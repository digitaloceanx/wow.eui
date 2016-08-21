--[[
@Date    : 2016-07-27 11:58:10
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]

BuildEnv(...)

Filter = Addon:NewClass('Filter')

function Filter:Constructor(filterGroups)
    self.filterChecked = {}
    self.favoriteAtTop = true
    self.planAtTop = true
    self.newAtTop = true
    self.onlyCurrentArea = false
    self.searchString = ''
    self.sortKey = 'Name'
    self.filterGroups = filterGroups

    self.filterBitCache = setmetatable({}, {__index = function(t, filter)
        local b = 0 do
            for id in pairs(self.filterChecked[filter]) do
                b = bit.bor(b, bit.lshift(1, id - 1))
            end
        end
        t[filter] = b
        return b
    end})
end

---- TypeFilter

function Filter:IsBitFilter(filter)
    return self.filterGroups[filter].isBit
end

function Filter:SetTypeFilterChecked(filter, id, checked)
    self.filterChecked[filter][id] = checked or nil
    self.filterBitCache[filter] = nil
    self:Refresh()
end

function Filter:IsTypeFilterChecked(filter, id, noRaw)
    if noRaw and self:IsBitFilter(filter) then
        return bit.band(self.filterBitCache[filter], id) > 0
    else
        return self.filterChecked[filter][id]
    end
end

function Filter:SetAllTypeFilterChecked(filter, checked)
    if checked then
        for _, v in ipairs(self.filterGroups[filter]) do
            self.filterChecked[filter][v.id] = true
        end
    else
        wipe(self.filterChecked[filter])
    end
    self.filterBitCache[filter] = nil
    self:Refresh()
end

function Filter:IsAnyTypeFilterChecked(filter)
    return next(self.filterChecked[filter])
end

function Filter:IsAnyTypeFilterNotChecked(filter)
    for _, v in ipairs(self.filterGroups[filter]) do
        if not self.filterChecked[filter][v.id] then
            return true
        end
    end
end

---- Sort

function Filter:SetFavoriteAtTop(flag)
    self.favoriteAtTop = flag or nil
    self:Refresh()
end

function Filter:IsFavoriteAtTop()
    return self.favoriteAtTop
end

function Filter:SetPlanAtTop(flag)
    self.planAtTop = flag or nil
    self:Refresh()
end

function Filter:IsPlanAtTop()
    return self.planAtTop
end

function Filter:SetNewAtTop(flag)
    self.newAtTop = flag or nil
    self:Refresh()
end

function Filter:IsNewAtTop()
    return self.newAtTop
end

function Filter:SetOnlyCurrentArea(flag)
    self.onlyCurrentArea = flag
    self:Refresh()
end

function Filter:IsOnlyCurrentArea()
    return self.onlyCurrentArea
end

function Filter:SetSortKey(key)
    self.sortKey = key
    self:Refresh()
end

function Filter:GetSortKey()
    return self.sortKey
end

---- Reset

function Filter:ResetFilterAndSort()
    for k, v in pairs(self.filterGroups) do
        self.filterChecked[k] = {}
        for _, v in ipairs(v) do
            self.filterChecked[k][v.id] = true
        end
    end
    self.favoriteAtTop = true
    self.planAtTop = true
    self.newAtTop = true
    self.onlyCurrentArea = false
    self.sortKey = 'Name'
    self:Refresh()
end

---- Virtual

function Filter:Refresh()
    error([[Refresh not define]], 1)
end
