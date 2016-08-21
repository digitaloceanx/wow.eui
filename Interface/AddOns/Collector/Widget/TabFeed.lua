
BuildEnv(...)

local TabFeed = Addon:NewClass('TabFeed', 'Frame')

TabFeed._Objects = TabFeed._Objects or {}

function TabFeed:Constructor()
    local Bg = self:CreateTexture(nil, 'BACKGROUND') do
        Bg:SetAllPoints(true)
        Bg:SetTexture([[Interface\LFGFRAME\UI-LFG-HOLIDAY-BACKGROUND-Brew]])
        Bg:SetTexCoord(0,326/512,0,252/256)
    end

    local RealmFeedList = GUI:GetClass('ListView'):New(self) do
        RealmFeedList:SetPoint('TOPLEFT', 40, -50)
        RealmFeedList:SetPoint('TOPRIGHT', -40, -50)
        RealmFeedList:SetHeight(101)
        RealmFeedList:SetItemHeight(20)

        RealmFeedList:SetCallback('OnItemCreated', function(_, button)
            button.Text = button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
                button.Text:SetPoint('LEFT')
            end

            button.Stamp = button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
                button.Stamp:SetPoint('RIGHT')
            end
        end)
        RealmFeedList:SetCallback('OnItemFormatted', function(_, button, data)
            button.Text:SetText(data.target)
            button.Stamp:SetText(FriendsFrame_GetLastOnline(data.stamp))
        end)
        RealmFeedList:SetCallback('OnRefresh', function(RealmFeedList)
            RealmFeedList.Empty:SetShown(RealmFeedList:GetItemCount() == 0)
        end)
        RealmFeedList:SetCallback('OnItemMenu', function(_, button, data)
            self:TogglePlayerMenu(button, data.target)
        end)

        RealmFeedList.Empty = RealmFeedList:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
            RealmFeedList.Empty:SetPoint('CENTER')
            RealmFeedList.Empty:SetText(L['暂无服务器动态'])
            RealmFeedList.Empty:Hide()
        end
    end

    local RealmFeedLabel = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') do
        RealmFeedLabel:SetPoint('BOTTOMLEFT', RealmFeedList, 'TOPLEFT', -20, 15)
        RealmFeedLabel:SetText(L['服务器动态'])
    end

    local WorldFeedList = GUI:GetClass('ListView'):New(self) do
        WorldFeedList:SetPoint('TOPLEFT', RealmFeedList, 'BOTTOMLEFT', 0, -50)
        WorldFeedList:SetPoint('TOPRIGHT', RealmFeedList, 'BOTTOMRIGHT', 0, -50)
        WorldFeedList:SetHeight(101)
        WorldFeedList:SetItemHeight(20)

        WorldFeedList:SetCallback('OnItemCreated', function(_, button)
            button.Text = button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
                button.Text:SetPoint('LEFT')
            end
            button.Stamp = button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
                button.Stamp:SetPoint('RIGHT')
            end
        end)
        WorldFeedList:SetCallback('OnItemFormatted', function(_, button, data)
            button.Text:SetText(data.target)
            button.Stamp:SetText(FriendsFrame_GetLastOnline(data.stamp))
        end)
        WorldFeedList:SetCallback('OnRefresh', function(WorldFeedList)
            WorldFeedList.Empty:SetShown(WorldFeedList:GetItemCount() == 0)
        end)

        WorldFeedList.Empty = WorldFeedList:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
            WorldFeedList.Empty:SetPoint('CENTER')
            WorldFeedList.Empty:SetText(L['暂无世界动态'])
            WorldFeedList.Empty:Hide()
        end
    end

    local WorldFeedLoading = CreateFrame('Frame', nil, self, 'LoadingSpinnerTemplate') do
        WorldFeedLoading:SetPoint('CENTER', WorldFeedList, 'CENTER')
        WorldFeedLoading:Hide()
        WorldFeedLoading.Anim:Play()
    end

    local WorldFeedLabel = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') do
        WorldFeedLabel:SetPoint('BOTTOMLEFT', WorldFeedList, 'TOPLEFT', -20, 15)
        WorldFeedLabel:SetText(L['世界动态'])
    end

    self.RealmFeedList = RealmFeedList
    self.RealmFeedLabel = RealmFeedLabel
    self.WorldFeedList = WorldFeedList
    self.WorldFeedLabel = WorldFeedLabel
    self.WorldFeedLoading = WorldFeedLoading

    self:SetScript('OnShow', self.QueryWorldFeed)

    tinsert(self._Objects, self)
end

function TabFeed:SetPlan(plan)
    self.plan = plan

    self.RealmFeedList:SetItemList(plan:GetObject():GetRealmFeedList())
    self.RealmFeedList:Refresh()

    self:QueryWorldFeed()
end

function TabFeed:GetPlan()
    return self.plan
end

function TabFeed:QueryWorldFeed()
    if not self.plan or not self:IsVisible() then
        return
    end
    Logic:QueryPlan(self.plan)
end

function TabFeed:TogglePlayerMenu(owner, target)
    GUI:ToggleMenu(owner, function()
        return {
            {
                text = target,
                isTitle = true,
            },
            {
                text = WHISPER,
                func = function()
                    ChatFrame_SendTell(target)
                end,
            },
            {
                text = INVITE,
                func = function()
                    InviteToGroup(target)
                end,
            },
        }
    end , 'TOPLEFT', owner, 'BOTTOMLEFT', 48, 2)
end

function TabFeed:RefreshWorldFeed(token)
    if not self.plan or self.plan:GetToken() ~= token then
        return
    end
    self.WorldFeedList:SetItemList(self.plan:GetObject():GetWorldFeedList())
    self.WorldFeedList:Refresh()
    self.WorldFeedList:Show()
    self.WorldFeedLoading:Hide()
end

function TabFeed:RefreshRealmFeed()
    self.RealmFeedList:Refresh()
end

function TabFeed:ToggleWorldFeedLoading(token)
    if not self.plan or self.plan:GetToken() ~= token then
        return
    end
    self.WorldFeedList:Hide()
    self.WorldFeedLoading:Show()
end

function TabFeed:IterateObjects()
    return ipairs(self._Objects)
end

local TabFeedManager = Addon:NewModule('TabFeedManager', 'AceEvent-3.0')

function TabFeedManager:OnInitialize()
    self:RegisterMessage('COLLECTOR_WORLD_FEED_QUERIED')
    self:RegisterMessage('COLLECTOR_WORLD_FEED_UPDATE')
    self:RegisterMessage('COLLECTOR_REALM_FEED_UPDATE')
end

function TabFeedManager:COLLECTOR_WORLD_FEED_QUERIED(_, token)
    for _, obj in TabFeed:IterateObjects() do
        obj:ToggleWorldFeedLoading(token)
    end
end

function TabFeedManager:COLLECTOR_WORLD_FEED_UPDATE(_, token)
    for _, obj in TabFeed:IterateObjects() do
        obj:RefreshWorldFeed(token)
    end
end

function TabFeedManager:COLLECTOR_REALM_FEED_UPDATE()
    for _, obj in TabFeed:IterateObjects() do
        obj:RefreshRealmFeed(token)
    end
end
