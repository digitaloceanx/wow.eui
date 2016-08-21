
BuildEnv(...)

PetPanel = Addon:NewModule(CreateFrame('Frame'), 'PetPanel', 'AceEvent-3.0', 'AceHook-3.0')
PetPanel:Hide()

function PetPanel:OnEnable()
    self:SetParent(PetJournal)
    self:Show()
    GUI:Embed(self, 'Refresh')

    

    PetJournalRightInset:SetPoint('TOPRIGHT', -6, -261)
    PetJournalLoadoutBorder:SetHeight(319)
    PetJournalLoadoutBorderSlotHeaderBG:Hide()
    PetJournalLoadoutBorderSlotHeaderText:Hide()
    PetJournalLoadoutBorderSlotHeaderF:Hide()
    PetJournalLoadoutBorderSlotHeaderLeft:Hide()
    PetJournalLoadoutBorderSlotHeaderRight:Hide()
    PetJournalLoadoutPet1:SetHeight(103)
    PetJournalLoadoutPet2:SetHeight(103)
    PetJournalLoadoutPet3:SetHeight(103)
    PetJournalLoadoutPet1BG:SetHeight(103)
    PetJournalLoadoutPet2BG:SetHeight(103)
    PetJournalLoadoutPet3BG:SetHeight(103)
    PetJournalLoadoutPet1HelpFrame:SetHeight(103)
    PetJournalLoadoutPet2HelpFrame:SetHeight(103)
    PetJournalLoadoutPet3HelpFrame:SetHeight(103)
    PetJournalLoadoutPet1HelpFrameHelpPlate:SetHeight(103)
    PetJournalLoadoutPet2HelpFrameHelpPlate:SetHeight(103)
    PetJournalLoadoutPet3HelpFrameHelpPlate:SetHeight(103)

    PetJournalLoadoutPet1HealthFrame:SetPoint('TOPLEFT', PetJournalLoadoutPet1Icon, 'BOTTOMRIGHT', 12, -2)
    PetJournalLoadoutPet2HealthFrame:SetPoint('TOPLEFT', PetJournalLoadoutPet2Icon, 'BOTTOMRIGHT', 12, -2)
    PetJournalLoadoutPet3HealthFrame:SetPoint('TOPLEFT', PetJournalLoadoutPet3Icon, 'BOTTOMRIGHT', 12, -2)

    PetJournalLoadoutPet2:SetPoint('TOP', 0, -107)
    PetJournalLoadoutPet3:SetPoint('TOP', 0, -211)

    PetJournalLoadout:HookScript('OnShow', function()
        PetJournalLoadoutBorder:Show()
    end)
    PetJournalLoadout:HookScript('OnHide', function()
        PetJournalLoadoutBorder:Hide()
    end)

    local PlanButton = CreateFrame('Button', nil, PetJournal, 'UIPanelButtonTemplate') do
        PlanButton:SetSize(140, 22)
        PlanButton:SetPoint('RIGHT', PetJournalFindBattle, 'LEFT')
        MagicButton_OnLoad(PlanButton)
        PlanButton:SetText(L['加入计划任务'])
        PlanButton:SetScript('OnClick', function()
            if PetJournalPetCard.speciesID then
                Profile:AddOrDelPlan(COLLECT_TYPE_PET, PetJournalPetCard.speciesID)
            end
        end)
    end

    local CardProcessBar = CreateFrame('StatusBar', nil, PetJournalPetCard) do
        CardProcessBar:SetSize(390, 10)
        CardProcessBar:SetPoint('BOTTOM', 0, 8)
        CardProcessBar:SetStatusBarTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]], 'ARTWORK')
        CardProcessBar:SetMinMaxValues(0, 100)
        CardProcessBar:Hide()

        local Left = CardProcessBar:CreateTexture(nil, 'OVERLAY') do
            Left:SetPoint('LEFT', -3, 0)
            Left:SetSize(9, 13)
            Left:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-BarBorder]])
            Left:SetTexCoord(0.007843, 0.043137, 0.193548, 0.774193)
        end

        local Right = CardProcessBar:CreateTexture(nil, 'OVERLAY') do
            Right:SetPoint('RIGHT', 3, 0)
            Right:SetSize(9, 13)
            Right:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-BarBorder]])
            Right:SetTexCoord(0.043137, 0.007843, 0.193548, 0.774193)
        end

        local Middle = CardProcessBar:CreateTexture(nil, 'OVERLAY') do
            Middle:SetPoint('TOPLEFT', Left, 'TOPRIGHT')
            Middle:SetPoint('BOTTOMRIGHT', Right, 'BOTTOMLEFT')
            Middle:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-BarBorder]])
            Middle:SetTexCoord(0.113726, 0.1490196, 0.193548, 0.774193)
        end

        local Bg = CardProcessBar:CreateTexture(nil, 'BACKGROUND') do
            Bg:SetAllPoints(true)
            Bg:SetColorTexture(0.04, 0.07, 0.18)
        end
    end

    local CardProcessText = CardProcessBar:CreateFontString(nil, 'OVERLAY') do
        CardProcessText:SetPoint('CENTER', 0, 2)
        CardProcessText:SetFont(ChatFontNormal:GetFont(), 12, 'OUTLINE')
    end

    local InfoTab = GUI:GetClass('InTabPanel'):New(PetJournalRightInset) do
        InfoTab:SetPoint('TOPLEFT', 3, -3)
        InfoTab:SetPoint('BOTTOMRIGHT', -3, 3)
    end

    InfoTab:RegisterPanel(L['战队'], PetJournalLoadout, 0)
    
    local Map = Addon:GetClass('TabMap'):New(PetJournalRightInset) do
        InfoTab:RegisterPanel(L['地图'], Map, 0)
    end

    local Summary = Addon:GetClass('TabSummary'):New(PetJournalRightInset) do
        InfoTab:RegisterPanel(L['详情'], Summary, 0)
    end

    local Feed = Addon:GetClass('TabFeed'):New(PetJournalRightInset) do
        InfoTab:RegisterPanel(L['动态'], Feed, 0)
    end

    PetJournalFilterButton:SetScript('OnClick', function(button)
        GUI:ToggleMenu(button, self:GetFilterMenuTable(), 20, 'TOPLEFT', button, 'TOPLEFT', 74, -7)
    end)

    local PetList = CreateFrame('ScrollFrame', 'CollectorPetList', self, 'HybridScrollFrameTemplate') do
        PetList:SetAllPoints(PetJournal.listScroll)

        local scrollBar = CreateFrame('Slider', 'CollectorPetListScrollBar', PetList, 'HybridScrollBarTrimTemplate') do
            scrollBar:SetAllPoints(PetJournal.listScroll.scrollBar)
            scrollBar.trackBG:Show()
            scrollBar.trackBG:SetVertexColor(0, 0, 0, 0.75)
            scrollBar.doNotHide = true
            PetList.scrollBar = scrollBar
        end
        HybridScrollFrame_CreateButtons(PetList, 'CompanionListButtonTemplate', 44, 0)

        PetList.update = function()
            self:Refresh()
        end
        PetJournal.listScroll:Hide()

        local function ButtonOnClick(button, click, anchor)
            if click == 'RightButton' then
                return self:TogglePetDropDown(button.index, anchor or button)
            end
            PetJournalListItem_OnClick(button, click)
            self:Refresh()
        end

        local function DragButtonOnClick(button, click)
            return ButtonOnClick(button:GetParent(), click, button)
        end

        for i, button in ipairs(PetList.buttons) do
            button:SetFrameLevel(PetList:GetFrameLevel()+1)
            button:SetScript('OnClick', ButtonOnClick)
            button.dragButton:SetScript('OnClick', DragButtonOnClick)

            local PlanLayer = button.dragButton:CreateTexture(nil, 'OVERLAY') do
                PlanLayer:SetAllPoints(button.dragButton.favorite)
                PlanLayer:SetTexture([[Interface\COMMON\friendship-FistHuman]])
                PlanLayer:SetTexCoord(button.dragButton.favorite:GetTexCoord())
            end
            button.PlanLayer = PlanLayer
        end
    end

    self.CardProcessBar = CardProcessBar
    self.CardProcessText = CardProcessText
    self.Map = Map
    self.Feed = Feed
    self.Summary = Summary
    self.InfoTab = InfoTab
    self.PlanButton = PlanButton
    self.PetList = PetList

    self:SecureHook('PetJournal_UpdatePetCard', 'UpdateDisplay')
    self:SecureHook('PetJournal_SelectSpecies', 'SelectSpecies')

    self:RegisterMessage('COLLECTOR_PLANLIST_UPDATE', 'UpdateAll')
    self:RegisterMessage('COLLECTOR_PET_LIST_UPDATED', 'Refresh')

    self:SetScript('OnShow', function()
        PetFilter:Refresh()
    end)

    C_Timer.After(1, function()
        if PetTrackerTrackToggle then
            PetTrackerTrackToggle:ClearAllPoints()
            PetTrackerTrackToggle:SetPoint('RIGHT', PlanButton, 'LEFT', -80, 0)
        end
    end)
