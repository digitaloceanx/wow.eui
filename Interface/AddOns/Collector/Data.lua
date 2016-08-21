
BuildEnv(...)

L = LibStub('AceLocale-3.0'):GetLocale('Collector')

_G.BINDING_NAME_COLLECTOR_TOGGLE = L['打开/关闭Collector']
_G.BINDING_HEADER_NETEASE = '网易插件'
_G.BINDING_HEADER_COLLECTOR = 'Collector'

ADDON_NAME = ...
ADDON_LOGO = [[Interface\AddOns\]] .. ADDON_NAME .. [[\Media\Logo]]
ADDON_VERSION = GetAddOnMetadata(ADDON_NAME, 'Version')
ADDON_VERSION_SHORT = ADDON_VERSION:gsub('(%d)%d(%d)%d%d%.(%d%d)','%1%2%3')

ADDON_REGIONSUPPORT = GetCurrentRegion() == 5
ADDON_SERVER = 'S1' .. UnitFactionGroup('player')

COLLECT_TYPE_MOUNT = 1
COLLECT_TYPE_PET = 2

PLAYER_FACTION = UnitFactionGroup('player')
NOT_PLAYER_FACTION = PLAYER_FACTION == 'Alliance' and 0 or 1

WOW_FRIEND_NAME_TO_INDEX = {}

COLLECTIONS_DATAS = {
    Mount = MOUNT_DATA,
    Pet = PET_DATA,
}

-- BATTLE_PET_SOURCE_1 = "掉落";
-- BATTLE_PET_SOURCE_10 = "游戏商城";
-- BATTLE_PET_SOURCE_2 = "任务";
-- BATTLE_PET_SOURCE_3 = "商人";
-- BATTLE_PET_SOURCE_4 = "专业技能";
-- BATTLE_PET_SOURCE_5 = "宠物对战";
-- BATTLE_PET_SOURCE_6 = "成就";
-- BATTLE_PET_SOURCE_7 = "世界事件";
-- BATTLE_PET_SOURCE_8 = "特殊";
-- BATTLE_PET_SOURCE_9 = "集换卡牌游戏";

MOUNT_JOURNAL_FILTER_TYPES = {
    -- Favorite = {
    --     { id = 1, text = L['偏好'] },
    --     { id = 2, text = L['非偏好'] },
    -- },
    -- Plan = {
    --     { id = 1, text = L['计划'] },
    --     { id = 2, text = L['非计划'] },
    -- },
    Faction = {
        { id = 0, text = L['部落'] },
        { id = 1, text = L['联盟'] },
        { id = 2, text = L['中立'] },
    },
    Walk = {
        { id = 1, text = L['地面'] },
        { id = 2, text = L['飞行'] },
        { id = 3, text = L['水上'] },
        { id = 4, text = L['游泳'] },
    },
    Model = {
        { id =  1, text = L['马'] },
        { id =  2, text = L['猫'] },
        { id =  3, text = L['狼'] },
        { id =  4, text = L['熊'] },
        { id =  5, text = L['羊'] },
        { id =  6, text = L['龟'] },
        { id =  7, text = L['猪'] },
        { id =  8, text = L['龙'] },
        { id =  9, text = L['鸟'] },
        { id = 39, text = L['鹿'] },
        { id = 10, text = L['雷象'] },
        { id = 11, text = L['牦牛'] },
        { id = 12, text = L['骆驼'] },
        { id = 13, text = L['水黾'] },
        { id = 14, text = L['摩托'] },
        { id = 15, text = L['蝎子'] },
        { id = 17, text = L['狮鹫'] },
        { id = 18, text = L['翔龙'] },
        { id = 19, text = L['龙鹰'] },
        { id = 20, text = L['火鹰'] },
        { id = 21, text = L['风筝'] },
        { id = 22, text = L['飞毯'] },
        { id = 16, text = L['水生'] },
        { id = 40, text = L['雪人'] },
        { id = 41, text = L['戈隆'] },
        { id = 23, text = L['骷髅马'] },
        { id = 24, text = L['迅猛龙'] },
        { id = 25, text = L['恐角龙'] },
        { id = 26, text = L['淡水兽'] },
        { id = 27, text = L['猛犸象'] },
        { id = 28, text = L['科多兽'] },
        { id = 29, text = L['穆山兽'] },
        { id = 30, text = L['裂蹄牛'] },
        { id = 31, text = L['陆行鸟'] },
        { id = 32, text = L['角鹰兽'] },
        { id = 33, text = L['虚空鳐'] },
        { id = 34, text = L['飞行器'] },
        { id = 42, text = L['地狱火'] },
        { id = 35, text = L['双足飞龙'] },
        { id = 36, text = L['机械陆行鸟'] },
        { id = 37, text = L['其拉作战坦克'] },
        { id = 38, text = L['其它'] },
    },
    Rarity = {
        { id = 1, text = L['极稀有'], tip = L['少于5%玩家拥有'], color = 'ff6600' },
        { id = 2, text = L['稀有'],   tip = L['少于10%玩家拥有'], color = 'ff00cc' },
        { id = 3, text = L['普通'],   tip = L['少于25%玩家拥有'], color = '00ffff' },
        { id = 4, text = L['大众'],   tip = L['超过25%玩家拥有'], color = '00ff00' },
    },
    Passenger = {
        { id = 1, text = L['无'] },
        { id = 2, text = L['NPC'] },
        { id = 3, text = L['玩家'] },
    },
    Source = {
    },
}

