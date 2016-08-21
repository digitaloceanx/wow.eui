
BuildEnv(...)

Area = Addon:NewClass('Area', Object)

function Area:Constructor(id, level)
    self.id = id
    self.level = level
end

function Area:GetID()
    return self.id
end

function Area:GetLevel()
    return self.level
end

function Area:GetMapID()
    return MAP_FILE_TO_ID[self.id]
end

function Area:IsGarrsion()
    return IsMapGarrisonMap(self:GetMapID())
end

function Area:GetToken(id, level)
    return self.token or format('%d:%d', id or self.id, level or self.level)
end

function Area.Once:GetNpcList()
    local list = {}
    local token = self:GetToken()
    for id, v in pairs(NPC_DATA) do
        if v.Coords and v.Coords[token] then
            tinsert(list, Npc:Get(id))
        end
    end
    return list
end

function Area.Once:GetGameObjectList()
    local list = {}
    local token = self:GetToken()
    for id, v in pairs(OBJECT_DATA) do
        if v.Coords and v.Coords[token] then
            tinsert(list, GameObject:Get(id))
        end
    end
    return list
end

function Area:GetName()
    SetMapByID(self:GetMapID())
    SetDungeonMapLevel(self.level + (DungeonUsesTerrainMap() and 1 or 0))

    local name = GetMapNameByID(self:GetMapID())
    local levelName = _G['DUNGEON_FLOOR_' .. strupper(GetMapInfo() or '') .. self.level]

    return levelName and levelName ~= name and name .. '-' .. levelName or name
end

function Area:GetNotCollectedCount()
    local exists = {}
    local counts = {}

    for _, object in ipairs(self:GetGameObjectList()) do
        for _, item in ipairs(object:GetDropList()) do
            if not exists[item] and not item:IsCollected() and not item:IsHideOnChar() then
                local klass = item:GetType()
                exists[item] = true
                counts[klass] = (counts[klass] or 0) + 1
            end
        end
    end

    for _, object in ipairs(self:GetNpcList()) do
        for _, item in ipairs(object:GetDropList()) do
            if not exists[item] and not item:IsCollected() and not item:IsHideOnChar() then
                local klass = item:GetType()
                exists[item] = true
                counts[klass] = (counts[klass] or 0) + 1
            end
        end

        for _, item in ipairs(object:GetSoldList()) do
            if not exists[item] and not item:IsCollected() and not item:IsHideOnChar() then
                local klass = item:GetType()
                exists[item] = true
                counts[klass] = (counts[klass] or 0) + 1
            end
        end
    end
    return counts[Mount] or 0, counts[Pet] or 0
end
