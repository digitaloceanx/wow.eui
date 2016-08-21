
BuildEnv(...)

Logic = Addon:NewModule('Logic', 'AceEvent-3.0', 'NetEaseSocket-2.0')

function Logic:OnInitialize()
    if not ADDON_REGIONSUPPORT then
        return
    end

    self:ListenSocket('NERB', ADDON_SERVER)

    self:RegisterServer('SERVER_CONNECTED')
    self:RegisterServer('SERVER_DISCONNECTED', 'ServerConnect')
    self:RegisterServer('CHANNEL_DISCONNECTED', 'ConnectChannel')
    self:RegisterServer('CRQR', 'FRIEND_REQUEST_RESULT')
    self:RegisterServer('CRPR', 'PLAN_REQUEST_RESULT')

    self:RegisterServer('CSDV', 'SOCKET_DATA_VALUE')

    self:RegisterServer('CHANNEL_CONNECTED')

    self:RegisterMessage('COLLECTOR_LEARNED')
    self:RegisterMessage('COLLECTOR_PLAN_ADDED')
    self:RegisterMessage('COLLECTOR_PLAN_DELETED')

    self:ServerConnect()
end

function Logic:CHANNEL_CONNECTED()
    self:RegisterBroad('CLC', 'BROAD_LEADED')
    self:RegisterBroad('CP', 'BROAD_PLAN')
end

function Logic:BROAD_LEADED(_, target, collectType, id)
    if not Addon:IsFriend(target) then
        return
    end

    local item = Addon:GetCollectTypeClass(collectType):Get(id)

    Addon:MakeChatMessage('CHAT_MSG_ACHIEVEMENT', L['你的好友%%s获得了%s%s']:format('坐骑', item:GetLink()), target, '', '')
end

function Logic:BROAD_PLAN(_, target, collectType, id, isAdd)
    if UnitIsUnit('player', target) then
        return
    end
    local class = Addon:GetCollectTypeClass(collectType)
    if not class then
        return
    end

    local target = GetFullName(target)
    local item = class:Get(id)
    if isAdd then
        item:AddRealmFeed(target)
    else
        item:DeleteRealmFeed(target)
    end
    self:SendMessage('COLLECTOR_REALM_FEED_UPDATE', collectType, id)
end

function Logic:ServerConnect()
    if self:IsCanConnect() then
        self:ConnectServer()
    end
    self:SendMessage('COLLECTOR_SERVER_STATUS_UPDATED', false)
end

function Logic:IsCanConnect()
    return not IsTrialAccount()
end

function Logic:SERVER_CONNECTED()
    self:SendServer('CMY', UnitGUID('player'), GetPlayerBattleTag(), ADDON_VERSION_SHORT, MountFilter:GetMountCount(), GetAddonSource(), DataCache:GetQueryData())
    self:SendMessage('COLLECTOR_SERVER_STATUS_UPDATED', true)
    -- print('server 连接成功，可以打开坐骑面板')
end

function Logic:QueryFriend(friend)
    if friend:IsCanQuery() and friend:IsQueryTimeOut() then
        self:SendServer('CRQ', friend:GetCharacter(), friend:GetBattleTag(), friend:GetToken())
        self:SendMessage('COLLECTOR_FRIEND_INFO_QUERIED', friend:GetToken())
    else
        self:SendMessage('COLLECTOR_FRIEND_INFO_UPDATE', friend:GetToken())
    end
end

function Logic:QueryPlan(plan)
    local item = plan:GetObject()

    if item:IsQueryTimeOut() then
        self:SendServer('CRP', plan:GetCollectType(), plan:GetID())
        self:SendMessage('COLLECTOR_WORLD_FEED_QUERIED', plan:GetToken())
    else
        self:SendMessage('COLLECTOR_WORLD_FEED_UPDATE', plan:GetToken())
    end
end

function Logic:SendBroadcast(collectType, id)
    local item = Addon:GetCollectTypeClass(collectType):Get(id)
    BNSetCustomMessage(format(L['我获得了%s [%s]'], '坐骑', item:GetName()))
end

function Logic:COLLECTOR_LEARNED(_, collectType, id, petID)
    self:SendServer('CLC', GetPlayerBattleTag(), collectType, id, petID)
    self:SendBroad('CLC', collectType, id)
end

function Logic:COLLECTOR_PLAN_ADDED(_, collectType, id)
    self:SendServer('CP', GetPlayerBattleTag(), collectType, id, true)
    self:SendBroad('CP', collectType, id, true)
end

function Logic:COLLECTOR_PLAN_DELETED(_, collectType, id)
    self:SendServer('CP', GetPlayerBattleTag(), collectType, id, false)
    self:SendBroad('CP', collectType, id, false)
end

function Logic:FRIEND_REQUEST_RESULT(_, feedData, planData, token)
    local friend = Friend:Get(token)
    friend:SetQueryStamp(time())
    friend:SetFeedList(DecodeCollectList(feedData))
    friend:SetPlanList(DecodeCollectList(planData))

    self:SendMessage('COLLECTOR_FRIEND_INFO_UPDATE', token)
end

function Logic:PLAN_REQUEST_RESULT(_, collectType, id, data)
    local item = Addon:GetCollectTypeClass(collectType):Get(id)
    local plan = Plan:Get(collectType, id)

    item:SetQueryStamp(time())
    item:SetWorldFeedList(DecodeTargetList(data))

    self:SendMessage('COLLECTOR_WORLD_FEED_UPDATE', plan:GetToken())
end

function Logic:SOCKET_DATA_VALUE(_, key, data)
    DataCache:SaveCache(key, data)
end
