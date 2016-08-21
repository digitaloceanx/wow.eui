
BuildEnv(...)

Object = Addon:NewClass('Object')

Object._Meta.__lt = function(a, b)
    return a:GetToken() < b:GetToken()
end

Object._Meta.__le = function(a, b)
    return a:GetToken() <= b:GetToken()
end

function Object:Constructor(...)
    local class = self:GetType()

    class.Objects = class.Objects or {}
    class.Objects[self:GetToken(...)] = self

    self._Once = {}
    self.token = self:GetToken(...)
end

local OnceMeta = {
    __newindex = function(t, k, v)
        t.class[k] = function(self)
            if self._Once[k] == nil then
                self._Once[k] = v(self)
            end
            return self._Once[k]
        end
    end
}

function Object:Inherit()
    self.Once = setmetatable({class = self}, OnceMeta)
end

function Object:GetToken(id)
    return self.token or id
end

function Object:Get(...)
    return self.Objects and self.Objects[self:GetToken(...)] or self:GetType():New(...)
end

function Object:GetByToken(token)
    return self.Objects and self.Objects[token]
end

function Object:Release()
    if self.Objects then
        tDeleteItem(self.Objects, self)
    end
end

function Object:IterateObjects()
    if self.Objects then
        return pairs(self.Objects)
    else
        return nop
    end
end
