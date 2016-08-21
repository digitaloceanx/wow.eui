
BuildEnv(...)

local TabMap = Addon:NewClass('TabMap', 'ScrollFrame')

function TabMap:Constructor()
    local NoMap = CreateFrame('Frame', nil, self) do
        NoMap:SetAllPoints(true)
        NoMap:Hide()

        -- local Bg = NoMap:CreateTexture(nil, 'BACKGROUND') do
        --     Bg:SetAllPoints(true)
        --     Bg:SetTexture([[Interface\LFGFRAME\UI-LFG-HOLIDAY-BACKGROUND-Cata]])
        --     Bg:SetTexCoord(0,326/512,0,252/256)
        -- end

        local Label = NoMap:CreateFontString(nil, 'ARTWORK', 'QuestFont_Huge')
        Label:SetPoint('CENTER')
        Label:SetText(L['没有地图数据'])
    end

    local Map = Addon:GetClass('PlanMap'):New(self) do
        self:SetScrollChild(Map)
    end

    local MoreMapButton = CreateFrame('Button', nil, self, 'UIMenuButtonStretchTemplate') do
        MoreMapButton:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -2, 5)
        MoreMapButton:SetSize(100, 22)
        MoreMapButton:SetText(L['更多地图'])
        MoreMapButton:SetScript('OnClick', function(MoreMapButton)
            GUI:ToggleMenu(MoreMapButton, self:GetAreaMenuTable())
        end)
    end

    self.NoMap = NoMap
    self.Map = Map
    self.MoreMapButton = MoreMapButton

    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function TabMap:OnSizeChanged(width, height)
    self.Map:SetSize(width, height)
end

function TabMap:GetAreaMenuTable()
    local menuTable = {}
    for i, area in ipairs(self.plan:GetObject():GetAreaList()) do
        tinsert(menuTable, {
            text = area:GetName(),
            checkable = true,
            checked = self.Map:GetArea() == area,
            func = function()
                self.Map:SetInfo(area, self.plan)
            end
        })
    end
    return menuTable
end

function TabMap:SetPlan(plan)
    if self.plan == plan then
        return
    end
    self.plan = plan
    
    local areaList = plan:GetObject():GetAreaList()
    if #areaList > 0 then
        self.NoMap:Hide()
        self.Map:Show()
        self.MoreMapButton:SetShown(#areaList > 1)
        self.Map:SetInfo(areaList[1], plan)
    else
        self.NoMap:Show()
        self.Map:Hide()
        self.MoreMapButton:Hide()
    end
end
