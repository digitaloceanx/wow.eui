
BuildEnv(...)

Profile = Addon:NewModule('Profile', 'AceEvent-3.0', 'LibInvoke-1.0')

function Profile:OnInitialize()
    local db = {
        global = {
            firstLogin = true,
            planList = {},
            trackList = {},
            friend = {},
            realmFeed = {},
            worldFeed = {},
            serverData = {},
        },
        profile = {
            settings = {
                objectives = true,
                mountBlip = false,
                petBlip = false,
                autoTrack = true,
            },
            recommend = {},
            showRecomment = 0,
        }
    }

    self.planList = {}
    self.trackList = {}
    self.recommend = {}

    self.db = LibStub('AceDB-3.0'):New('COLLECTOR_DB', db)

    ---- old var
    self.db.profile.settings.blip = nil

    self.db.RegisterCallback(self, 'OnDatabaseShutdown')
end

function Profile.Invoke:OnEnable()
    ---- PlanList
    for i, v in ipairs(self.db.global.planList) do
        local plan = Plan:Get(split(v))
        if not plan:GetObject():IsCollected() then
            tinsert(self.planList, plan)
        end
    end

    ---- TrackList
    for i, v in ipairs(self.db.global.trackList) do
        local plan = Plan:Get(split(v))
        if not plan:GetObject():IsCollected() then
            tinsert(self.trackList, plan)
        end
    end

    ---- Friend Feed
    local bnids = {}
    for i = 1, BNGetNumFriends() do
        local id, _, battleTag = BNGetFriendInfo(i)
        if battleTag then
            bnids[battleTag] = id
        end
    end

    local function makeCollectList(list)
        for i, v in ipairs(list) do
            list[i] = Collect:New(split(v))
        end
        return list
    end

    for k, v in pairs(self.db.global.friend) do
        local id = not k:find('#', nil, true) and Ambiguate(k, 'none') or bnids[k] 
        if id then
            local friend = Friend:Get(id)
            friend:SetQueryStamp(v.queryStamp)
            friend:SetFeedList(makeCollectList(v.feedList))
            friend:SetPlanList(makeCollectList(v.planList))
        end
    end

    ---- Realm Feed
    local realm = self:GetCurrentRealm()
    do
        local db = self.db.global.realmFeed[realm]
        if db then
            for k, v in pairs(db) do
                local collectType, id = split(k)
                local item = Addon:GetCollectTypeClass(collectType):Get(id)

                item:SetRealmFeedList(DecodeTargetList(v))
            end
        end
    end

    ---- World Feed
    do
        for k, v in pairs(self.db.global.worldFeed) do
            local collectType, id, stamp = split(k)
            local item = Addon:GetCollectTypeClass(collectType):Get(id)

            item:SetQueryStamp(stamp)
            item:SetWorldFeedList(DecodeTargetList(v))
        end
    end
    
    ----- firstLogin
    if self.db.global.firstLogin then
        self.db.global.firstLogin = false
        self:SendMessage('COLLECTOR_FIRST_LOGIN')
    end

    ----- recommend
    do
        local key = date('%Y-%m-%d')
        if self.db.profile.recommend[key] then
            for _, line in ipairs(self.db.profile.recommend[key]) do
                local collectType, id, text = split(line)
                local item = Addon:GetCollectTypeClass(collectType):Get(id)
                item:SetRecommend(key, text)
            end
            self:SendMessage('COLLECTOR_RECOMMEND_UPDATE')
        end
    end

    ---- settings

    local keys = { 'mountBlip', 'petBlip', 'objectives', 'autoTrack' }

    for _, key in ipairs(keys) do
        self:SendMessage('COLLECTOR_SETTING_UPDATE', key, self:GetVar(key))
    end
end

function Profile:GetCurrentRealm()
    return (GetAutoCompleteRealms() or {GetRealmName()})[1]
end

