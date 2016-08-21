
BuildEnv(...)

Option = Addon:NewModule('Option', 'AceEvent-3.0')

function Option:OnInitialize()
    local _order = 0
    local function order()
        _order = _order + 1
        return _order
    end

    local options = {
        type = 'group',
        name = L['魔兽达人'],
        get = function(item)
            return Profile:GetVar(item[#item])
        end,
        set = function(item, value)
            Profile:SetVar(item[#item], value)
        end,
        args = {
            description = {
                type = 'description',
                name = select(3, GetAddOnInfo('Collector')) .. '\n',
                order = order(),
            },
            objectives = {
                type = 'toggle',
                name = L['显示追踪列表'],
                width = 'full',
                order = order(),
            },
            autoTrack = {
                type = 'toggle',
                name = L['添加到计划任务时自动追踪'],
                width = 'full',
                order = order(),
            },
        }
    }

    local registry = LibStub('AceConfigRegistry-3.0')
    registry:RegisterOptionsTable('Collector Options', options)
    
    local dialog = LibStub('AceConfigDialog-3.0')
    dialog:AddToBlizOptions('Collector Options', L['魔兽达人'])
end

function Option:Toggle()
    HideUIPanel(CollectionsJournal)
    InterfaceOptionsFrame_OpenToCategory(L['魔兽达人'])
    InterfaceOptionsFrame_OpenToCategory(L['魔兽达人'])
end
