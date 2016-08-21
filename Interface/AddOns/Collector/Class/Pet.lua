
BuildEnv(...)

Pet = Addon:NewClass('Pet', BaseObject)
Pet.COLLECT_TYPE = COLLECT_TYPE_PET
Pet.DB = PET_DATA
Pet.BLIP_KEY = 'petBlip'

function Pet.Once:GetName()
    return (C_PetJournal.GetPetInfoBySpeciesID(self.id))
end

function Pet.Once:GetIcon()
    return (select(2, C_PetJournal.GetPetInfoBySpeciesID(self.id)))
end

function Pet.Once:GetPetType()
    return (select(3, C_PetJournal.GetPetInfoBySpeciesID(self.id)))
end

function Pet.Once:GetDisplay()
    return (select(12, C_PetJournal.GetPetInfoBySpeciesID(self.id)))
end

local Descriptions = {
    -- { key = 'Rarity',       name = L['稀有度：'] },
    { key = 'Trade',        name = L['交易：'],    api = function(self) return self:IsTradable() and 1 or 2 end },
    { key = 'Battle',       name = L['战斗：'],    api = function(self) return self:IsCanBattle() and 1 or 2 end },
}

function Pet.Once:GetSummary()
    local sourceText, description = select(5, C_PetJournal.GetPetInfoBySpeciesID(self.id))
    local custom do
        local sb = {}
        for i, v in ipairs(Descriptions) do
            local value = PET_JOURNAL_FILTER_TYPES[v.key][v.api and v.api(self) or self:GetAttribute(v.key)].text or UNKNOWN
            if value == L['游戏商城'] then
                value = format('|Hstore:1|h|cff00ffff[%s]|r|h', value)
            end
            tinsert(sb, format('|cffffd200%s|r%s', v.name, value))
        end
        custom = table.concat(sb, '\n')
    end
    return custom .. '\n\n' .. sourceText .. '\n' .. description
end

function Pet.Once:GetDescription()
    local sourceText, description, _, _, tradable, unique = select(5, C_PetJournal.GetPetInfoBySpeciesID(self.id))
    if not tradable then
        sourceText = sourceText .. '\n' .. format('|cffff1919%s|r', BATTLE_PET_NOT_TRADABLE)
    end
    if unique then
        sourceText = sourceText .. '\n' .. format('|cffffd200%s|r', ITEM_UNIQUE)
    end
    return sourceText .. '\n\n|cffffd200' .. description .. '|r'
end

function Pet.Once:GetSourceText()
    return (select(5, C_PetJournal.GetPetInfoBySpeciesID(self.id)))
end

function Pet.Once:IsCanBattle()
    return (select(8, C_PetJournal.GetPetInfoBySpeciesID(self.id))) or false
end

function Pet.Once:IsTradable()
    return (select(9, C_PetJournal.GetPetInfoBySpeciesID(self.id))) or false
end

function Pet.Once:GetAbility()
    local ability = 0
    local abilities = {} do
        C_PetJournal.GetPetAbilityList(self.id, abilities)
    end
    for _, id in ipairs(abilities) do
        ability = bit.bor(ability, bit.lshift(1, select(3, C_PetJournal.GetPetAbilityInfo(id)) - 1))
    end
    return ability
end

function Pet:IsCollected()
    return PetFilter:IsPetCollected(self.id)
end

function Pet:IsValid()
    return true
end

function Pet:IsHideOnChar()
    return false
end

function Pet:TogglePanel()
    return Addon:TogglePetJournal(self)
end

function Pet:GetBlipIcon()
    return GetPetTypeTexture(self:GetPetType()), 0.79687500, 0.49218750, 0.50390625, 0.65625000
end

function Pet:GetTypeTexture()
    if self:IsCanBattle() then
        return GetPetTypeTexture(self:GetPetType()), 0.00781250, 0.71093750, 0.74609375, 0.91796875
    end
end

function Pet:GetTypeSize()
    return 90, 44
end

function Pet:GetLocale()
    return L['小宠物']
end
