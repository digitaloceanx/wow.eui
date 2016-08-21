--[[
@Date    : 2016-07-26 16:10:55
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]


BuildEnv(...)

local PetGUID = {}

PetFilter = Addon:NewModule(Filter:New(PET_JOURNAL_FILTER_TYPES), 'PetFilter', 'AceEvent-3.0', 'AceHook-3.0')

function PetFilter:OnInitialize()
    self.displayedCache = {}
    self.collectedCache = {}
    self.collectedGuidCache = {}
    self.newPetCache = {}
    self.petCache = {}
end

function PetFilter:OnEnable()
    self:RegisterEvent('PET_JOURNAL_PET_DELETED', 'Refresh')
    self:RegisterMessage('COLLECTOR_PLANLIST_UPDATE', 'Refresh')

    self:RegisterEvent('COMPANION_UPDATE', function(_, companionType)
        if companionType == 'CRITTER' then
            self:Refresh()
        end
    end)

    self:RegisterEvent('PET_JOURNAL_LIST_UPDATE', function()
        local numPets, numCollected = C_PetJournal.GetNumPets()
        if numPets == 0 then
            return
        end
        if numCollected == 0 then
            
            return self:Refresh()
        end
        
        self:Refresh()
        self:UpdateCollected(true)
        self:RegisterEvent('PET_JOURNAL_LIST_UPDATE')
    end)

    self:ResetBlizzardFilter()
    self:ResetFilterAndSort()
end

function PetFilter:PET_JOURNAL_LIST_UPDATE()
    self:UpdateCollected()
    self:Refresh()
end

function PetFilter:Refresh()
    if not PetJournal or not PetJournal:IsVisible() then
        return
    end
    self:UpdateDisplayed()
    self:SendMessage('COLLECTOR_PET_LIST_UPDATED')
end

---- Cache

function PetFilter:ResetBlizzardFilter()
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true)
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, true)
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetAllPetTypesChecked(true)
    C_PetJournal.SetAllPetSourcesChecked(true)
end

function PetFilter:GetNumPets()
    return #self.displayedCache
end

function PetFilter:GetDisplayed(index)
    return self.displayedCache[index]
end

function PetFilter:UpdateCache()
end

function PetFilter:UpdateDisplayed()
    if self:IsOnlyCurrentArea() then
        SetMapToCurrentZone()
    end

    local displayedCache = {}
    local sortVal = {}

    for i = 1, C_PetJournal.GetNumPets() do
        local petID, speciesID, isOwned, customName, level, isFavorite, isRevoked, name, icon, petType, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(i)

        local pet = Pet:Get(speciesID)

        if self:MatchPet(petID, speciesID, isOwned, isFavorite) then
            tinsert(displayedCache, i)

            sortVal[i] = self:MakeSortValue(pet, isOwned, isFavorite, false)
        end
    end

    table.sort(displayedCache, function(a, b)
        if sortVal[a] == sortVal[b] then
            return a < b
        end
        return sortVal[a] < sortVal[b]
    end)

    self.displayedCache = displayedCache
end

function PetFilter:UpdateCollected(firstPetCache)
    local search = C_PetJournal.GetSearchFilter()
    local collect = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED)
    local notCollect = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED)
    local petTypeFilters = {} do
        for i = 1, C_PetJournal.GetNumPetTypes() do
            petTypeFilters[i] = C_PetJournal.IsPetTypeChecked(i)
        end
    end
    local petSourceFilters = {} do
        for i = 1, C_PetJournal.GetNumPetSources() do
            petSourceFilters[i] = C_PetJournal.IsPetSourceChecked(i)
        end
    end

    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true)
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, true)
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetAllPetTypesChecked(true)
    C_PetJournal.SetAllPetSourcesChecked(true)

    local old = self.collectedGuidCache
    local new = {}
    

    if C_PetJournal.GetNumPets() == 0 then
        return
    end

    for i = 1, C_PetJournal.GetNumPets() do
        local petID, speciesID, isOwned = C_PetJournal.GetPetInfoByIndex(i)

        if isOwned then
            Profile:DelPlan(COLLECT_TYPE_PET, speciesID)

            if not firstPetCache and not old[petID] then
                self.newPetCache[petID] = true
                self:SendMessage('COLLECTOR_LEARNED', COLLECT_TYPE_PET, speciesID, petID)
            end
            new[petID] = true
        end

        if firstPetCache then
            tinsert(self.petCache, Pet:Get(speciesID))
        end

        self.collectedCache[speciesID] = isOwned or nil
    end
    self.collectedGuidCache = new

    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, collect)
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, notCollect)
    C_PetJournal.SetSearchFilter(search)

    for i, v in ipairs(petTypeFilters) do
        C_PetJournal.SetPetTypeFilter(i, v)
    end
    for i, v in ipairs(petSourceFilters) do
        C_PetJournal.SetPetSourceChecked(i, v)
    end

    if firstPetCache then
        self:SendMessage('COLLECTOR_PET_CACHED', self.petCache)
    end
    
    return true
end

function PetFilter:MakeSortValue(pet, isCollected, isFavorite, isNew)
    local key1 do
        if self:IsNewAtTop() and isNew then
            key1 = 1
        elseif self:IsFavoriteAtTop() and isFavorite then
            key1 = 2
        elseif isCollected then
            key1 = 3
        elseif self:IsPlanAtTop() and pet:IsInPlan() then
            key1 = 4
        else
            key1 = 99
        end
    end
    return key1
end

function PetFilter:MatchPet(petID, speciesID, isFavorite, inPlan)
    if self:IsOnlyCurrentArea() and not Pet:Get(speciesID):IsInCurrentArea() then
        return false
    end
    for filter, v in pairs(PET_JOURNAL_FILTER_TYPES) do
        if v.isOwned and petID and not self:IsTypeFilterChecked(filter, self:GetPetAttr(filter, petID, speciesID), true) then
            return false
        end
        if not v.isOwned and not self:IsTypeFilterChecked(filter, self:GetPetAttr(filter, petID, speciesID), true) then
            return false
        end
    end
    return true
end

function PetFilter:GetPetAttr(attr, petID, speciesID)
    return PetGUID[attr](petID, speciesID)
end

function PetFilter:IsPetCollected(speciesID)
    return self.collectedCache[speciesID]
end

---- PetGUID

function PetGUID.LevelRange(petID)
    local _, _, level = C_PetJournal.GetPetInfoByPetID(petID)
    if level == 1 then
        return 1
    elseif level <= 10 then
        return 2
    elseif level <= 20 then
        return 3
    elseif level <= 24 then
        return 4
    else
        return 5
    end
end

function PetGUID.Quality(petID)
    return select(5, C_PetJournal.GetPetStats(petID))
end

function PetGUID.Ability(petID, speciesID)
    return Pet:Get(speciesID):GetAbility()
end

function PetGUID.Trade(petID, speciesID)
    return Pet:Get(speciesID):IsTradable() and 1 or 2
end

function PetGUID.Battle(petID, speciesID)
    return Pet:Get(speciesID):IsCanBattle() and 1 or 2
end
