
BuildEnv(...)

Npc = Addon:NewClass('Npc', GameObject)
Npc.DB = NPC_DATA
Npc.DROP_PREFIX = 'drop:'

function Npc:HasAnyItem()
    return #self:GetSoldList() > 0 or #self:GetDropList() > 0
end

function Npc:HasNotCollectedItem(klasses)
    for i, item in ipairs(self:GetSoldList()) do
        if (not klasses or klasses[item:GetCollectType()]) and not item:IsCollected() and item:IsValid() then
            return true
        end
    end
    return self:SuperCall('HasNotCollectedItem', klasses)
end

function Npc.Once:GetSoldList()
    return GetDropList('sold:', self.id)
end

function Npc:HasItem(item)
    return tContains(self:GetSoldList(), item) or self:SuperCall('HasItem', item)
end

function Npc:GetDisplay()
    return self.DB[self.id].Display
end

function Npc:GetBlipIcon()
    for _, item in ipairs(self:GetSoldList()) do
        if item:IsBlipValid() then
            return item:GetBlipIcon()
        end
    end
    return self:SuperCall('GetBlipIcon')
end
