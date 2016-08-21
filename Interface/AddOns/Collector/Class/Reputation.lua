
BuildEnv(...)

Reputation = Addon:NewClass('Reputation', Object)

local REPUTATION_SUM = {} do
    local base = {0,36000,3000,3000,3000,6000,12000,21000,}
    local function sum(t, s, e)
        local value = 0
        for i = s, e do
            value = value + t[i]
        end
        return value
    end

    REPUTATION_SUM.CanWar = {}
    REPUTATION_SUM.Normal = {}

    for i = 1, 8 do
        REPUTATION_SUM.CanWar[i] = sum(base, 1, i)
        REPUTATION_SUM.Normal[i] = sum(base, 5, i)
    end
end

function Reputation:Constructor(id)
    self.id = id
end

function Reputation:GetID()
    return self.id
end

function Reputation:GetStanding()
    return (select(3, GetFactionInfoByID(self.id)))
end

function Reputation:GetProgressRate(standing)
    local _, _, currentStanding, minRep, _, rep = GetFactionInfoByID(self.id)
    local rate

    if self:IsFriendShip() then
        local _, friendRep, _, _, _, _, _, friendThreshold, nextFriendThreshold = GetFriendshipReputation(self.id)
        if not nextFriendThreshold then
            return 1
        else
            local levelad = nextFriendThreshold - friendThreshold
            rate = (friendRep % levelad + levelad * (currentStanding - 1)) / (levelad * (standing - 1))
        end
    else
        local sumTbl = REPUTATION_SUM[self:GetReputationType()]

        rate = (rep - minRep + sumTbl[currentStanding]) / sumTbl[standing]
    end
    return rate > 1 and 1 or rate < 0 and 0 or rate
end

function Reputation:GetStandingColor()
    return FACTION_BAR_COLORS[self:IsFriendShip() and 5 or self:GetStanding()]
end

function Reputation.Once:GetReputationType()
    return self:IsCanAtWar() and 'CanWar' or 'Normal'
end

function Reputation.Once:GetName()
    return (GetFactionInfoByID(self.id))
end

function Reputation.Once:IsFriendShip()
    return not not GetFriendshipReputation(self.id)
end

function Reputation.Once:IsCanAtWar()
    local atWar, canToggle = select(7, GetFactionInfoByID(self.id))
    return atWar or canToggle
end
