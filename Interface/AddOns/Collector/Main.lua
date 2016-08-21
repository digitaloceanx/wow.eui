
BuildEnv(...)

GUI = LibStub('NetEaseGUI-2.0')

Addon = LibStub('AceAddon-3.0'):NewAddon('Collector', 'AceEvent-3.0', 'LibModule-1.0', 'LibClass-2.0', 'AceHook-3.0')
Addon:SetDefaultModuleState(false)

function Addon:OnInitialize()
    self.petCollectedCache = {}
    self.petGUIDCollectedCache = {}
    self.newPetCache = {}

    self:RegisterEvent('FRIENDLIST_UPDATE')
    self:RegisterEvent('ZONE_CHANGED')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'ZONE_CHANGED')

    self:RegisterEvent('ADDON_LOADED')

    self:HookScript(WorldMapFrame, 'OnHide', 'ZONE_CHANGED')
    self:RegisterMessage('COLLECTOR_SETTING_UPDATE')


    do
        local searchFilter

        self:SecureHook(C_PetJournal, 'SetSearchFilter', function(text)
            searchFilter = text
        end)
        self:SecureHook(C_PetJournal, 'ClearSearchFilter', function()
            searchFilter = nil
        end)

        local PickupPet = C_PetJournal.PickupPet
        function C_PetJournal.PickupPet(id)
            if InCombatLockdown() then
                C_Timer.After(0, function()
                    for i = 1, 3 do
                        PetJournal.Loadout['Pet'..i].setButton:Hide()
                    end
                end)
                return
            end
            PickupPet(id)
        end

        function C_PetJournal.GetSearchFilter()
            return searchFilter or ''
        end
    end
end

function Addon:OnEnable()
    self:ZONE_CHANGED()
    CollectionsJournal_LoadUI()

    local laters = {
        MountPanel = true,
        PetPanel = true,
        PlanPanel = true,
        Objectives = true,
    }

    for module in self:IterateModules() do
        if not laters[module] then
            self:EnableModule(module)
        end
    end
end

function Addon:ADDON_LOADED(_, addon)
    if addon ~= 'Blizzard_Collections' then
        return
    end
    self:EnableModule('MountPanel')
    self:EnableModule('PetPanel')
    C_Timer.After(0, function()
        self:EnableModule('PlanPanel')
    end)
end

function Addon:COLLECTOR_SETTING_UPDATE(_, key, value)
    if key == 'objectives' then
        if value then
            self:EnableModule('Objectives')
        else
            self:DisableModule('Objectives')
        end
    end
end

function Addon:FRIENDLIST_UPDATE()
    wipe(WOW_FRIEND_NAME_TO_INDEX)
    for i = 1, GetNumFriends() do
        WOW_FRIEND_NAME_TO_INDEX[GetFriendInfo(i)] = i
    end
end

function Addon:ZONE_CHANGED()
    if self:UpdateCurrentArea() then
        self:SendMessage('COLLECTOR_AREA_CHANGED')
    end
end

function Addon:UpdateCurrentArea()
    if WorldMapFrame:IsShown() then
        return false
    end

    SetMapToCurrentZone()

    local area = self.area
    self.area = Area:Get(self:GetCurrentAreaInfo())
    return self.area ~= area
end

function Addon:TogglePlanPanel(plan)
    -- CollectionsJournal_LoadUI()
    PlanPanel:Toggle(plan)
end

function Addon:ToggleAchievement(achievement)
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end 
    if not AchievementFrame:IsShown() then
        AchievementFrame_ToggleAchievementFrame(false, achievement:IsGuild())
    end
    AchievementFrame_SelectAchievement(achievement:GetID())
end

function Addon:ToggleWorldMap(area)
    ShowUIPanel(WorldMapFrame)
    SetMapByID(area:GetMapID())
    SetDungeonMapLevel(area:GetLevel() + (DungeonUsesTerrainMap() and 1 or 0))
end

function Addon:ToggleMountJournal(mount)
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage(L['不能在战斗中这样做'], 1, 0, 0)
    else
        HideUIPanel(WorldMapFrame)
        ShowUIPanel(CollectionsJournal)
        CollectionsJournal_SetTab(CollectionsJournal, 1)
        MountPanel:SelectMount(mount)
    end
end

function Addon:TogglePetJournal(pet)
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage(L['不能在战斗中这样做'], 1, 0, 0)
    else
        HideUIPanel(WorldMapFrame)
        ShowUIPanel(CollectionsJournal)
        CollectionsJournal_SetTab(CollectionsJournal, 2)
        PetJournal_SelectSpecies(PetJournal, pet:GetID())
    end
end

function Addon:ToggleObjectPanel(object)
    -- body
end

function Addon:GetCurrentAreaInfo()
    local map = select(2, GetAreaMapInfo(GetCurrentMapAreaID()))
    local lvl = GetCurrentMapDungeonLevel()
    if DungeonUsesTerrainMap() then
        lvl = lvl - 1
    end
    return map, lvl
end

function Addon:GetCurrentAreaToken()
    return self:GetAreaToken(self:GetCurrentAreaInfo())
end

function Addon:GetAreaToken(map, lvl)
    return format('%s:%d', map, lvl)
end

function Addon:GetCollectTypeClass(collectType)
    if collectType == COLLECT_TYPE_MOUNT then
        return Mount
    elseif collectType == COLLECT_TYPE_PET then
        return Pet
    end
end

function Addon:IsFriend(target)
    return WOW_FRIEND_NAME_TO_INDEX[target]
end

function Addon:MakeChatMessage(event, ...)
    for i, v in ipairs(CHAT_FRAMES) do
        local frame = _G[v]
        local script = frame:IsEventRegistered(event) and frame:GetScript('OnEvent')
        if script then
            script(frame, event, ...)
        end
    end 
end
