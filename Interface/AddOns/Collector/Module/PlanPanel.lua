
BuildEnv(...)

PlanPanel = Addon:NewModule(CreateFrame('Frame'), 'PlanPanel', 'AceEvent-3.0', 'AceHook-3.0', 'AceBucket-3.0', 'AceTimer-3.0', 'LibInvoke-1.0')
PlanPanel:Hide()

function PlanPanel:OnEnable()
    self:SetParent(CollectionsJournal)
    GUI:Embed(self, 'Refresh')

    self:Hide()
    self:SetPoint('TOPLEFT', 4, -60)
    self:SetPoint('BOTTOMRIGHT', -6, 26)
    self:SetFrameLevel(CollectionsJournal:GetFrameLevel() + 100)
    self:EnableMouse(true)
    self:EnableMouseWheel(true)
    self:SetScript('OnMouseWheel', nop)

    local cover = CreateFrame('Frame', nil, self) do
        cover:SetPoint('TOPLEFT', CollectionsJournal, 0, -20)
        cover:SetPoint('BOTTOMRIGHT', CollectionsJournal, 0, 0)
        cover:EnableMouse(true)
        cover:EnableMouseWheel(true)
        cover:SetScript('OnMouseWheel', nop)
    end

    local Tab do
        local id = CollectionsJournal.numTabs + 1
        Tab = CreateFrame('Button', 'CollectionsJournalTab' .. id, CollectionsJournal, 'CharacterFrameTabButtonTemplate', id) do
            Tab:SetPoint('LEFT', _G['CollectionsJournalTab' .. (id-1)], 'RIGHT', -16, 0)
            Tab:SetText(L['计划任务'])

            PanelTemplates_TabResize(Tab, 0, nil, 36, 88)
            PanelTemplates_UpdateTabs(CollectionsJournal)
            PanelTemplates_DeselectTab(Tab)
        end

        local function CollectionsJournal_UpdateSelectedTab()
            local selectedTab = PanelTemplates_GetSelectedTab(CollectionsJournal)
            if selectedTab then
                self:Hide()
                PanelTemplates_DeselectTab(Tab)
            else
                self:Show()
                PanelTemplates_SelectTab(Tab)
            end
        end

        self:SecureHook('CollectionsJournal_UpdateSelectedTab', CollectionsJournal_UpdateSelectedTab)

        Tab:SetScript('OnClick', function()
            CollectionsJournal.selectedTab = 99
            PanelTemplates_UpdateTabs(CollectionsJournal)
            CollectionsJournal.selectedTab = nil

            HideUIPanel(CollectionsJournal)
            ShowUIPanel(CollectionsJournal)
        end)

        for i = 6, id -1 do
            _G['CollectionsJournalTab' .. i]:HookScript('OnClick', CollectionsJournal_UpdateSelectedTab)
        end
    end

    local LeftInset = CreateFrame('Frame', nil, self, 'InsetFrameTemplate') do
        LeftInset:SetPoint('TOPLEFT')
        LeftInset:SetPoint('BOTTOMLEFT')
        LeftInset:SetWidth(260)
    end

    local PlanList = GUI:GetClass('ListView'):New(LeftInset) do
        PlanList:SetPoint('TOPLEFT', 2, -5)
        PlanList:SetPoint('BOTTOMRIGHT', -5, 5)
        PlanList:SetItemClass(Addon:GetClass('PlanItem'))
        PlanList:SetItemHeight(46)
        PlanList:SetItemSpacing(0)
        PlanList:SetSelectMode('RADIO')
        PlanList:SetItemList(Profile:GetPlanList())

        PlanList:SetCallback('OnItemFormatted', function(PlanList, button, plan)
            button:SetPlan(plan)
        end)
        PlanList:SetCallback('OnItemMenu', function(PlanList, button, plan)
            self:TogglePanelMenu(button, plan)
        end)
        PlanList:SetCallback('OnRefresh', function(PlanList, ...)
            PlanList.Empty:SetShown(PlanList:GetItemCount() == 0)
        end)
        PlanList:SetCallback('OnSelectChanged', function(_, _, plan)
            if plan then
                self:SetPlan(plan)
            else
                self:ClearPlan()
            end
        end)
        PlanList:SetCallback('OnItemClick', function(_, _, plan)
            if IsShiftKeyDown() then
                Profile:AddOrDelTrack(plan:GetCollectType(), plan:GetID())
            end
        end)

        PlanList.Empty = PlanList:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') do
            PlanList.Empty:SetText(L['暂时没有计划'])
            PlanList.Empty:SetPoint('CENTER')
        end
    end

    local EmptyInset = CreateFrame('Frame', nil, self, 'InsetFrameTemplate') do
        EmptyInset:SetPoint('TOPLEFT', LeftInset, 'TOPRIGHT', 5, 0)
        EmptyInset:SetPoint('BOTTOMRIGHT')
        EmptyInset.Bg:SetHorizTile(false)
        EmptyInset.Bg:SetVertTile(false)
        EmptyInset.Bg:SetTexture([[Interface\PetBattles\MountJournal-NoMounts]])
        EmptyInset.Bg:SetTexCoord(0, 0.78515625, 0, 1)
    end

    local Card = Addon:GetClass('Card'):New(self) do
        Card:SetPoint('TOPLEFT', LeftInset, 'TOPRIGHT', 5, 0)
        Card:SetPoint('BOTTOMRIGHT')
    end

    local Flyin = CreateFrame('Button', nil, Tab, 'ItemAnimTemplate') do
        Flyin:SetSize(30, 30)
        Flyin:SetFrameStrata('DIALOG')
        Flyin:SetPoint('CENTER')
        Flyin:UnregisterAllEvents()
        Flyin:SetScript('OnEvent', nil)
        Flyin:EnableMouse(false)
        Flyin.flyin:SetScript('OnPlay', function()
            Flyin.animIcon:Show()
        end)
        Flyin.flyin:SetScript('OnFinished', function()
            Flyin.animIcon:Hide()
        end)
    end

    local ObjectivesToggle = GUI:GetClass('CheckBox'):New(self) do
        ObjectivesToggle:SetPoint('BOTTOMRIGHT', CollectionsJournal, 'BOTTOMRIGHT', -80, 3)
        ObjectivesToggle:SetText(L['追踪计划'])
        ObjectivesToggle:SetFrameLevel(self:GetFrameLevel()+ 10)
        ObjectivesToggle:SetChecked(Profile:GetVar('objectives'))
        ObjectivesToggle:SetScript('OnClick', function(self)
            Profile:SetVar('objectives', self:GetChecked())
        end)
    end

    local OptionButton = CreateFrame('Button', nil, self) do
        OptionButton:SetSize(32, 32)
        OptionButton:SetNormalTexture([[Interface\BUTTONS\UI-SquareButton-Up]])
        OptionButton:SetPushedTexture([[Interface\BUTTONS\UI-SquareButton-Down]])
        OptionButton:SetHighlightTexture([[Interface\BUTTONS\UI-Common-MouseHilight]], 'ADD')
        OptionButton:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
        OptionButton:SetFrameLevel(cover:GetFrameLevel() + 10)

        local Icon = OptionButton:CreateTexture(nil, 'OVERLAY') do
            Icon:SetSize(16, 16)
            Icon:SetPoint('CENTER')
            Icon:SetTexture([[Interface\GossipFrame\BinderGossipIcon]])
        end

        OptionButton:SetScript('OnMouseUp', function()
            Icon:SetPoint('CENTER')
        end)
        OptionButton:SetScript('OnMouseDown', function()
            Icon:SetPoint('CENTER', -1, -1)
        end)
        OptionButton:SetScript('OnClick', function()
            Option:Toggle()
        end)
    end

    self.EmptyInset = EmptyInset
    self.Card = Card
    self.Flyin = Flyin
    self.PlanList = PlanList
    self.InfoTab = InfoTab
    self.Tab = Tab
    self.ObjectivesToggle = ObjectivesToggle

    self:SetScript('OnShow', self.OnShow)
    self:RegisterMessage('COLLECTOR_PLANLIST_UPDATE', 'RefreshPlanList')
    self:RegisterMessage('COLLECTOR_TRACKLIST_UPDATE', 'RefreshPlanList')
    self:RegisterMessage('COLLECTOR_PLAN_ADDED')
    self:RegisterMessage('COLLECTOR_SETTING_UPDATE')

    self:RegisterBucketEvent({'UPDATE_FACTION', 'UPDATE_INSTANCE_INFO'}, 1, 'RefreshPlanList')
