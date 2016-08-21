
BuildEnv(...)

local TabSummary = Addon:NewClass('TabSummary', 'Frame')

function TabSummary:Constructor()
    
    local Bg = self:CreateTexture(nil, 'BACKGROUND') do
        Bg:SetAllPoints(true)
        Bg:SetTexture([[Interface\LFGFRAME\UI-LFG-HOLIDAY-BACKGROUND-Summer]])
        Bg:SetTexCoord(0,326/512,0,252/256)
    end

    local Description = GUI:GetClass('ScrollSummaryHtml'):New(self) do
        Description:SetPoint('TOPLEFT', 30, -30)
        Description:SetSize(self:GetWidth() - 60, self:GetHeight() - 60)
        Description:SetCallback('OnHyperlinkClick', function(_, linkType, data, link)
            if linkType == 'achievement' then
                Achievement:Get(tonumber(data:match('^(%d+):'))):TogglePanel()
            elseif linkType == 'store' then
                ToggleStoreUI()
            end
        end)
        Description:SetCallback('OnHyperlinkEnter', function(owner, linkType, data, link)
            if linkType == 'achievement' then
                GameTooltip:SetOwner(owner, 'ANCHOR_CURSOR')
                -- GameTooltip:SetText(L['点击打开成就'])
                GameTooltip:SetHyperlink(link)
                GameTooltip:Show()
            elseif linkType == 'store' then
                GameTooltip:SetOwner(owner, 'ANCHOR_CURSOR')
                GameTooltip:SetText(L['点击打开商城'])
                GameTooltip:Show()
            end
        end)
    end

    self.Description = Description

    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function TabSummary:OnSizeChanged(width, height)
    self.Description:SetSize(width-60, height-60)
end

function TabSummary:SetPlan(plan)
    self.Description:SetText(plan:GetObject():GetSummary())
end
