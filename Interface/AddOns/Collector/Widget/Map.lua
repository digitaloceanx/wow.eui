
BuildEnv(...)

Map = Addon:NewClass('Map', 'Frame')

Map.x = 0
Map.y = 0

GUI:Embed(Map, 'Refresh')

function Map:Constructor()
    self.activeBlips = {}
    self.freeBlips = {}
    self.blipScripts = {}
end

function Map:SetOffset(x, y)
    self.x, self.y = x, y
end

function Map:GetOffset()
    return self.x, self.y
end

function Map:SetBlipSize(size)
    self.blipSize = size
end

function Map:GetBlipSize()
    return self.blipSize or 18
end

-- function Map:RefreshScale()
--     local scale = self:GetEffectiveScale()
--     local size = self:GetBlipSize()

--     for blip in pairs(self.activeBlips) do
--         blip:SetSize(size/scale, size/scale)
--     end
-- end

function Map:Clear()
    for blip in pairs(self.activeBlips) do
        blip:Hide()
    end
end

function Map:CreateBlip()
    local blip = Addon:GetClass('Blip'):New(self)

    blip:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    blip:Hide()
    blip:SetScript('OnClick', self:BlipScript(self.BlipOnClick))
    blip:SetScript('OnEnter', self:BlipScript(self.BlipOnEnter))
    blip:SetScript('OnLeave', self:BlipScript(self.BlipOnLeave))
    blip:SetScript('OnHide', self:BlipScript(self.BlipOnHide))
    blip:SetScript('OnShow', self:BlipScript(self.BlipOnShow))

    return blip
end

function Map:DrawObjectCoord(object, x, y, item)
    local blip = next(self.freeBlips) or self:CreateBlip()

    blip:SetObject(object, item)
    blip:Show()
    self:SetBlipPosition(blip, x, y)
end

function Map:SetBlipPosition(blip, x, y)
    local w, h = self:GetWidth()-self.x*2, self:GetHeight()+self.y*2
    local x, y = x*w/100+self.x, -y*h/100-self.y
    local scale = 1 --self:GetEffectiveScale()
    local size = self:GetBlipSize()

    blip:ClearAllPoints()
    blip:SetPoint('CENTER', self, 'TOPLEFT', x, y)
    blip:SetSize(size/scale, size/scale)
end

function Map:DrawObject(object, area, item)
    local coords = object:GetAreaCoords(area:GetID(), area:GetLevel())
    if not coords then
        return
    end
    for _, coord in ipairs(coords) do
        local x, y = coord:match('^(.+),(.+)$')

        self:DrawObjectCoord(object, tonumber(x), tonumber(y), item)
    end
end

function Map:GetMouseOverBlips()
    local blips = {}
    for blip in pairs(self.activeBlips) do
        if blip:IsMouseOver() then
            tinsert(blips, blip)
        end
    end
    return blips
end

function Map:GetMouseOverItems()
    local items = {}
    local exists = {}
    for _, blip in ipairs(self:GetMouseOverBlips()) do
        local object = blip:GetObject()

        for _, item in ipairs(object:GetDropList()) do
            if not item:IsCollected() and not exists[item] then
                tinsert(items, item)
                exists[item] = true
            end
        end

        if object:IsType(Npc) then
            for _, item in ipairs(object:GetSoldList()) do
                if not item:IsCollected() and not exists[item] then
                    tinsert(items, item)
                    exists[item] = true
                end
            end
        end
    end
    sort(items)
    return items
end

function Map:BlipOnShow(blip)
    self.freeBlips[blip] = nil
    self.activeBlips[blip] = true
end

function Map:BlipOnHide(blip)
    self.activeBlips[blip] = nil
    self.freeBlips[blip] = true
    blip:Hide()
end

function Map:BlipScript(method)
    if not method then
        return nil
    end
    if not self.blipScripts[method] then
        self.blipScripts[method] = function(...)
            return method(self, ...)
        end
    end
    return self.blipScripts[method]
end
