
BuildEnv(...)

FriendFeed = Addon:NewModule(CreateFrame('Frame', nil, FriendsListFrame), 'FriendFeed', 'AceEvent-3.0', 'AceHook-3.0', 'AceBucket-3.0')

function FriendFeed:OnInitialize()
    self:SetPoint('TOPLEFT', FriendsFrame, 'TOPRIGHT', -6, -20)
    self:SetPoint('BOTTOMLEFT', FriendsFrame, 'BOTTOMRIGHT', -6, 10)
    self:SetWidth(250)
    self:Hide()
    self:SetBackdrop{
        edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
        edgeSize = 16,
    }

    local bg = self:CreateTexture(nil, 'BACKGROUND') do
        bg:SetPoint('TOPLEFT', 2, -2)
        bg:SetPoint('BOTTOMRIGHT', -2, 2)
        bg:SetTexture([[Interface\FrameGeneral\UI-Background-Rock]])
    end

    local Title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') do
        Title:SetPoint('TOPLEFT', 10, -10)
    end

    local PlanParent = CreateFrame('Frame', nil, self, 'InsetFrameTemplate') do
        PlanParent:SetPoint('TOPLEFT', 15, -50)
        PlanParent:SetPoint('TOPRIGHT', -15, -50)
        PlanParent:SetHeight(36)

        local Label = PlanParent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
            Label:SetPoint('BOTTOMLEFT', PlanParent, 'TOPLEFT', 0, 3)
            Label:SetText(L['玩家计划'])
        end
    end

    local PlanList = GUI:GetClass('GridView'):New(PlanParent) do
        PlanList:SetPoint('LEFT', 15, 0)
        PlanList:SetSize(1, 1)
        PlanList:SetAutoSize(true)
        PlanList:SetRowCount(1)
        PlanList:SetColumnCount(5)
        PlanList:SetItemHeight(24)
        PlanList:SetItemWidth(24)
        PlanList:SetItemSpacing(3)
        PlanList:SetCallback('OnItemFormatted', function(_, button, plan)
            button:SetNormalTexture(plan:GetObject():GetIcon())
        end)
        PlanList:SetCallback('OnItemCreated', function(_, button)
            button:SetHighlightTexture([[Interface\BUTTONS\ButtonHilight-Square]], 'ADD')
        end)
        PlanList:SetCallback('OnItemEnter', function(_, button, plan)
            GameTooltip:SetOwner(button, 'ANCHOR_BOTTOMRIGHT')
            if plan:GetObject().GetLink then
                GameTooltip:SetHyperlink(plan:GetObject():GetLink())
            else
                GameTooltip:SetText(plan:GetObject():GetName(), 1, 1, 1)
                GameTooltip:AddLine(plan:GetObject():GetDescription(), 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        PlanList:SetCallback('OnItemLeave', function()
            GameTooltip:Hide()
        end)
        PlanList:SetCallback('OnItemClick', function(_, _, collect)
            collect:GetObject():TogglePanel()
        end)
        PlanList:SetCallback('OnRefresh', function(PlanList)
            PlanList.Empty:SetShown(PlanList:GetItemCount() == 0)
        end)

        PlanList.Empty = PlanList:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
            PlanList.Empty:SetPoint('CENTER', PlanParent, 'CENTER')
            PlanList.Empty:Hide()
            PlanList.Empty:SetText(L['玩家暂无计划'])
        end
    end

    local FeedParent = CreateFrame('Frame', nil, self, 'InsetFrameTemplate') do
        FeedParent:SetPoint('TOPLEFT', PlanParent, 'BOTTOMLEFT', 0, -25)
        FeedParent:SetPoint('BOTTOMRIGHT', -15, 15)

        local Label = FeedParent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
            Label:SetPoint('BOTTOMLEFT', FeedParent, 'TOPLEFT', 0, 3)
            Label:SetText(L['玩家动态'])
        end
    end

    local FeedList = GUI:GetClass('ListView'):New(FeedParent) do
        FeedList:SetPoint('TOPLEFT', 5, -5)
        FeedList:SetPoint('BOTTOMRIGHT', -5, 5)
        FeedList:SetItemHeight(110)
        FeedList:SetItemSpacing(5)
        FeedList:SetItemClass(Addon:GetClass('FeedItem'))
        FeedList:SetCallback('OnItemFormatted', function(_, button, feed)
            button:SetFeed(feed)
        end)
        FeedList:SetCallback('OnRefresh', function(FeedList)
            FeedList.Empty:SetShown(FeedList:GetItemCount() == 0)
        end)
        FeedList:SetCallback('OnPraiseClick', function(_, _, collect)
            self:Praise(collect)
        end)
        FeedList:SetCallback('OnItemClick', function(_, _, collect)
            collect:GetObject():TogglePanel()
        end)

        FeedList.Empty = FeedList:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
            FeedList.Empty:SetPoint('CENTER')
            FeedList.Empty:Hide()
            FeedList.Empty:SetText(L['玩家暂无动态'])
        end
    end

    local Error = self:CreateFontString(nil, 'ARTWORK', 'QuestFont_Huge') do
        Error:SetPoint('CENTER', FeedParent, 'CENTER')
    end

    local Loading = CreateFrame('Frame', nil, self, 'LoadingSpinnerTemplate') do
        Loading:SetPoint('CENTER', FeedParent, 'CENTER')
        Loading:Hide()
        Loading.Anim:Play()

        Loading:SetScript('OnShow', function()
            PlanList:SetItemList()
            FeedList:SetItemList()
            PlanList:Hide()
            FeedList:Hide()
        end)
        Loading:SetScript('OnHide', function()
            PlanList:Show()
            FeedList:Show()
        end)
    end

    self.Title = Title
    self.FeedList = FeedList
    self.PlanList = PlanList
    self.PlanParent = PlanParent
    self.FeedParent = FeedParent
    self.Error = Error
    self.Loading = Loading

    self:SecureHook('FriendsFrame_SelectFriend')

    self:SetScript('OnShow', function()
        self:SendMessage('COLLECTOR_FRIENDFEED_SHOW')
    end)

    self:RegisterMessage('COLLECTOR_SERVER_STATUS_UPDATED')
    self:RegisterMessage('COLLECTOR_FRIEND_INFO_UPDATE')
    self:RegisterMessage('COLLECTOR_FRIEND_INFO_QUERIED')

    self:RegisterBucketEvent({'FRIENDLIST_UPDATE', 'BN_FRIEND_LIST_SIZE_CHANGED'}, 0.5, function()
        if FriendsFrame.selectedFriend == 0 then
            self:Hide()
        end
    end)
end

function FriendFeed:FriendsFrame_SelectFriend(friendType, id)
    if friendType == FRIENDS_BUTTON_TYPE_WOW then
        self.selectedFriend = Friend:Get((GetFriendInfo(id)))
    elseif friendType == FRIENDS_BUTTON_TYPE_BNET then
        self.selectedFriend = Friend:Get((BNGetFriendInfo(id)))
    end

    self.Title:SetText(self.selectedFriend:GetName())

    Logic:QueryFriend(self.selectedFriend)
end

function FriendFeed:COLLECTOR_SERVER_STATUS_UPDATED(_, status)
    if not status or not self.selectedFriend then
        return
    end
    Logic:QueryFriend(self.selectedFriend)
end

function FriendFeed:COLLECTOR_FRIEND_INFO_UPDATE(_, token)
    if token ~= self.selectedFriend:GetToken() then
        return 
    end

    self.Loading:Hide()

    if not self.selectedFriend:IsCanQuery() then
        self.Error:Show()
        self.Error:SetText('Error')
    else
        self.Error:Hide()

        local feed = self.selectedFriend:GetFeedList()
        local plan = self.selectedFriend:GetPlanList()
        self:SetShown(#feed > 0 or #plan > 0)

        self.FeedList:SetItemList(feed)
        self.FeedList:Refresh()
        self.PlanList:SetItemList(plan)
        self.PlanList:Refresh()
    end
end

function FriendFeed:COLLECTOR_FRIEND_INFO_QUERIED(_, token)
    if token ~= self.selectedFriend:GetToken() then
        return 
    end

    self.Loading:Show()
    self.Error:Hide()
end

function FriendFeed:Praise(collect)
    self.selectedFriend:SendChat(L['称赞你的'] .. collect:GetObject():GetLocale() .. collect:GetObject():GetLink())
end
