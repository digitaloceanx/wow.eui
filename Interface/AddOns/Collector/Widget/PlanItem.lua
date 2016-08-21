
BuildEnv(...)

local PlanItem = Addon:NewClass('PlanItem', GUI:GetClass('ItemButton'))

function PlanItem:Constructor()
    local Icon = self:CreateTexture(nil, 'ARTWORK') do
        Icon:SetPoint('LEFT', 4, 0)
        Icon:SetSize(38, 38)
        Icon:SetTexture([[Interface\ICONS\Achievement_BG_winbyten]])
    end

    local Bg = self:CreateTexture(nil, 'BACKGROUND') do
        Bg:SetPoint('LEFT', Icon, 'RIGHT', 4, 0)
        Bg:SetPoint('TOPRIGHT')
        Bg:SetPoint('BOTTOMRIGHT')
        Bg:SetAtlas('PetList-ButtonBackground')
    end

    local Highlight = self:CreateTexture(nil, 'HIGHLIGHT') do
        Highlight:SetAllPoints(Bg)
        Highlight:SetAtlas('PetList-ButtonHighlight')
    end

    local Checked = self:CreateTexture(nil, 'OVERLAY') do
        Checked:SetAllPoints(Bg)
        Checked:SetAtlas('PetList-ButtonSelect')
        self:SetCheckedTexture(Checked)
    end

    local State = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalRight') do
        State:SetPoint('RIGHT', Bg, 'RIGHT', -10, 0)
    end

    local Text = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLeft') do
        Text:SetPoint('LEFT', Bg, 'LEFT', 10, 0)
        Text:SetPoint('RIGHT', State, 'LEFT', -5, 0)
        Text:SetWordWrap(false)
        self:SetFontString(Text)
    end

    local ExtraIcon = self:CreateTexture(nil, 'BORDER') do
        ExtraIcon:SetSize(46, 44)
        ExtraIcon:SetPoint('BOTTOMRIGHT', -1, 1)
    end

    local Track = self:CreateTexture(nil, 'BORDER') do
        Track:Hide()
        Track:SetSize(16, 16)
        Track:SetPoint('TOPRIGHT', Bg)
        Track:SetTexture([[Interface\BUTTONS\UI-CheckBox-Check]])
    end

    -- local StatusBar = CreateFrame('StatusBar', nil, self) do
    --     StatusBar:SetPoint('BOTTOMLEFT', Bg, 'BOTTOMLEFT', 2, 0)
    --     StatusBar:SetPoint('BOTTOMRIGHT', Bg, 'BOTTOMRIGHT', -2, 0)
    --     StatusBar:SetHeight(3)
    --     StatusBar:SetMinMaxValues(0, 100)
    --     StatusBar:SetValue(50)
    --     StatusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]], 'BACKGROUND')
    -- end

    -- local StatusBarText = StatusBar:CreateFontString(nil, 'ARTWORK') do
    --     StatusBarText:SetPoint('BOTTOMRIGHT', 0, 3)
    --     StatusBarText:SetFont(ChatFontNormal:GetFont(), 12)
    -- end

    self.Icon = Icon
    self.State = State
    self.StatusBar = StatusBar
    self.StatusBarText = StatusBarText
    self.ExtraIcon = ExtraIcon
    self.Track = Track

    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function PlanItem:SetIcon(icon)
    self.Icon:SetTexture(icon)
end

function PlanItem:SetExtraTexture(texture, l, r, t, b)
    if not texture then
        self.ExtraIcon:Hide()
    else
        self.ExtraIcon:SetTexture(texture)
        self.ExtraIcon:SetTexCoord(l or 0, r or 1, t or 0, b or 1)
        self.ExtraIcon:Show()
    end
end

function PlanItem:SetExtraSize(w, h)
    self.ExtraIcon:SetSize(w, h)
end

function PlanItem:SetPlan(plan)
    local item = plan:GetObject()

    self:SetText(item:GetName())
    self:SetIcon(item:GetIcon())
    self:SetExtraTexture(item:GetTypeTexture())
    self:SetExtraSize(item:GetTypeSize())
    self.Track:SetShown(item:IsInTrack())

    local state = item:IsCanKill()
    local text
    local color
    if state == true then
        text = BOSS_ALIVE
        color = GREEN_FONT_COLOR
    elseif state == false then
        text = BOSS_DEAD
        color = RED_FONT_COLOR
    end
    self.State:SetText(text)
    if color then
        self.State:SetTextColor(color.r, color.g, color.b)
    end
end
