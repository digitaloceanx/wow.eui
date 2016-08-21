BuildEnv(...)

Friend = Addon:NewClass('Friend', Object)

function Friend:Constructor(id)
    self.id = id
    self.isBNFriend = type(id) == 'number'
    self.feedList = {}
    self.planList = {}
end

function Friend:IsBNFriend()
    return self.isBNFriend
end

function Friend:GetIndex()
    return self.isBNFriend and BNGetFriendIndex(self.id) or WOW_FRIEND_NAME_TO_INDEX[self.id]
end

function Friend:GetCharacter()
    if self.isBNFriend then
        local index = self:GetIndex()
        for i = 1, BNGetNumFriendGameAccounts(index) do
            local hasFocus, toonName, client, realmName = BNGetFriendGameAccountInfo(index, i)
            if hasFocus and client == BNET_CLIENT_WOW then
                return GetFullName(toonName, realmName)
            end
        end
    else
        return GetFullName(self.id)
    end
end

function Friend:Query()
    if not self:IsCanQuery() then
        return false
    end
    Logic:QueryFriend(self)

    return true
end

function Friend:SetQueryStamp(stamp)
    self.queryStamp = stamp
end

function Friend:SetFeedList(list)
    self.feedList = list
end

function Friend:SetPlanList(list)
    self.planList = list
end

function Friend:GetFeedList()
    return self.feedList
end

function Friend:GetPlanList()
    return self.planList
end

function Friend:IsQueryTimeOut()
    return not self.queryStamp or time() - self.queryStamp > 86400
    -- return true
end

function Friend:IsOnline()
    if self.isBNFriend then
        return (select(8, BNGetFriendInfoByID(self.id))) 
    else
        return (select(5, GetFriendInfo(self:GetIndex())))
    end
end

function Friend:IsCanQuery()
    return not self.isBNFriend or (self:GetBattleTag() or select(8, BNGetFriendInfoByID(self.id)))
end

function Friend.Once:GetName()
    return self.isBNFriend and (FRIENDS_BNET_NAME_COLOR_CODE .. select(2, BNGetFriendInfoByID(self.id)) .. FONT_COLOR_CODE_CLOSE) or self.id
end

function Friend.Once:GetBattleTag()
    return self.isBNFriend and select(3, BNGetFriendInfoByID(self.id)) or nil
end

function Friend:SendChat(msg)
    if not self:IsOnline() then
        return
    end
    if self.isBNFriend then
        BNSendWhisper(self.id, msg)
    else
        SendChatMessage(msg, 'WHISPER', nil, self.id)
    end
end

function Friend:GetDBKey()
    if self.isBNFriend then
        return self:GetBattleTag()
    else
        return self:GetCharacter()
    end
end

function Friend:ToDB()
    local result = {
        queryStamp = self.queryStamp,
        feedList = {},
        planList = {},
    }

    for i, v in ipairs(self.feedList) do
        result.feedList[i] = v:ToDB()
    end

    for i, v in ipairs(self.planList) do
        result.planList[i] = v:ToDB()
    end
    return result
end
