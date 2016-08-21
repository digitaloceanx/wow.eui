
BuildEnv(...)

Plan = Addon:NewClass('Plan', Object)

function Plan:Constructor(collectType, id)
    self.collectType = collectType
    self.id = id
end

function Plan:GetToken(collectType, id)
    return self.token or format('%d:%d', collectType, id)
end

function Plan:GetCollectType()
    return self.collectType
end

function Plan:GetID()
    return self.id
end

function Plan:GetObject()
    return Addon:GetCollectTypeClass(self.collectType):Get(self.id)
end