end

function PetPanel:UpdateAll()
    self:UpdateDisplay()
    self:Refresh()
end

function PetPanel:Update()
    if not self:IsVisible() then
        return
    end
    self:UpdateList()
    self:UpdatePetIndex()
end

function PetPanel:UpdateList()
    local scrollFrame = self.PetList
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local petButtons = scrollFrame.buttons
    local button, index

    local numPets = PetFilter:GetNumPets()
    local summonedPetID = C_PetJournal.GetSummonedPetGUID()

    for i = 1, #petButtons do
        button = petButtons[i]
        index = offset + i
        if index <= numPets then
            local index = PetFilter:GetDisplayed(index)
            local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(index)
            local needsFanfare = petID and C_PetJournal.PetNeedsFanfare(petID)

            if customName then
                button.name:SetText(customName)
                button.name:SetHeight(12)
                button.subName:Show()
                button.subName:SetText(name)
            else
                button.name:SetText(name)
                button.name:SetHeight(30)
                button.subName:Hide()
            end

            button.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon)
            button.new:SetShown(needsFanfare)
            button.newGlow:SetShown(needsFanfare)
            button.petTypeIcon:SetTexture(GetPetTypeTexture(petType))

            if (favorite) then
                button.dragButton.favorite:Show()
            else
                button.dragButton.favorite:Hide()
            end

            if isOwned then
                local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID)

                button.dragButton.levelBG:SetShown(canBattle)
                button.dragButton.level:SetShown(canBattle)
                button.dragButton.level:SetText(level)

                button.icon:SetDesaturated(false)
                button.name:SetFontObject('GameFontNormal')
                button.petTypeIcon:SetShown(canBattle)
                button.petTypeIcon:SetDesaturated(false)
                button.dragButton:Enable()
                button.iconBorder:Show()
                button.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b)
                if health and health <= 0 then
                    button.isDead:Show()
                else
                    button.isDead:Hide()
                end
                if isRevoked then
                    button.dragButton.levelBG:Hide()
                    button.dragButton.level:Hide()
                    button.iconBorder:Hide()
                    button.icon:SetDesaturated(true)
                    button.petTypeIcon:SetDesaturated(true)
                    button.dragButton:Disable()
                end
            else
                button.dragButton.levelBG:Hide()
                button.dragButton.level:Hide()
                button.icon:SetDesaturated(true)
                button.iconBorder:Hide()
                button.name:SetFontObject('GameFontDisable')
                button.petTypeIcon:SetShown(canBattle)
                button.petTypeIcon:SetDesaturated(true)
                button.dragButton:Disable()
                button.isDead:Hide()
            end

            button.PlanLayer:SetShown(Pet:Get(speciesID):IsInPlan())
            button.dragButton.ActiveTexture:SetShown(petID and petID == summonedPetID)

            button.petID = petID
            button.speciesID = speciesID
            button.index = index
            button.owned = isOwned
            button:Show()

            if not PetJournalPetCard.petIndex then
                PetJournalPetCard.petIndex = index
                PetJournalPetCard.petID, PetJournalPetCard.speciesID = C_PetJournal.GetPetInfoByIndex(index)
            end
            if PetJournalPetCard.petIndex == index then
                button.selected = true
                button.selectedTexture:Show()
            else
                button.selected = false
                button.selectedTexture:Hide()
            end

            if petID then
                local start, duration, enable = C_PetJournal.GetPetCooldownByGUID(button.petID)
                if (start) then
                    CooldownFrame_Set(button.dragButton.Cooldown, start, duration, enable)
                end
            end
        else
            button:Hide()
        end
    end

    HybridScrollFrame_Update(scrollFrame, numPets * 46, scrollFrame:GetHeight())
