--[[
@Date    : 2016-07-27 17:01:21
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]


BuildEnv(...)

DataLoader = Addon:NewModule('DataLoader', 'AceEvent-3.0')

function DataLoader:OnInitialize()
    self.co = nil
    self.list = {}

    self:RegisterMessage('COLLECTOR_PET_CACHED', 'OnEvent')
    self:RegisterMessage('COLLECTOR_MOUNT_CACHED', 'OnEvent')
end

function DataLoader:OnEvent(e, list)
    self:UnregisterMessage(e)

    for i, v in ipairs(list) do
        tinsert(self.list, v)
    end
    self:Start()
end

function DataLoader:Start()
    if self.co then
        return
    end

    local loaders = {
        [Mount] = {
            GetAcquireList = true,
            IsInHoliday = true,
            GetAchievementList = true,
            GetItemId = true,
            GetItemData = true,
            GetReputationData = true,
            GetReputation = true,
            GetReputationStanding = true,
            GetProgressObject = true,
            GetAreaList = 'in',
        },
        [Pet] = {
            GetAcquireList = true,
            IsInHoliday = true,
            GetAchievementList = true,
            GetItemId = true,
            GetItemData = true,
            GetReputationData = true,
            GetReputation = true,
            GetReputationStanding = true,
            GetProgressObject = true,
            GetAreaList = 'in',
        },
        [Npc] = {
            GetSoldList = true,
            GetDropList = true,
        },
        [GameObject] = {
            GetDropList = true,
        },
        [Area] = {
            GetNpcList = 'in',
            GetGameObjectList = 'in',
        },
    }

    local function sleep(n)
        C_Timer.After(n, function()
            if InCombatLockdown() then
                self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
                    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
                    coroutine.resume(self.co)
                end)
            else
                coroutine.resume(self.co)
            end
        end)
        return coroutine.yield()
    end

    local loaded = {}
    local function load(obj)
        if loaded[obj] then
            return
        end
        loaded[obj] = true

        sleep(0)

        for k, v in pairs(loaders[obj:GetType()]) do
            if InCombatLockdown() then
                sleep(0)
            end
            local r = obj[k](obj)
            if v == 'in' then
                for _, o in ipairs(r) do
                    load(o)
                end
            end
        end
    end

    self.co = coroutine.create(function()
        while true do
            local item = tremove(self.list, 1)
            if not item then
                break
            end
            load(item)
        end
        self.co = nil
        collectgarbage('collect')
        
    end)
    coroutine.resume(self.co)
end
