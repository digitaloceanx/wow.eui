
BuildEnv(...)

local MOUNT_FACTION_TEXTURES = {
    [0] = "MountJournalIcons-Horde",
    [1] = "MountJournalIcons-Alliance"
}

MountPanel = Addon:NewModule(CreateFrame('Frame'), 'MountPanel', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0', 'LibInvoke-1.0')
MountPanel:Hide()

function MountPanel:OnEnable()
    GUI:Embed(self, 'Refresh', 'Blocker', 'Help')
    self:SetParent(MountJournal)
    self:Show()
    self:SetAllPoints(true)

    self.recommend = {}

    MountJournalFilterButton:SetScript('OnClick', function(button)
        GUI:ToggleMenu(button, self:GetFilterMenuTable(), 20, 'TOPLEFT', button, 'TOPLEFT', 74, -7)
        -- self:SendMessage('COLLECTOR_FILTER_CLICK')
    end)

    local PlanButton = CreateFrame('Button', nil, MountJournal, 'UIPanelButtonTemplate') do
        PlanButton:SetSize(140, 22)
        PlanButton:SetPoint('BOTTOMRIGHT')
        MagicButton_OnLoad(PlanButton)
        PlanButton:SetText(L['加入计划任务'])
        PlanButton:SetScript('OnClick', function()
            Profile:AddOrDelPlan(COLLECT_TYPE_MOUNT, self.spellID)
        end)
    end

    local CurrentArea = GUI:GetClass('CheckBox'):New(MountJournal) do
        CurrentArea:SetPoint('LEFT', MountJournal.MountCount, 'RIGHT', 10, 0)
        CurrentArea:SetText(L['仅当前区域'])
        CurrentArea:SetScript('OnClick', function(CurrentArea)
            MountFilter:SetOnlyCurrentArea(CurrentArea:GetChecked())
            -- self:SendMessage('COLLECTOR_CURRENTAREA_CLICK')
        end)
    end

    local Blocker = self:NewBlocker('recommend', 1) do
        Blocker:SetPoint('TOPRIGHT', -3, -60)
        Blocker:SetPoint('BOTTOMLEFT', 2, 2)
        Blocker:SetFrameStrata('DIALOG')
        -- Blocker:Show()
        Blocker:Hide()

        Blocker:SetCallback('OnInit', function()
            local List = GUI:GetClass('GridView'):New(Blocker) do
                List:SetPoint('TOPLEFT', 5, -5)
                List:SetSize(1, 1)
                List:SetItemClass(Addon:GetClass('RecommendItem'))
                List:SetItemWidth(342)
                List:SetItemHeight(257)
                List:SetColumnCount(2)
                List:SetRowCount(2)
                List:SetItemSpacing(5)
                List:SetAutoSize(true)
                List:SetItemList(self:GetRecommend())
                List:SetCallback('OnItemFormatted', function(_, button, mount)
                    button:SetItem(mount)
                end)
                List:SetCallback('OnItemClick', function(_, _, mount)
                    ToggleFrame(Blocker)
                    Addon:ToggleMountJournal(mount)
                end)
                List:Refresh()
            end
        end)

        local Text = Blocker:CreateFontString(nil, 'OVERLAY', 'GameFontNormal') do
            Text:Hide()
            Text:SetWidth(500)
            Text:SetWordWrap(true)
            Text:SetPoint('CENTER')
        end

        Blocker.Text = Text
        Blocker:HookScript('OnHide', function()
            self:SendMessage('COLLECTOR_RECOMMEND_HIDE')
        end)
    end

    local BlockButton = GUI:GetClass('TitleButton'):New(self) do
        BlockButton:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]], 0, 0.5, 0, 0.5)
        BlockButton:SetSize(20, 20)
        BlockButton:SetPoint('TOPRIGHT', -30, -3)
        BlockButton:SetTooltip(L['今日推荐'])
        BlockButton:SetScript('OnClick', function()
            self:SetBlocker(true)
        end)
    end

    local Card = Addon:GetClass('Card'):New(MountJournal) do
        Card:SetAllPoints(MountJournal.RightInset)
        Card:SetFrameLevel(MountJournal.RightInset:GetFrameLevel() + 10)
        Card:SetCallback('OnFanfareFinished', function()
            local mount = self:GetSelectedMount()
            if mount then
                mount:ClearFanfare()
                MountFilter:Refresh()
            end
        end)
    end

    local MountList = CreateFrame('ScrollFrame', 'CollectorMountList', MountJournal, 'HybridScrollFrameTemplate') do
        MountList:SetAllPoints(MountJournal.ListScrollFrame)

        local scrollBar = CreateFrame('Slider', 'CollectorMountListScrollBar', MountList, 'HybridScrollBarTrimTemplate') do
            scrollBar:SetAllPoints(MountJournal.ListScrollFrame.scrollBar)
            scrollBar.trackBG:Show()
            scrollBar.trackBG:SetVertexColor(0, 0, 0, 0.75)
            scrollBar.doNotHide = true
            MountList.scrollBar = scrollBar
        end
        HybridScrollFrame_CreateButtons(MountList, 'MountListButtonTemplate', 44, 0)

        MountList.update = function()
            return self:Refresh()
        end
        MountJournal.ListScrollFrame:Hide()

        local function ButtonOnClick(button, click)
            if click == 'RightButton' then
                return self:ToggleMountDropDown(button.mount, button)
            end
            return MountListItem_OnClick(button, click)
        end

        local function Pickup(index)
            if not InCombatLockdown() then
                C_MountJournal.Pickup(index)
            end
        end

        local function DragButtonOnDragStart(button)
            return Pickup(button:GetParent().index)
        end

        local function DragButtonOnClick(button, click)
            if click == 'RightButton' then
                return self:ToggleMountDropDown(button:GetParent().mount, button:GetParent(), button)
            elseif not IsModifiedClick('CHATLINK') then
                return DragButtonOnDragStart(button)
            else
                return MountListDragButton_OnClick(button, click)
            end
        end


        for i, button in ipairs(MountList.buttons) do
            button:SetFrameLevel(MountList:GetFrameLevel()+1)
            button:SetScript('OnClick', ButtonOnClick)
            button.DragButton:SetScript('OnClick', DragButtonOnClick)
            button.DragButton:SetScript('OnDragStart', DragButtonOnDragStart)

            local PlanLayer = button:CreateTexture(nil, 'OVERLAY') do
                PlanLayer:SetAllPoints(button.favorite)
                PlanLayer:SetTexture([[Interface\COMMON\friendship-FistHuman]])
                PlanLayer:SetTexCoord(button.favorite:GetTexCoord())
            end
            button.PlanLayer = PlanLayer
        end
    end

    local MountJournalHelpList = {
        FramePos = { x = 0,          y = -22 },
        FrameSize = { width = 700, height = 580 },
        { ButtonPos = { x = 106,   y = -35 }, HighLightBox = { x = 10, y = -45, width = 247, height = 30 },   ToolTipDir = "DOWN",  ToolTipText = L.MJHelp1 },
        { ButtonPos = { x = 105,  y = -300 }, HighLightBox = { x = 10, y = -78, width = 247, height = 477 },  ToolTipDir = "DOWN",  ToolTipText = L.MJHelp2 },
        { ButtonPos = { x = 525,  y = -546},  HighLightBox = { x = 550, y = -556, width = 150, height = 26 }, ToolTipDir = "UP",    ToolTipText = L.MJHelp3 },
        { ButtonPos = { x = 470,  y = -95 },  HighLightBox = { x = 290, y = -45, width = 400, height = 160 }, ToolTipDir = "RIGHT", ToolTipText = L.MJHelp4 },
        { ButtonPos = { x = 175,  y = 0 },    HighLightBox = { x = 200, y = 0, width = 150, height = 40 },    ToolTipDir = "UP",    ToolTipText = L.MJHelp5 },
    }

    self.HelpButton = self:AddHelpButton(MountJournal, MountJournalHelpList, nil, CollectionsJournal)

    self.PlanButton = PlanButton
    self.CurrentArea = CurrentArea
    self.Blocker = Blocker
    self.BlockButton = BlockButton
    self.Rarity = Rarity
    self.Card = Card
    self.MountList = MountList

    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
    self:Refresh()
    self:UpdateDisplay()

    self:SecureHook('MountJournal_UpdateMountDisplay', 'UpdateDisplay')
    self:SecureHook('MountJournal_Select', 'Refresh')
    self:RegisterMessage('COLLECTOR_MOUNT_LIST_UPDATED', 'Refresh')
    self:RegisterEvent('PLAYER_REGEN_ENABLED', 'Refresh')
    self:RegisterEvent('PLAYER_REGEN_DISABLED', 'Refresh')
    
    self:RegisterMessage('COLLECTOR_RECOMMEND_UPDATE')

    self:RegisterMessage('COLLECTOR_PLANLIST_UPDATE', 'UpdatePlan')
    self:RegisterMessage('COLLECTOR_HELP_UPDATE')
