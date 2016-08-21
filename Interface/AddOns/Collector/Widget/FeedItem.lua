
BuildEnv(...)

local FeedItem = Addon:NewClass('FeedItem', GUI:GetClass('ItemButton'))

local function PraiseOnClick(self)
    self:GetParent():FireHandler('OnPraiseClick')
end

function FeedItem:Constructor()
    local Time = self:CreateFontString(nil, 'ARTWORK', 'FriendsFont_Small') do
        Time:SetPoint('TOPLEFT', 5, -5)
        Time:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
    end

    local Label = self:CreateFontString(nil, 'ARTWORK', 'FriendsFont_Small') do
        Label:SetPoint('LEFT', Time, 'RIGHT', 10, 0)
    end

    local Collect = self:CreateFontString(nil, 'ARTWORK', 'FriendsFont_Small') do
        Collect:SetPoint('BOTTOMLEFT', 5, 5)
        Collect:SetText('已收集')
    end

    local Model = CreateFrame('PlayerModel', nil, self) do
        Model:SetPoint('TOPLEFT', Time, 'BOTTOMLEFT', 0, -2)
        Model:SetPoint('BOTTOMLEFT', Collect, 'TOPLEFT', 0, 2)
        Model:SetWidth(130)
        Model:SetRotation(MODELFRAME_DEFAULT_ROTATION)
    end

    local Praise = GUI:GetClass('TitleButton'):New(self) do
        Praise:SetPoint('BOTTOMRIGHT', -5, 5)
        Praise:SetTexture([[Interface\COMMON\friendship-heart]], 0.21875, 0.78125, 0.15625, 0.71875)
        Praise:SetScript('OnClick', PraiseOnClick)
    end

    local Highlight = self:CreateTexture(nil, 'BACKGROUND') do
        Highlight:SetAllPoints(true)
        Highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        self:SetHighlightTexture(Highlight)
    end

    self.Label = Label
    self.Time = Time
    self.Model = Model
    self.Collect = Collect
end

function FeedItem:SetFeed(feed)
    if not feed then
        return
    end
    local item = feed:GetObject()

    self.Label:SetText(L['获得'] .. (item.GetLink and item:GetLink() or item:GetName()))
    self.Time:SetText(feed:GetStampText())
    self.Model:SetDisplayInfo(item:GetDisplay())
    self.Collect:SetText(item:IsCollected() and L['|cff00ff00已收集|r'] or L['|cffff0000未收集|r'])
end
