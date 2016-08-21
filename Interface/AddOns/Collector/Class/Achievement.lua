
BuildEnv(...)

Achievement = Addon:NewClass('Achievement', Object)

function Achievement:Constructor(id)
    self.id = id
end

function Achievement:GetID()
    return self.id
end

function Achievement.Once:GetName()
    return (select(2, GetAchievementInfo(self.id)))
end

function Achievement.Once:IsGuild()
    return select(12, GetAchievementInfo(self.id)) or false
end

function Achievement.Once:IsCompleted()
    return select(4, GetAchievementInfo(self.id)) or nil
end

function Achievement:GetProgressRate()
    if self:IsCompleted() then
        return 1
    end

    local numCriteria = GetAchievementNumCriteria(self.id)
    if not numCriteria or numCriteria == 0 then
        return 0
    end
    
    local count, total = 0, 0
    for i = 1, numCriteria do
        local _, type, completed, quantity, requiredQuantity, _, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(self.id, i)
        if requiredQuantity == 0 then
            requiredQuantity = 1
            quantity = completed and 1 or 0
        end

        count = count + quantity
        total = total + requiredQuantity
    end
    local rate = count / total

    return rate > 1 and 1 or rate < 0 and 0 or rate
end

function Achievement:TogglePanel()
    Addon:ToggleAchievement(self)
end

function Achievement.Once:GetAchievementMenu()
    return {
        text = self:GetName(),
        func = function()
            self:TogglePanel()
        end,
    }
end

function Achievement.Once:GetTrackMenu()
    return {
        text = self:GetName(),
        func = function()
            AddTrackedAchievement(self:GetID())
        end,
    }
end