end

function PetPanel:TogglePetDropDown(index, anchor)
    local petID, speciesID = C_PetJournal.GetPetInfoByIndex(index)
    if petID then
        return PetJournal_ShowPetDropdown(index, anchor, 0, 0, petID)
    else
        GUI:ToggleMenu(anchor, self:GetPetMenuTable(speciesID), 20, 'TOPLEFT', anchor, 'BOTTOMLEFT')
    end
end

function PetPanel:GetPetMenuTable(speciesID)
    local menuTable = {
        {
            text = Profile:IsInPlan(COLLECT_TYPE_PET, speciesID) and L['取消计划任务'] or L['加入计划任务'],
            func = function()
                Profile:AddOrDelPlan(COLLECT_TYPE_PET, speciesID)
            end
        },
    }
    for i, v in ipairs(Pet:Get(speciesID):GetAchievementMenu()) do
        tinsert(menuTable, v)
    end
    tinsert(menuTable, { text = CANCEL })
    return menuTable
end

function PetPanel:UpdateDisplay()
    
    local card = PetJournalPetCard
    if card.speciesID then
        local plan = Plan:Get(COLLECT_TYPE_PET, card.speciesID)
        local pet = plan:GetObject()

        self.PlanButton:SetEnabled(not pet:IsCollected() and not pet:IsHideOnChar())
        self.PlanButton:SetText(pet:IsInPlan() and L['取消计划任务'] or L['加入计划任务'])

        self.Summary:SetPlan(plan)
        self.Map:SetPlan(plan)
        self.Feed:SetPlan(plan)

        self.InfoTab:EnablePanel(self.Map)
        self.InfoTab:EnablePanel(self.Summary)
        self.InfoTab:EnablePanel(self.Feed)

        if not card.petID and pet:GetProgressObject() then
            local color = pet:GetProgressColor()
            local progress = pet:GetProgressRate() * 100
            local name = pet:GetProgressName()

            self.CardProcessText:SetText(format('%s (%d%%)', name, progress))
            self.CardProcessBar:SetValue(progress)
            self.CardProcessBar:SetStatusBarColor(color.r, color.g, color.b)
            self.CardProcessBar:Show()
        else
            self.CardProcessBar:Hide()
        end
    else
        self.CardProcessBar:Hide()
        self.PlanButton:Disable()
        self.PlanButton:SetText(L['加入计划任务'])

        self.InfoTab:DisablePanel(self.Map)
        self.InfoTab:DisablePanel(self.Summary)
        self.InfoTab:DisablePanel(self.Feed)
    end