end

function MountPanel:UpdateList()
    local scrollFrame = self.MountList
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    local numDisplayedMounts = MountFilter:GetNumDisplayedMounts()
    local showMounts = C_MountJournal.GetNumMounts() > 0

    for i = 1, #buttons do
        local button = buttons[i]
        local index = i + offset

        if index <= numDisplayedMounts and showMounts then
            local index = MountFilter:GetDisplayed(index)

            local creatureName, spellID, icon, active, isUsable, sourceType,
                    isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index)
            local mount = Mount:Get(spellID)
            local needsFanFare = mount:NeedsFanfare()

            button.name:SetText(creatureName)
            button.icon:SetTexture(needsFanFare and COLLECTIONS_FANFARE_ICON or icon)
            button.new:SetShown(needsFanFare)
            button.newGlow:SetShown(needsFanFare)

            button.mount = mount
            button.index = index
            button.spellID = spellID
            button.active = active
            button.selected = MountJournal.selectedSpellID == spellID

            button.DragButton.ActiveTexture:SetShown(active)
            button.selectedTexture:SetShown(button.selected)
            button.favorite:SetShown(isFavorite)
            button.PlanLayer:SetShown(mount:IsInPlan())
            button:Show()

            button:SetEnabled(true)
            button.unusable:Hide()
            button.iconBorder:Hide()
            button.background:SetVertexColor(1, 1, 1, 1)

            if isUsable or needsFanFare then
                button.DragButton:SetEnabled(true)
                button.additionalText = nil
                button.icon:SetDesaturated(false)
                button.icon:SetAlpha(1.0)
                button.name:SetFontObject('GameFontNormal')
            else
                if isCollected then
                    button.unusable:Show()
                    button.DragButton:SetEnabled(true)
                    button.name:SetFontObject('GameFontNormal')
                    button.icon:SetAlpha(0.75)
                    button.additionalText = nil
                    button.background:SetVertexColor(1, 0, 0, 1)
                else
                    button.icon:SetDesaturated(true)
                    button.DragButton:SetEnabled(false)
                    button.icon:SetAlpha(0.25)
                    button.additionalText = nil
                    button.name:SetFontObject('GameFontDisable')
                end
            end

            if isFactionSpecific then
                button.factionIcon:SetAtlas(MOUNT_FACTION_TEXTURES[faction], true)
                button.factionIcon:Show()
            else
                button.factionIcon:Hide()
            end
            
            if button.DragButton.showingTooltip then
                MountJournalMountButton_UpdateTooltip(button)
            end
        else
            button.name:SetText('')
            button.icon:SetTexture('Interface\\PetBattles\\MountJournalEmptyIcon')
            button.index = nil
            button.spellID = 0
            button.selected = false
            button.unusable:Hide()
            button.DragButton.ActiveTexture:Hide()
            button.selectedTexture:Hide()
            button:SetEnabled(false)
            button.DragButton:SetEnabled(false)
            button.icon:SetDesaturated(true)
            button.icon:SetAlpha(0.5)
            button.favorite:Hide()
            button.factionIcon:Hide()
            button.background:SetVertexColor(1, 1, 1, 1)
            button.iconBorder:Hide()
            button.PlanLayer:Hide()
        end
    end

    HybridScrollFrame_Update(scrollFrame, numDisplayedMounts * 46, scrollFrame:GetHeight())
