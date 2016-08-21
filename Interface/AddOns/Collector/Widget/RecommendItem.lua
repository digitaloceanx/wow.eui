
BuildEnv(...)

local RecommendItem = Addon:NewClass('RecommendItem', GUI:GetClass('ItemButton'))

GUI:Embed(RecommendItem, 'Refresh', 'Blocker')

function RecommendItem:Constructor()
    local Background = self:CreateTexture(nil, 'BACKGROUND') do
        Background:SetTexture([[Interface\Store\Store-Main]])
        Background:SetTexCoord(0.18457031, 0.32714844, 0.64550781, 0.84960938)
        Background:SetAllPoints(true)
    end

    local Model = CreateFrame('PlayerModel', nil, self, 'ModelWithZoomTemplate') do
        Model:SetPoint('TOPLEFT', 5, -5)
        Model:SetPoint('BOTTOMRIGHT', -5, 5)
    end

    local ClickFrame = CreateFrame('Button', nil, Model) do
        ClickFrame:SetAllPoints(true)
    end

    local Cover = ClickFrame:CreateTexture(nil, 'HIGHLIGHT', nil, 0) do
        Cover:SetColorTexture(0.035, 0.071, 0.118, 0.5)
        Cover:SetAllPoints(true)
    end

    local Icon = ClickFrame:CreateTexture(nil, 'HIGHLIGHT', nil, 1) do
        Icon:SetPoint('TOPLEFT', 40, -40)
        Icon:SetSize(32, 32)
    end

    local Name = ClickFrame:CreateFontString(nil, 'HIGHLIGHT', 'GameFontNormal') do
        Name:SetPoint('LEFT', Icon, 'RIGHT', 5, 0)
    end

    local Text = GUI:GetClass('ScrollSummaryHtml'):New(ClickFrame) do
        Text:Hide()
        Text:SetPoint('TOPLEFT', Icon, 'BOTTOMLEFT', 0, -10)
        Text:SetPoint('BOTTOMRIGHT', -20, 20)
    end

    local Discount = CreateFrame('Frame', nil, Text) do
        Discount:SetPoint('TOPRIGHT', Model, 1, -2)
        Discount:SetSize(100,32)

        local DiscountRight = Discount:CreateTexture(nil, 'ARTWORK', nil, 3)
        DiscountRight:SetTexture([[Interface\Store\Store-Main]])
        DiscountRight:SetTexCoord(0.98828125, 0.99609375, 0.19921875, 0.23046875)
        DiscountRight:SetSize(8, 32)
        DiscountRight:SetPoint('TOPRIGHT', 1, -2)

        local DiscountLeft = Discount:CreateTexture(nil, 'ARTWORK', nil, 3)
        DiscountLeft:SetTexture([[Interface\Store\Store-Main]])
        DiscountLeft:SetTexCoord(0.98828125, 0.99609375, 0.10546875, 0.13671875)
        DiscountLeft:SetSize(8, 32)
        DiscountLeft:SetPoint('TOPLEFT', -1, -2)

        local DiscountMiddle = Discount:CreateTexture(nil, 'ARTWORK', nil, 3)
        DiscountMiddle:SetTexture([[Interface\Store\Store-Main]])
        DiscountMiddle:SetTexCoord(0.32910156, 0.36230469, 0.69042969, 0.72167969)
        DiscountMiddle:SetSize(34, 32)
        DiscountMiddle:SetPoint('RIGHT', DiscountRight, 'LEFT', 0, 0)
        DiscountMiddle:SetPoint('LEFT', DiscountLeft, 'RIGHT', 0, 0)

        local Text = Discount:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed2')
        Text:SetPoint('CENTER', DiscountMiddle, 1, 2)
        Text:SetTextColor(1, 1, 1)
        Text:SetText(L['今日推荐'])
        -- Discount.SetText = function(_, text)
        --     Text:SetText(text)
        --     Discount:SetWidth(Text:GetStringWidth() + 20)
        -- end
    end

    ClickFrame:SetScript('OnEnter', function()
        Text:Show()
    end)

    ClickFrame:SetScript('OnLeave', function()
        Text:Hide()
    end)

    ClickFrame:SetScript('OnClick', function()
        self:FireHandler('OnItemClick')
    end)

    self.Model = Model
    self.Blocker = Blocker
    self.Text = Text
    self.Icon = Icon
    self.Name = Name
end

function RecommendItem:SetItem(mount)
    self.Icon:SetTexture(mount:GetIcon())
    self.Name:SetText(mount:GetName())
    self.Text:SetText(mount:GetRecommendDescription())
    self.Model:SetDisplayInfo(mount:GetDisplay())
end

-- x=RecommendItem:New(UIParent)
-- x:SetPoint('CENTER', 0, -200)
-- x:SetSize(342, 257)
-- x.Model:SetDisplayInfo(34492)
-- x:SetText('123')