end

function PlanPanel.Invoke:Toggle(plan)
    if not self.Tab then
        return self:Toggle(plan)
    end
    ShowUIPanel(CollectionsJournal)
    self.Tab:Click()
    self:SetPlan(plan)
end

function PlanPanel:OnShow()
    RequestRaidInfo()

    if not self.PlanList:GetSelected() then
        self.PlanList:SetSelected(1)
    end
    self:RefreshPlanList()

    CollectionsJournalTitleText:SetText(L['魔兽达人'])
    CollectionsJournalPortrait:SetTexture([[Interface\AddOns\Collector\Media\Logo]])
    -- SetPortraitToTexture(CollectionsJournalPortrait, [[Interface\AddOns\Collector\Media\Logo]])
end

function PlanPanel:RefreshPlanList()
    self.PlanList:Refresh()
    local plan = self.PlanList:GetSelectedItem()
    if plan then
        self:SetPlan(plan)
    end
end

function PlanPanel:TogglePanelMenu(owner, plan)
    GUI:ToggleMenu(owner, function()
        return self:GetPlanMenuTable(plan)
    end, 'TOPLEFT', owner, 'BOTTOMLEFT', 48, 2)
end

function PlanPanel:GetPlanMenuTable(plan)
    local item = plan:GetObject()

    local menuTable = {
        {
            text = L['取消计划任务'],
            func = function()
                Profile:DelPlan(plan:GetCollectType(), plan:GetID())
            end
        },
        {
            text = item:IsInTrack() and L['取消追踪'] or L['追踪'],
            func = function()
                Profile:AddOrDelTrack(plan:GetCollectType(), plan:GetID())
            end
        },
        item:GetAreaMenu(),
    }

    for i, v in ipairs(item:GetAchievementMenu()) do
        tinsert(menuTable, v)
    end

    tinsert(menuTable, {text = CANCEL})

    return menuTable
end

function PlanPanel:SetPlan(plan)
    GUI:CloseMenu()

    self.plan = plan

    self.Card:SetPlan(plan)
    self.Card:Show()
    self.EmptyInset:Hide()
    self.PlanList:SetSelectedItem(plan)
end

function PlanPanel:ClearPlan()
    self.Card:Hide()
    self.EmptyInset:Show()
end

function PlanPanel:COLLECTOR_PLAN_ADDED(_, collectType, id)
    if not self.Flyin:IsVisible() then
        return
    end
    local plan = Plan:Get(collectType, id)
    self.Flyin.animIcon:SetTexture(plan:GetObject():GetIcon())
    self.Flyin.flyin:Play(true)
end

function PlanPanel:COLLECTOR_SETTING_UPDATE(_, key, value)
    if key == 'objectives' then
        self.ObjectivesToggle:SetChecked(value)
    end
end