end

function MountPanel:UpdateMountIndex()
    if not self.selectedSpellID then
        return
    end

    local mountIndex = nil
    for i = 1, MountFilter:GetNumDisplayedMounts() do
        if self.selectedSpellID == select(2, C_MountJournal.GetDisplayedMountInfo(MountFilter:GetDisplayed(i))) then
            mountIndex = i
            break
        end
    end
    if mountIndex then
        PetJournalPetList_UpdateScrollPos(self.MountList, mountIndex)
    end
    self.selectedSpellID = nil
end

function MountPanel:Update()
    self:UpdateList()
    self:UpdateMountIndex()
end

function MountPanel:OnShow()
    -- self:Refresh()
    MountFilter:Refresh()
    self:CheckShowRecommend()
end

function MountPanel:OnHide()
    for _, mount in MountFilter:IterateMounts() do
        mount:SetIsNew(false)
    end
end

function MountPanel:CheckShowRecommend()
    if Profile:IsRecommendShown() then
        return
    end

    if PanelTemplates_GetSelectedTab(CollectionsJournal) ~= 1 then
        if InCombatLockdown() then
            return
        else
            if CollectionsJournal_SetTab then
                CollectionsJournal_SetTab(CollectionsJournal, 1)
            else
                SetCVar('petJournalTab', 1)
            end
        end
    end

    

    self:SetBlocker(true)
    self:SendMessage('COLLECTOR_RECOMMEND_SHOW')