PET_JOURNAL_FILTER_TYPES = {
    LevelRange = {
        isOwned = true,
        { id = 1, text = '1' },
        { id = 2, text = '2-10' },
        { id = 3, text = '11-20' },
        { id = 4, text = '21-24' },
        { id = 5, text = '25' },
    },
    Ability = {
        isBit = true,
    },
    Quality = {
        isOwned = true,
        { id = 1, text = format('|c%s%s|r', select(4, GetItemQualityColor(0)), BATTLE_PET_BREED_QUALITY1) },
        { id = 2, text = format('|c%s%s|r', select(4, GetItemQualityColor(1)), BATTLE_PET_BREED_QUALITY2) },
        { id = 3, text = format('|c%s%s|r', select(4, GetItemQualityColor(2)), BATTLE_PET_BREED_QUALITY3) },
        { id = 4, text = format('|c%s%s|r', select(4, GetItemQualityColor(3)), BATTLE_PET_BREED_QUALITY4) },
    },
    Trade = {
        { id = 1, text = L['可交易'] },
        { id = 2, text = L['不可交易'] },
    },
    Battle = {
        { id = 1, text = L['可战斗'] },
        { id = 2, text = L['不可战斗'] },
    },
}

MOUNT_FILTER_DATA = {}
PET_FILTER_DATA = {}
MOUNT_ID_TO_INDEX = {}

do
    for _, id in ipairs(C_MountJournal.GetMountIDs()) do
        local name, spellID, _, _, _, sourceType, _, isFactionSpecific, faction = C_MountJournal.GetMountInfoByID(id)

        MOUNT_DATA[spellID] = MOUNT_DATA[spellID] or {}

        sourceType = MOUNT_DATA[spellID] and MOUNT_DATA[spellID].Source or sourceType
        
        MOUNT_ID_TO_INDEX[spellID] = id
        
        MOUNT_DATA[spellID].Source = sourceType
        MOUNT_DATA[spellID].Faction = not isFactionSpecific and 2 or faction
    end

    for i = 1, C_PetJournal.GetNumPetSources() do
        local data = {
            id = i,
            text = _G['BATTLE_PET_SOURCE_' .. i]
        }
        tinsert(MOUNT_JOURNAL_FILTER_TYPES.Source, data)
    end

    for i = 1, C_PetJournal.GetNumPetTypes() do
        local data = {
            id = i,
            text = _G['BATTLE_PET_NAME_' .. i],
        }
        tinsert(PET_JOURNAL_FILTER_TYPES.Ability, data)
    end

    local function MakeFilterData(types, data)
        for k, v in pairs(types) do
            data[k] = data[k] or {}
            
            for i, v in ipairs(v) do
                data[k][v.id] = v
            end
        end
    end

    MakeFilterData(MOUNT_JOURNAL_FILTER_TYPES, MOUNT_FILTER_DATA)
    MakeFilterData(PET_JOURNAL_FILTER_TYPES, PET_FILTER_DATA)
end

MAP_FILE_TO_ID = {} do
    for _, id in ipairs(GetAreaMaps()) do
        -- SetMapByID(id)

        local file = select(2, GetAreaMapInfo(id))
        -- if id == GetCurrentMapAreaID() then
            MAP_FILE_TO_ID[file] = id
        -- elseif not MAP_FILE_TO_ID[file] then
        --     MAP_FILE_TO_ID[file] = id
        -- end
    end
end

RECOMMEND_LIST = {
    'Rarity:1',
    'Top20List',
    'ProgressRate',
    'Cool',
    'Easy',
}

DEFAULT_STATUSBAR_COLOR = {
    r = 0.26, g = 0.42, b = 1
}

RARITY_DATA = {
    [1] = { text = L['|cffff6600极稀有|r'], tip = L['少于5%玩家拥有'] },
    [2] = { text = L['|cffff00cc稀有|r'],   tip = L['少于10%玩家拥有'] },
    [3] = { text = L['|cff00ffff普通|r'],   tip = L['少于25%玩家拥有'] },
    [4] = { text = L['|cff00ff00大众|r'],   tip = L['超过25%玩家拥有'] },
}

MODEL_SORT_ORDER = {} do
    local order = 1
    for i, v in ipairs(MOUNT_JOURNAL_FILTER_TYPES.Model) do
        MODEL_SORT_ORDER[v.id] = order
        order = order + 1
    end
end
