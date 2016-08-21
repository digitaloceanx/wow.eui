
BuildEnv(...)

Mount = Addon:NewClass('Mount', BaseObject)
Mount.COLLECT_TYPE = COLLECT_TYPE_MOUNT
Mount.DB = MOUNT_DATA
Mount.BLIP_KEY = 'mountBlip'

function Mount:Constructor(id, mountId)
    self.mountId = mountId
end

function Mount:GetMountID()
    return self.mountId
end

function Mount:SetMountID(mountId)
    self.mountId = mountId
end

function Mount:GetStat()
    local isFavorite, _, _, hideOnChar, isCollected = select(7, C_MountJournal.GetMountInfoByID(self.mountId))
    return hideOnChar, isCollected, isFavorite, Profile:IsInPlan(COLLECT_TYPE_MOUNT, self.id)
end

function Mount:IsHideOnChar()
    return (select(10, C_MountJournal.GetMountInfoByID(self.mountId)))
end

function Mount:IsCollected()
    return (select(11, C_MountJournal.GetMountInfoByID(self.mountId)))
end

function Mount:Summon()
    C_MountJournal.SummonByID(self.mountId)
end

function Mount:Dismiss()
    C_MountJournal.Dismiss()
end

function Mount.Once:GetName()
    return (C_MountJournal.GetMountInfoByID(self.mountId))
end

function Mount.Once:GetIcon()
    return (select(3, C_MountJournal.GetMountInfoByID(self.mountId)))
end

function Mount.Once:GetLink()
    return (GetSpellLink(self.id))
end

function Mount.Once:GetDisplay()
    return (C_MountJournal.GetMountInfoExtraByID(self.mountId))
end

local Descriptions = {
    { key = 'Rarity',       name = L['稀有度：'] },
    { key = 'Walk',         name = L['行走方式：'] },
    { key = 'Passenger',    name = L['乘客类型：'] },
    { key = 'Model',        name = L['模型：'] },
    { key = 'Faction',      name = L['阵营：'] },
    { key = 'Source',       name = L['来源：'] },
}

function Mount.Once:GetSummary()
    local _, description, source = C_MountJournal.GetMountInfoExtraByID(self.mountId)

    local custom do
        local sb = {}
        for i, v in ipairs(Descriptions) do
            local attr = self:GetAttribute(v.key)
            if attr then
                local value = attr and MOUNT_FILTER_DATA[v.key][attr].text or UNKNOWN
                if value == L['游戏商城'] then
                    value = format('|Hstore:1|h|cff00ffff[%s]|r|h', value)
                end
                tinsert(sb, format('|cffffd200%s|r%s', v.name, value))
            end
        end
        custom = table.concat(sb, '\n')
    end

    local link = {}
    for i, v in ipairs(self:GetAchievementList()) do
        tinsert(link, GetAchievementLink(v:GetID()))
    end

    if #link > 0 then
        return custom .. '\n\n' .. source .. '\n' .. L['|cffffd200相关：|r'] .. table.concat(link) .. '\n\n' .. description
    else
        return custom .. '\n\n' .. source .. '\n\n' .. description
    end    
end

function Mount:IsValid()
    return not self:IsOutOfPrint() and not self:IsHideOnChar() and self:IsInHoliday()
end

function Mount.Once:GetSourceText()
    return (select(3, C_MountJournal.GetMountInfoExtraByID(self.mountId)))
end

function Mount:TogglePanel()
    return Addon:ToggleMountJournal(self)
end

function Mount:IsCanRecommend()
    return self:IsValid() and not self:IsCollected() and not self:IsInPlan()
end

function Mount.Once:GetRecommendDescription()
    return (select(3, C_MountJournal.GetMountInfoExtraByID(self.mountId))):gsub('%.[Bb][Ll][Pp]', ''):gsub('|n|n', '|n') .. '\n\n' .. L[self:GetRecommendKey()]
end

function Mount.Once:IsInTop20()
    local data = DataCache:GetObject('top20Data'):GetData()
    return data and data[self:GetID()]
end

function Mount:GetBlipIcon()
    return [[Interface\AddOns\Collector\Media\Mount]]
end

function Mount:GetTypeTexture()
    if self:GetAttribute('Faction') == 0 then
        return [[Interface\PetBattles\MountJournalicons]], 0.3828125, 0.7421875, 0.015625, 0.703125
    elseif self:GetAttribute('Faction') == 1 then
        return [[Interface\PetBattles\MountJournalicons]], 0.0078125, 0.3671875, 0.015625, 0.703125
    end
end

function Mount:GetTypeSize()
    return 46, 44
end

function Mount:GetLocale()
    return L['坐骑']
end

function Mount:NeedsFanfare()
    return C_MountJournal.NeedsFanfare(self.mountId) or self:IsNew()
end

function Mount:ClearFanfare()
    self:SetIsNew(false)
    C_MountJournal.ClearFanfare(self.mountId)
end

function Mount:IsActive()
    return (select(4, C_MountJournal.GetMountInfoByID(self.mountId)))
end