end

function MountPanel:COLLECTOR_HELP_UPDATE(_, enable)
    if enable then
        self:SetBlocker(false)
    else
        self:CheckShowRecommend()
    end
end

function MountPanel:SetBlocker(enable)
    if enable then
        ToggleFrame(self.Blocker)
    else
        HideUIPanel(self.Blocker)     
    end
end

function MountPanel:GetSelectedMount()
    local spellID = MountJournal.selectedSpellID

    return spellID and Mount:Get(spellID)
end

function MountPanel.InvokeOnce:UpdateDisplay()
    local mount = self:GetSelectedMount()
    if not mount then
        self.Card:Hide()
        MountJournal.RightInset:Show()
        MountJournal.MountDisplay:Show()
    else
        
        self:UpdatePlan()
        self.Card:Show()
        self.Card:SetPlan(Plan:Get(COLLECT_TYPE_MOUNT, mount:GetID()), mount:NeedsFanfare())

        MountJournal.RightInset:Hide()
        MountJournal.MountDisplay:Hide()

        self.spellID = mount:GetID()
        self:SendMessage('COLLECTOR_PLANBUTTON_CHANGED', not isCollected and not inPlan)
    end
end

function MountPanel:UpdatePlan()
    local mount = self:GetSelectedMount()
    if not mount then
        return
    end

    local hideOnChar, isCollected, isFavorite, inPlan = mount:GetStat()

    self.PlanButton:SetEnabled(not isCollected and not hideOnChar)
    self.PlanButton:SetText(inPlan and L['取消计划任务'] or L['加入计划任务'])
end

function MountPanel:ToggleMountDropDown(mount, owner, anchor)
    GUI:ToggleMenu(owner, function()
        return self:GetMountMenuTable(mount, owner.index)
    end, 20, 'TOPLEFT', anchor or owner, 'BOTTOMLEFT')
end

function MountPanel:GetMountMenuTable(mount, index)
    local menuTable = {}

    if mount:IsCollected() then
        local isActive = mount:IsActive()
        tinsert(menuTable, {
            text = isActive and PET_DISMISS or BATTLE_PET_SUMMON,
            func = function()
                if isActive then
                    mount:Dismiss()
                else
                    mount:Summon()
                end
            end
        })

        local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(index)
        tinsert(menuTable, {
            text = isFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE,
            disabled = not canFavorite,
            func = function()
                C_MountJournal.SetIsFavorite(index, not isFavorite)
            end
        })
    else
        tinsert(menuTable, {
            text = mount:IsInPlan() and L['取消计划任务'] or L['加入计划任务'],
            func = function()
                Profile:AddOrDelPlan(COLLECT_TYPE_MOUNT, mount:GetID())
            end,
        })
    end

    do
        local list = mount:GetAchievementMenu()
        for i, v in ipairs(mount:GetAchievementMenu()) do
            tinsert(menuTable, v)
        end
    end

    tinsert(menuTable, { text = CANCEL })

    return menuTable
end

