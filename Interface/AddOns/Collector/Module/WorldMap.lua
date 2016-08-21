
BuildEnv(...)

WorldMap = Addon:NewModule(Addon:GetClass('Map'):New(WorldMapButton), 'WorldMap', 'AceEvent-3.0', 'AceHook-3.0', 'LibInvoke-1.0')

function WorldMap:OnInitialize()
    self:SetAllPoints(true)

    -- self:SetScript('OnSizeChanged', self.RefreshScale)
    self:RegisterEvent('WORLD_MAP_UPDATE', 'Refresh')
    self:SetScript('OnShow', self.ForceRefresh)

    self:SetBlipSize(18)

    self.Tooltip = GUI:GetClass('Tooltip'):New(WorldMapFrame)

    local Button = CreateFrame('Button', nil, WorldMapFrame.UIElementsFrame) do
        Button:SetSize(31, 31)
        Button:RegisterForClicks('anyUp')
        Button:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]], 'ADD')
        Button:SetPoint('TOP', WorldMapFrame.UIElementsFrame.TrackingOptionsButton, 'BOTTOM')

        local Overlay = Button:CreateTexture(nil, 'OVERLAY') do
            Overlay:SetSize(53, 53)
            Overlay:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])
            Overlay:SetPoint('TOPLEFT')
        end

        local Bg = Button:CreateTexture(nil, 'BACKGROUND') do
            Bg:SetSize(20, 20)
            Bg:SetTexture([[Interface\Minimap\UI-Minimap-Background]])
            Bg:SetPoint('TOPLEFT', 7, -5)
        end

        local Icon = Button:CreateTexture(nil, 'ARTWORK') do
            Icon:SetSize(17, 17)
            Icon:SetPoint('TOPLEFT', 7, -6)
            Icon:SetTexture([[Interface\AddOns\Collector\Media\Logo]])
        end

        Button:SetScript('OnMouseDown', function()
            Icon:SetPoint('TOPLEFT', 8, -7)
        end)
        Button:SetScript('OnMouseUp', function()
            Icon:SetPoint('TOPLEFT', 7, -6)
        end)
        Button:SetScript('OnClick', function(Button)
            GUI:ToggleMenu(Button, self:GetMenuTable())
            self:SendMessage('COLLECTOR_WORLDMAPBUTTON_CLICK')
        end)
        Button:SetScript('OnShow', function()
            self:SendMessage('COLLECTOR_WORLDMAP_SHOW')
            Button:SetScript('OnShow', nil)
        end)
    end

    self.Button = Button


    self:RegisterMessage('COLLECTOR_SETTING_UPDATE')
end

function WorldMap:COLLECTOR_SETTING_UPDATE(_, key, value)
    if key == 'mountBlip' or key == 'petBlip' then
        self:SetShown(Profile:GetVar('mountBlip') or Profile:GetVar('petBlip'))
        self:ForceRefresh()
    end
end

function WorldMap:Update()
    local area = Area:Get(Addon:GetCurrentAreaInfo())
    local klasses = Profile:GetBlipClasses()

    if not self.forceRefresh and self.area == area and self.klasses == klasses then
        return
    end

    self.area = area
    self.klasses = klasses
    self.forceRefresh = nil
    self:Clear()
    self:Draw()
end

function WorldMap:ForceRefresh()
    self.forceRefresh = true
    self:Refresh()
end

function WorldMap:Draw()
    for i, v in ipairs(self.area:GetNpcList()) do
        self:DrawNotCollectedObject(v)
    end
    for i, v in ipairs(self.area:GetGameObjectList()) do
        self:DrawNotCollectedObject(v)
    end
end

function WorldMap.Invoke:DrawNotCollectedObject(obj)
    if obj:HasNotCollectedItem(self.klasses) then
        self:DrawObject(obj, self.area)
    end
end

function WorldMap:BlipOnEnter(blip)
    self.Tooltip:SetOwner(blip, 'ANCHOR_RIGHT')

    for _, item in ipairs(self:GetMouseOverItems()) do
        self.Tooltip:AddHeader(format('|T%s:16|t %s', item:GetIcon(), item:GetName()))
        self.Tooltip:AddLine(item:GetSourceText(), 1, 1, 1, true)
    end

    self.Tooltip:Show()
    self.Tooltip:SetFrameStrata('TOOLTIP')
end

function WorldMap:BlipOnLeave()
    self.Tooltip:Hide()
end

function WorldMap:BlipOnClick(blip, button)
    if button == 'RightButton' then
        local menuTable = {}
        for _, item in ipairs(self:GetMouseOverItems()) do
            tinsert(menuTable, {
                text = item:GetName(),
                value = item,
                func = function()
                    item:TogglePanel()
                end
            })
        end
        GUI:ToggleMenu(blip, menuTable, 'cursor')
    end
end

function WorldMap:GetMenuTable()
    if not self.menuTable then
        self.menuTable = {
            {
                text = L['魔兽达人'],
                isTitle = true,
            },
            {
                text = L['显示坐骑标记'],
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return Profile:GetVar('mountBlip')
                end,
                func = function(_,_,_,value)
                    Profile:SetVar('mountBlip', value)
                end,
            },
            {
                text = L['显示小宠物标记'],
                checkable = true,
                isNotRadio = true,
                keepShownOnClick = true,
                checked = function()
                    return Profile:GetVar('petBlip')
                end,
                func = function(_,_,_,value)
                    Profile:SetVar('petBlip', value)
                end,
            },
        }
    end
    return self.menuTable
end
