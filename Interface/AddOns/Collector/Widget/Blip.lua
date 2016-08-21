
BuildEnv(...)

local Blip = Addon:NewClass('Blip', 'Button')

function Blip:Constructor()
    self.icon = self:CreateTexture(nil, 'ARTWORK')
    self.icon:SetAllPoints(true)
end

function Blip:SetIcon(icon, left, right, top, bottom)
    self.icon:SetTexture(icon)
    self.icon:SetTexCoord(left or 0, right or 1, top or 0, bottom or 1)
end

function Blip:SetObject(object, item)
    self.object = object

    self:SetIcon((item or object):GetBlipIcon())
end

function Blip:GetObject()
    return self.object
end