function MountPanel:GetFilterMenuTable()
    if not self.menuTable then
        local function MakeFilterTypeMenuTable(filter, name, hasAll, parentCheckable)
            local menuTable = type(name) == 'table' and name or {
                text = name,
                keepShownOnClick = true,
                hasArrow = true,
            }

            if parentCheckable then
                menuTable.checkable = true
                menuTable.isNotRadio = true
                menuTable.refreshParentOnClick = true
                menuTable.checked = function()
                    return MountFilter:IsAnyTypeFilterChecked(filter)
                end
                menuTable.func = function(_, _, _, checked)
                    return MountFilter:SetAllTypeFilterChecked(filter, checked)
                end
            else
                menuTable.fontObject = function()
                    return MountFilter:IsAnyTypeFilterNotChecked(filter) and 'GameFontGreenSmall'
                end
            end

            if hasAll then
                menuTable.menuTable = {
                    {
                        text = CHECK_ALL,
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        func = function()
                            MountFilter:SetAllTypeFilterChecked(filter, true)
                        end
                    },
                    {

                        text = UNCHECK_ALL,
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        func = function()
                            MountFilter:SetAllTypeFilterChecked(filter, false)
                        end
                    },
                    {
                        isSeparator = true,
                    },
                }
            else
                menuTable.menuTable = {}
            end

            for _, v in ipairs(MOUNT_JOURNAL_FILTER_TYPES[filter]) do
                tinsert(menuTable.menuTable, {
                    text = v.text,
                    keepShownOnClick = true,
                    refreshParentOnClick = true,
                    checkable = true,
                    isNotRadio = true,
                    checked = function()
                        return MountFilter:IsTypeFilterChecked(filter, v.id)
                    end,
                    func = function(_,_,_,checked)
                        MountFilter:SetTypeFilterChecked(filter, v.id, checked)
                    end,
                })
            end

            return menuTable
        end

        local function MakeSortMenuTable(key, name)
            return {
                text = name,
                value = key,
                keepShownOnClick = true,
                refreshParentOnClick = true,
                checkable = true,
                checked = function(data)
                    return MountFilter:GetSortKey() == data.value
                end,
                func = function(_, data)
                    MountFilter:SetSortKey(data.value)
                end
            }
        end

        local function MakeBlizzardFilter(text, all, num, set, is, pn)
            local menuTable = {
                text = text,
                keepShownOnClick = true,
                hasArrow = true,
                fontObject = function()
                    for i = 1, num() do
                        if not is(i) then
                            return 'GameFontGreenSmall'
                        end
                    end
                end,
                menuTable = {
                    {
                        text = CHECK_ALL,
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        func = function()
                            all(true)
                        end,
                    },
                    {
                        text = UNCHECK_ALL,
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        func = function()
                            all(false)
                        end,
                    },
                    {
                        isSeparator = true,
                    },
                },
            }

            for i = 1, num() do
                tinsert(menuTable.menuTable, {
                    text = _G[pn .. i],
                    checkable = true,
                    isNotRadio = true,
                    keepShownOnClick = true,
                    refreshParentOnClick = true,
                    checked = function()
                        return is(i)
                    end,
                    func = function(_,_,_,value)
                        set(i, value)
                    end,
                })
            end
            return menuTable
        end

        self.menuTable = {
            -- MakeFilterTypeMenuTable('Favorite', COLLECTED, false, true),
            -- MakeFilterTypeMenuTable('Plan', NOT_COLLECTED, false, true),

            {
                text = COLLECTED,
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED)
                end,
                func = function(_,_,_,value)
                    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, value)
                end,
            },
            {
                text = NOT_COLLECTED,
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED)
                end,
                func = function(_,_,_,value)
                    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, value)
                end,
            },
            {
                isSeparator = true,
            },
            {
                text = L['过滤器'],
                isTitle = true,
            },
            MakeFilterTypeMenuTable('Rarity',      L['* 稀有度'],   true),
            MakeFilterTypeMenuTable('Model',       L['* 模型'],     true),
            MakeFilterTypeMenuTable('Walk',        L['* 行走方式'], true),
            MakeFilterTypeMenuTable('Passenger',   L['* 乘客类型'], true),
            MakeBlizzardFilter(
                SOURCES,
                C_MountJournal.SetAllSourceFilters,
                C_PetJournal.GetNumPetSources,
                C_MountJournal.SetSourceFilter,
                C_MountJournal.IsSourceChecked,
                'BATTLE_PET_SOURCE_'
            ),
            MakeFilterTypeMenuTable('Faction',     L['阵营'],     true),
            {
                isSeparator = true,
            },
            {
                text = L['* 排序'],
                keepShownOnClick = true,
                hasArrow = true,
                fontObject = function()
                    return (MountFilter:GetSortKey() ~= 'Name' or not MountFilter:IsFavoriteAtTop() or not MountFilter:IsPlanAtTop() or not MountFilter:IsNewAtTop()) and 'GameFontGreenSmall'
                end,
                menuTable = {
                    MakeSortMenuTable('Name',        L['名称']),
                    MakeSortMenuTable('Rarity',      L['稀有度']),
                    MakeSortMenuTable('Model',       L['模型']),
                    MakeSortMenuTable('Walk',        L['行走方式']),
                    MakeSortMenuTable('Passenger',   L['乘客类型']),
                    MakeSortMenuTable('Source',      SOURCES),
                    MakeSortMenuTable('Faction',     L['阵营']),
                    MakeSortMenuTable('Progress',    L['完成度']),
                    {
                        isSeparator = true,
                    },
                    {
                        text = L['偏好置顶'],
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        checkable = true,
                        isNotRadio = true,
                        checked = function()
                            return MountFilter:IsFavoriteAtTop()
                        end,
                        func = function(_,_,_,checked)
                            MountFilter:SetFavoriteAtTop(checked)
                        end
                    },
                    {
                        text = L['计划置顶'],
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        checkable = true,
                        isNotRadio = true,
                        checked = function()
                            return MountFilter:IsPlanAtTop()
                        end,
                        func = function(_,_,_,checked)
                            MountFilter:SetPlanAtTop(checked)
                        end
                    },
                    {
                        text = L['新收集置顶'],
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        checkable = true,
                        isNotRadio = true,
                        checked = function()
                            return MountFilter:IsNewAtTop()
                        end,
                        func = function(_,_,_,checked)
                            MountFilter:SetNewAtTop(checked)
                        end
                    },
                },
            },
            {
                isSeparator = true,
            },
            {
                text = RESET,
                keepShownOnClick = true,
                func = function()
                    self:ResetFilter()
                end
            }
        }
    end
    return self.menuTable