function Profile:OnDatabaseShutdown()
    wipe(self.db.global.planList)
    wipe(self.db.global.trackList)
    wipe(self.db.global.friend)
    wipe(self.db.global.worldFeed)
    wipe(self.db.profile.recommend)

    for i, plan in ipairs(self.planList) do
        self.db.global.planList[i] = plan:GetToken()
    end

    for i, plan in ipairs(self.trackList) do
        self.db.global.trackList[i] = plan:GetToken()
    end

    ---- Friend Feed

    for _, friend in Friend:IterateObjects() do
        local key = friend:GetDBKey()
        if key and not friend:IsQueryTimeOut() then
            self.db.global.friend[key] = friend:ToDB()
        end
    end

    ---- Realm Feed

    local feedKlasses = { Mount, Pet }

    local realm = self:GetCurrentRealm()
    do
        local db = {}
        self.db.global.realmFeed[realm] = db

        for _, mount in Mount:IterateObjects() do
            db[mount:GetDBKey()] = mount:GetRealmFeedDB()
        end
    end

    ---- World Feed
    do
        for _, klass in ipairs(feedKlasses) do
            for _, obj in klass:IterateObjects() do
                if not obj:IsQueryTimeOut() then
                    self.db.global.worldFeed[obj:GetDBKey(true)] = obj:GetWorldFeedDB()
                end
            end
        end
    end

    ---- recommend
    do
        for _, mount in Mount:IterateObjects() do
            local key = mount:IsRecommend()
            if key then
                self.db.profile.recommend[key] = self.db.profile.recommend[key] or {}
                tinsert(self.db.profile.recommend[key], mount:GetDBKey() .. ':' .. mount:GetRecommendKey())
            end
        end
    end
end

function Profile:GetPlanList()
    return self.planList
end

function Profile:AddPlan(collectType, id)
    tinsert(self.planList, Plan:Get(collectType, id))

    self:SendMessage('COLLECTOR_PLAN_ADDED', collectType, id)
    self:SendMessage('COLLECTOR_PLANLIST_UPDATE')

    if self:GetVar('autoTrack') then
        self:AddTrack(collectType, id)
    end
end

function Profile:DelPlan(collectType, id)
    local plan = Plan:Get(collectType, id)
    local index = tIndexOf(self.planList, plan)
    if not index then
        return
    end

    tremove(self.planList, index)

    self:SendMessage('COLLECTOR_PLAN_DELETED', collectType, id)
    self:SendMessage('COLLECTOR_PLANLIST_UPDATE')

    self:DelTrack(collectType, id)
end

function Profile:AddOrDelPlan(collectType, id)
    if self:IsInPlan(collectType, id) then
        self:DelPlan(collectType, id)
    else
        self:AddPlan(collectType, id)
    end
end

function Profile:IsInPlan(collectType, id)
    return tContains(self.planList, Plan:Get(collectType, id))
end

function Profile:GetTrackList()
    return self.trackList
end

function Profile:AddTrack(collectType, id)
    tinsert(self.trackList, Plan:Get(collectType, id))

    self:SendMessage('COLLECTOR_TRACK_ADDED', collectType, id)
    self:SendMessage('COLLECTOR_TRACKLIST_UPDATE')
end

function Profile:DelTrack(collectType, id)
    tDeleteItem(self.trackList, Plan:Get(collectType, id))

    self:SendMessage('COLLECTOR_TRACK_DELETED', collectType, id)
    self:SendMessage('COLLECTOR_TRACKLIST_UPDATE')
end

function Profile:AddOrDelTrack(collectType, id)
    if self:IsInTrack(collectType, id) then
        self:DelTrack(collectType, id)
    else
        self:AddTrack(collectType, id)
    end
end

function Profile:IsInTrack(collectType, id)
    return tContains(self.trackList, Plan:Get(collectType, id))
end

function Profile:MovePlanToTop(collectType, id)
    local plan = Plan:Get(collectType, id)
    tDeleteItem(self.planList, plan)
    tinsert(self.planList, 1, plan)

    self:SendMessage('COLLECTOR_PLANLIST_UPDATE')
end

function Profile:GetServerData()
    return self.db.global.serverData
end

function Profile:SetVar(key, value)
    self.db.profile.settings[key] = value
    self:SendMessage('COLLECTOR_SETTING_UPDATE', key, value)
end

function Profile:GetVar(key)
    return self.db.profile.settings[key]
end

do
    local blipData = {
        { key = 'mountBlip', type = COLLECT_TYPE_MOUNT },
        { key = 'petBlip', type = COLLECT_TYPE_PET },
    }
    
    local blipKlassesCache = setmetatable({}, {__index = function(t, k)
        t[k] = {}
        for i, v in ipairs(blipData) do
            local b = bit.band(k, bit.lshift(1, i-1))
            if b > 0 then
                t[k][v.type] = true
            end
        end
        return t[k]
    end})

    function Profile:GetBlipClasses()
        local b = 0
        for i, v in ipairs(blipData) do
            if self:GetVar(v.key) then
                b = bit.bor(b, bit.lshift(1, i-1))
            end
        end
        return blipKlassesCache[b]
    end
end

function Profile:IsRecommendShown()
    local t = date('*t')
    t.hour = 0
    t.min = 0
    t.sec = 0
    t = time(t)
    local r = self.db.profile.showRecomment == t
    self.db.profile.showRecomment = t
    return r
end

