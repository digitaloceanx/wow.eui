
BuildEnv(...)

GameObject = Addon:NewClass('GameObject', Object)
GameObject.DB = OBJECT_DATA
GameObject.DROP_PREFIX = 'object:'

function GameObject:Constructor(id)
    self.id = id
    self.data = self.DB[id] or {}
end

function GameObject:GetDisplay()
    return self.data.Display
end

function GameObject:GetID()
    return self.id
end

function GameObject:IsInArea(map, lvl)
    return not not self:GetAreaCoords(map, lvl)
end

function GameObject:IsInCurrentArea()
    return self:IsInArea(self:GetCurrentAreaInfo())
end

function GameObject:GetAreaCoords(map, lvl)
    return self.data.Coords and self.data.Coords[Addon:GetAreaToken(map, lvl)]
end

function GameObject:GetCurrentAreaCoords()
    return self:GetAreaCoords(Addon:GetCurrentAreaInfo())
end

function GameObject:HasAnyItem()
    return #self:GetDropList() > 0
end

function GameObject:HasNotCollectedItem(klasses)
    for i, item in ipairs(self:GetDropList()) do
        if (not klasses or klasses[item:GetCollectType()]) and not item:IsCollected() and item:IsValid() then
            return true
        end
    end
end

function GameObject:HasItem(item)
    return tContains(self:GetDropList(), item)
end

function GameObject:GetBlipIcon()
    for _, item in ipairs(self:GetDropList()) do
        if item:IsBlipValid() then
            return item:GetBlipIcon()
        end
    end
end

function GameObject.Once:GetDropList()
    return GetDropList(self.DROP_PREFIX, self.id)
end

function GameObject.Once:GetAreaList()
    local results = {}
    if self.data.Coords then
        for k in pairs(self.data.Coords) do
            local map, lvl = k:match('^(%d+):(%d+)$')

            tinsert(results, Area:Get(tonumber(map), tonumber(lvl)))
        end
    end
    sort(results)
    return results
end

function GameObject:GetDisplay()
    -- return self.DB[self.id].Display
    return nil
end

function GameObject:GetName()
    return self.DB[self.id].Name
end