end

function MountPanel:ResetFilter()
    self.CurrentArea:SetChecked(false)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, true)
    C_MountJournal.SetAllSourceFilters(true)
    MountFilter:ResetFilterAndSort()
end

function MountPanel:COLLECTOR_RECOMMEND_UPDATE()
    wipe(self.recommend)
    for _, v in MountFilter:IterateMounts() do
        if v:IsRecommend() then
            tinsert(self.recommend, v)
        end
    end
end

function MountPanel:GetRecommend()
    local maxRate = -1
    local cache = {
        Cool = {},
        Easy = {},
        ProgressRate = {},
        Top20List = {},
    }

    for _, mount in MountFilter:IterateMounts() do
        if not mount:IsCollected() and not mount:IsInPlan() and not mount:IsHideOnChar() then
            if mount:GetAttribute('Cool') then
                tinsert(cache.Cool, mount)
            elseif mount:GetAttribute('Easy') then
                tinsert(cache.Easy, mount)
            elseif mount:IsInTop20() then
                tinsert(cache.Top20List, mount)
            else
                local rate = mount:GetProgressRate()
                if rate and rate > maxRate then
                    cache.ProgressRate[1] = mount
                    maxRate = rate
                end
            end
        end
    end

    local list = {}

    for k, v in pairs(cache) do
        if next(v) then
            local mount = v[fastrandom(1, #v)]
            mount:SetRecommend(true, L[k])
            tinsert(list, mount)
        end
    end
    return list
end

function MountPanel:SelectMount(mount)
    MountJournal.selectedSpellID = mount:GetID()
    MountJournal.selectedMountID = mount:GetMountID()
    self.selectedSpellID = mount:GetID()
    self:UpdateDisplay()
    self:Refresh()
end
