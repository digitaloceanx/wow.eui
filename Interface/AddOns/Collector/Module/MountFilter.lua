--[[
@Date    : 2016-07-26 11:48:39
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]


BuildEnv(...)

MountFilter = Addon:NewModule(Filter:New(MOUNT_JOURNAL_FILTER_TYPES), 'MountFilter', 'AceEvent-3.0', 'AceHook-3.0')

function MountFilter:OnInitialize()
    self.displayedCache = {}
    self.collectedCache = {}
    self.mountCache = {}
end

function MountFilter:OnEnable()
    self:UpdateCache()

    self:RegisterEvent('COMPANION_LEARNED', 'UpdateCollected')
    self:RegisterEvent('COMPANION_UNLEARNED', 'UpdateCollected')
    self:RegisterEvent('MOUNT_JOURNAL_SEARCH_UPDATED', 'Refresh')
    self:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', 'Refresh')

    self:RegisterMessage('COLLECTOR_PLANLIST_UPDATE', 'Refresh')

    self:ResetFilterAndSort()
    self:Refresh()
end

---- Cache

function MountFilter:GetNumDisplayedMounts()
    return #self.displayedCache
end

function MountFilter:MakeSortValue(mount, isCollected, isFavorite, inPlan)
    local key1 do
        if self:IsNewAtTop() and mount:NeedsFanfare() then
            key1 = 1
        elseif self:IsFavoriteAtTop() and isFavorite then
            key1 = 2
        elseif isCollected then
            key1 = 3
        elseif self:IsPlanAtTop() and inPlan then
            key1 = 4
        else
            key1 = 99
        end
    end

    local key2 do
        local sortKey = self:GetSortKey()
        if sortKey == 'Name' then
            key2 = 0
        elseif sortKey == 'Progress' then
            key2 = 999 - (mount:GetProgressRate() or -1) * 100
        elseif sortKey == 'Model' then
            key2 = MODEL_SORT_ORDER[mount:GetAttribute('Model')] or 99
        else
            key2 = mount:GetAttribute(sortKey)
        end
    end
    return format('%02d%04d%s', key1, key2, mount:GetName())
end

function MountFilter:MatchMount(mount, isCollected, isFavorite, inPlan)
    local searchString = self.searchString
    if searchString and searchString ~= '' then
        return strfind(mount:GetName(), searchString, 1, true)
    end
    if self:IsOnlyCurrentArea() then
        return mount:IsInCurrentArea()
    end
    -- if isCollected then
    --     if isFavorite and not self:IsTypeFilterChecked('Favorite', 1) then
    --         return false
    --     end
    --     if not isFavorite and not self:IsTypeFilterChecked('Favorite', 2) then
    --         return false
    --     end
    -- else
    --     if inPlan and not self:IsTypeFilterChecked('Plan', 1) then
    --         return false
    --     end
    --     if not inPlan and not self:IsTypeFilterChecked('Plan', 2) then
    --         return false
    --     end
    -- end

    for filter in pairs(MOUNT_JOURNAL_FILTER_TYPES) do
        local attr = mount:GetAttribute(filter)
        if attr and not self:IsTypeFilterChecked(filter, attr) then
            return false
        end
    end
    return true
end

function MountFilter:GetDisplayed(index)
    return self.displayedCache[index]
end

function MountFilter:GetRealIndex(mount)
    return self.displayedIndex[mount:GetID()]
end

function MountFilter:Refresh()
    if not MountJournal or not MountJournal:IsVisible() then
        return
    end
    self:UpdateDisplayed()
    self:SendMessage('COLLECTOR_MOUNT_LIST_UPDATED')
end

function MountFilter:IterateMounts()
    
    return ipairs(self.mountCache)
end

function MountFilter:UpdateDisplayed()
    
    if self:IsOnlyCurrentArea() then
        SetMapToCurrentZone()
    end

    local displayedCache = {}
    local sortVal = {}
    local numOwned = 0

    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
        local id = select(2, C_MountJournal.GetDisplayedMountInfo(i))
        local mount = Mount:Get(id)

        local hideOnChar, isCollected, isFavorite, inPlan = mount:GetStat()
        if not hideOnChar or IsGMClient() then
            if self:MatchMount(mount, isCollected, isFavorite, inPlan) then
                tinsert(displayedCache, i)

                sortVal[i] = self:MakeSortValue(mount, isCollected, isFavorite, inPlan)
            end
        end
    end

    table.sort(displayedCache, function(a, b)
        return sortVal[a] < sortVal[b]
    end)
    self.displayedCache = displayedCache
end

function MountFilter:UpdateCache()
    for _, i in ipairs(C_MountJournal.GetMountIDs()) do
        local name, id, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(i)
        local mount = Mount:Get(id, i)
        mount:SetMountID(i)
        tinsert(self.mountCache, mount)

        self.collectedCache[id] = isCollected or nil
    end
    self:SendMessage('COLLECTOR_MOUNT_CACHED', self.mountCache)
end

function MountFilter:UpdateCollected()
    for _, mount in ipairs(self.mountCache) do
        if mount:IsCollected() then
            if not self.collectedCache[mount:GetID()] then
                mount:SetIsNew(true)
                Profile:DelPlan(COLLECT_TYPE_MOUNT, mount:GetID())

                self.collectedCache[mount:GetID()] = true
                self:SendMessage('COLLECTOR_LEARNED', COLLECT_TYPE_MOUNT, mount:GetID())
            end
        else
            self.collectedCache[mount:GetID()] = nil
        end
    end
    self:Refresh()
end

function MountFilter:GetMountCount()
    local count = 0
    for k, v in pairs(self.collectedCache) do
        count = count + 1
    end
    return count
end
