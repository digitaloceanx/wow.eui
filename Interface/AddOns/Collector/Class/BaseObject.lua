
BuildEnv(...)

BaseObject = Addon:NewClass('BaseObject', Object)

function BaseObject:Constructor(id)
    self.id = id
    self.realmFeed = {}
    self.worldFeed = {}
end

function BaseObject:GetID()
    return self.id
end

function BaseObject:IsInArea(map, lvl)
    for _, object in ipairs(self:GetAcquireList()) do
        if object:IsType(GameObject) and object:IsInArea(map, lvl) then
            return true
        end
    end
end

function BaseObject:IsInCurrentArea()
    return self:IsInArea(Addon:GetCurrentAreaInfo())
end

function BaseObject:IsInPlan()
    return Profile:IsInPlan(self.COLLECT_TYPE, self.id)
end

function BaseObject:IsInTrack()
    return Profile:IsInTrack(self.COLLECT_TYPE, self.id)
end

function BaseObject:SetIsNew(flag)
    self.isNew = flag or nil
end

function BaseObject:IsNew()
    return self.isNew
end

function BaseObject:GetAttribute(key)
    local method = 'Get' .. key
    if self[method] then
        return self[method](self)
    end
    return self.DB[self.id] and self.DB[self.id][key]
end

function BaseObject.Once:GetAcquireList()
    return GetAcquireList(self.DB, self.id, 'Acquire') or {}
end

function BaseObject:IsOutOfPrint()
    return self:GetAttribute('OutOfPrint')
end

function BaseObject.Once:IsInHoliday()
    local holiday = self:GetAttribute('Holiday')
    if not holiday then
        return true
    end
    return IsInHoliday(holiday)
end

function BaseObject.Once:GetAreaList()
    local results = {}
    local exists = {}

    for _, object in ipairs(self:GetAcquireList()) do
        if object:IsType(GameObject) then
            for _, area in ipairs(object:GetAreaList()) do
                if not exists[area] then
                    tinsert(results, area)
                    exists[area] = true
                end
            end
        end
    end
    
    sort(results)
    return results
end

function BaseObject.Once:GetAchievementList()
    return GetAcquireList(self.DB, self.id, 'Achievement') or {}
end

function BaseObject.Once:GetItemId()
    return GetItemData(self.DB, self.id) or false
end

function BaseObject.Once:GetItemData()
    return ITEM_DATA[self:GetItemId()] or false
end

function BaseObject.Once:GetReputationData()
    local itemData = self:GetItemData()

    if itemData and itemData.Reputation then
        return itemData.Reputation[GetPlayerSide()] or itemData.Reputation[0]
    end
    return false
end

function BaseObject.Once:GetReputation()
    local rd = self:GetReputationData()
    
    return rd and rd.Faction and GetFactionInfoByID(rd.Faction) and UnitRace('player') ~= rd.ExceptRace and Reputation:Get(rd.Faction) or false
end

function BaseObject.Once:GetReputationStanding()
    local rd = self:GetReputationData()

    return rd and rd.Standing or false
end

function BaseObject:GetAchievement()
    local list = self:GetAchievementList()
    if #list ~= 1 then
        return
    end
    return list[1]
end

function BaseObject:AddRealmFeed(target)
    self:DeleteRealmFeed(target)

    tinsert(self.realmFeed, 1, {
        target = GetFullName(target),
        stamp = time(),
    })

    -- for i = #self.realmFeed, 6, -1 do
    --     tremove(self.realmFeed, i)
    -- end
end

function BaseObject:DeleteRealmFeed(target)
    for i, v in ipairs(self.realmFeed) do
        if v.target == target then
            tremove(self.realmFeed, i)
        end
    end
end

function BaseObject:GetRealmFeedList()
    return self.realmFeed
end

function BaseObject:SetRealmFeedList(list)
    self.realmFeed = list
end

function BaseObject:SetWorldFeedList(list)
    self.worldFeed = list
end

function BaseObject:GetWorldFeedList()
    return self.worldFeed
end

function BaseObject:GetDBKey(withStamp)
    if withStamp then
        return format('%d:%d:%d', self.COLLECT_TYPE, self.id, self.queryStamp)
    end
    return format('%d:%d', self.COLLECT_TYPE, self.id)
end

function BaseObject:GetRealmFeedDB()
    if #self.realmFeed > 0 then
        return EncodeTargetList(self.realmFeed)
    end
end

function BaseObject:GetWorldFeedDB()
    if #self.worldFeed > 0 then
        return EncodeTargetList(self.worldFeed)
    end
end

function BaseObject:SetQueryStamp(stamp)
    self.queryStamp = stamp
end

function BaseObject:IsQueryTimeOut()
    return not self.queryStamp or time() - self.queryStamp > 86400
end

function BaseObject:IsCanKill()
    local item = self:GetItemData()
    if item then
        return IsBossCanKill(item.Instance, item.Boss, item.Difficulty)
    end
end

function BaseObject.Once:GetProgressObject()
    return self:GetReputation() or self:GetAchievement() or false
end

function BaseObject.Once:GetProgressName()
    local object = self:GetProgressObject()
    if object then
        return object:GetName()
    end
end

function BaseObject:GetProgressRate()
    local object = self:GetProgressObject()
    if object then
        return object:GetProgressRate(self:GetReputationStanding())
    end
end

function BaseObject:GetProgressColor()
    local object = self:GetProgressObject()
    if object then
        return object.GetStandingColor and object:GetStandingColor() or DEFAULT_STATUSBAR_COLOR
    end
end

function BaseObject:SetRecommend(flag, key)
    self.recommend = flag
    self.recommendKey = key
end

function BaseObject:IsRecommend()
    return self.recommend
end

function BaseObject:GetRecommendKey()
    return self.recommendKey
end

function BaseObject.Once:GetAreaMenu()
    local areaList = self:GetAreaList()
    local menuNode = {
        text = L['查看地图']
    }

    if #areaList > 1 then
        menuNode.hasArrow = true
        menuNode.menuTable = {}

        for _, area in ipairs(self:GetAreaList()) do
            tinsert(menuNode.menuTable, {
                text = area:GetName(),
                func = function()
                    Addon:ToggleWorldMap(area)
                end
            })
        end
    elseif #areaList == 1 then
        menuNode.func = function()
            Addon:ToggleWorldMap(areaList[1])
        end
    else
        menuNode.disabled = true
    end
    return menuNode
end

function BaseObject.Once:GetAchievementMenu()
    local list = self:GetAchievementList()
    local menuTable = {}
    if #list == 1 then
            tinsert(menuTable, {
                text = L['查看成就'],
                func = function()
                    list[1]:TogglePanel()
                end
            })
            tinsert(menuTable, {
                text = L['追踪成就'],
                func = function()
                    AddTrackedAchievement(list[1]:GetID())
                end
            })
    else
        local view = {}
        local track = {}
        for i, v in ipairs(list) do
            if not v:IsCompleted() then
                tinsert(view, v:GetAchievementMenu())
                tinsert(track, v:GetTrackMenu())
            end
        end
        tinsert(menuTable, {
            text = L['查看成就'],
            disabled = #view == 0,
            hasArrow = #view > 0,
            menuTable = view,
        })
        tinsert(menuTable, {
            text = L['追踪成就'],
            disabled = #track == 0,
            hasArrow = #track > 0,
            menuTable = track,
        })
    end

    return menuTable
end

function BaseObject:IsBlipValid()
    return Profile:GetVar(self.BLIP_KEY)
end

function BaseObject:GetCollectType()
    return self.COLLECT_TYPE
end