end

function PetPanel:UpdatePetIndex()
    if not self.selectSpeciesID then
        return
    end
    local numPets = PetFilter:GetNumPets()
    local petIndex = nil
    for i = 1, numPets do
        if self.selectSpeciesID == select(2, C_PetJournal.GetPetInfoByIndex(PetFilter:GetDisplayed(i))) then
            petIndex = i
            break
        end
    end
    if petIndex then
        PetJournalPetList_UpdateScrollPos(self.PetList, petIndex)
    end
    self.selectSpeciesID = nil
end

function PetPanel:SelectSpecies(_, speciesID)
    self.selectSpeciesID = speciesID
end

function PetPanel:ResetFilter()
    C_PetJournal.SetAllPetTypesChecked(true)
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true)
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, true)
    PetFilter:ResetFilterAndSort()
    self:Refresh()
end

function PetPanel:GetFilterMenuTable()
    if not self.menuTable then
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

        local function MakeFilterTypeMenuTable(filter, name)
            local menuTable = type(name) == 'table' and name or {
                text = name,
                keepShownOnClick = true,
                hasArrow = true,
                fontObject = function()
                    return PetFilter:IsAnyTypeFilterNotChecked(filter) and 'GameFontGreenSmall'
                end
            }

            menuTable.menuTable = {
                {
                    text = CHECK_ALL,
                    keepShownOnClick = true,
                    refreshParentOnClick = true,
                    func = function()
                        PetFilter:SetAllTypeFilterChecked(filter, true)
                    end
                },
                {

                    text = UNCHECK_ALL,
                    keepShownOnClick = true,
                    refreshParentOnClick = true,
                    func = function()
                        PetFilter:SetAllTypeFilterChecked(filter, false)
                    end
                },
                {
                    isSeparator = true,
                },
            }

            for _, v in ipairs(PET_JOURNAL_FILTER_TYPES[filter]) do
                tinsert(menuTable.menuTable, {
                    text = v.text,
                    keepShownOnClick = true,
                    refreshParentOnClick = true,
                    checkable = true,
                    isNotRadio = true,
                    checked = function()
                        return PetFilter:IsTypeFilterChecked(filter, v.id)
                    end,
                    func = function(_,_,_,checked)
                        PetFilter:SetTypeFilterChecked(filter, v.id, checked)
                    end,
                })
            end

            return menuTable
        end

        self.menuTable = {
            {
                text = COLLECTED,
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED)
                end,
                func = function(_,_,_,value)
                    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, value)
                end,
            },
            {
                text = NOT_COLLECTED,
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED)
                end,
                func = function(_,_,_,value)
                    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value)
                end,
            },
            {
                isSeparator = true,
            },
            {
                text = L['过滤器'],
                isTitle = true,
            },
            {
                text = L['仅当前区域'],
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return PetFilter:IsOnlyCurrentArea()
                end,
                func = function(_,_,_,value)
                    PetFilter:SetOnlyCurrentArea(value)
                end
            },
            MakeBlizzardFilter(
                PET_FAMILIES,
                C_PetJournal.SetAllPetTypesChecked,
                C_PetJournal.GetNumPetTypes,
                C_PetJournal.SetPetTypeFilter,
                C_PetJournal.IsPetTypeChecked,
                'BATTLE_PET_NAME_'
            ),
            MakeBlizzardFilter(
                SOURCES,
                C_PetJournal.SetAllPetSourcesChecked,
                C_PetJournal.GetNumPetSources,
                C_PetJournal.SetPetSourceChecked,
                C_PetJournal.IsPetSourceChecked,
                'BATTLE_PET_SOURCE_'
            ),
            -- MakeFilterTypeMenuTable('PetType', PET_FAMILIES),
            -- MakeFilterTypeMenuTable('Source', SOURCES),
            MakeFilterTypeMenuTable('LevelRange', LEVEL),
            MakeFilterTypeMenuTable('Quality', QUALITY),
            MakeFilterTypeMenuTable('Ability', L['技能']),
            MakeFilterTypeMenuTable('Trade', L['交易']),
            MakeFilterTypeMenuTable('Battle', L['战斗']),
            {
                isSeparator = true,
            },
            {
                text = RAID_FRAME_SORT_LABEL,
                keepShownOnClick = true,
                hasArrow = true,
                menuTable = {
                    {
                        text = NAME,
                        checkable = true,
                        keepShownOnClick = true,
                        checked = function()
                            return C_PetJournal.GetPetSortParameter() == LE_SORT_BY_NAME
                        end,
                        func = function()
                            C_PetJournal.SetPetSortParameter(LE_SORT_BY_NAME)
                            self:Refresh()
                        end,
                    },
                    {
                        text = LEVEL,
                        checkable = true,
                        keepShownOnClick = true,
                        checked = function()
                            return C_PetJournal.GetPetSortParameter() == LE_SORT_BY_LEVEL
                        end,
                        func = function()
                            C_PetJournal.SetPetSortParameter(LE_SORT_BY_LEVEL)
                            self:Refresh()
                        end,
                    },
                    {
                        text = RARITY,
                        checkable = true,
                        keepShownOnClick = true,
                        checked = function()
                            return C_PetJournal.GetPetSortParameter() == LE_SORT_BY_RARITY
                        end,
                        func = function()
                            C_PetJournal.SetPetSortParameter(LE_SORT_BY_RARITY)
                            self:Refresh()
                        end,
                    },
                    {
                        text = TYPE,
                        checkable = true,
                        keepShownOnClick = true,
                        checked = function()
                            return C_PetJournal.GetPetSortParameter() == LE_SORT_BY_PETTYPE
                        end,
                        func = function()
                            C_PetJournal.SetPetSortParameter(LE_SORT_BY_PETTYPE)
                            self:Refresh()
                        end,
                    },
                    {
                        isSeparator = true,
                    },
                    -- {
                    --     text = L['偏好置顶'],
                    --     keepShownOnClick = true,
                    --     refreshParentOnClick = true,
                    --     checkable = true,
                    --     isNotRadio = true,
                    --     checked = function()
                    --         return PetFilter:IsFavoriteAtTop()
                    --     end,
                    --     func = function(_,_,_,checked)
                    --         PetFilter:SetFavoriteAtTop(checked)
                    --     end
                    -- },
                    {
                        text = L['计划置顶'],
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        checkable = true,
                        isNotRadio = true,
                        checked = function()
                            return PetFilter:IsPlanAtTop()
                        end,
                        func = function(_,_,_,checked)
                            PetFilter:SetPlanAtTop(checked)
                        end
                    },
                    {
                        text = L['新收集置顶'],
                        keepShownOnClick = true,
                        refreshParentOnClick = true,
                        checkable = true,
                        isNotRadio = true,
                        checked = function()
                            return PetFilter:IsNewAtTop()
                        end,
                        func = function(_,_,_,checked)
                            PetFilter:SetNewAtTop(checked)
                        end
                    },
                }
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
