
BuildEnv(...)

local ServerDataCache = Addon:NewModule('ServerDataCache', 'AceEvent-3.0')

function ServerDataCache:OnInitialize()
    local top20Data = DataCache:NewObject('top20Data') do
        top20Data:SetCallback('OnCacheChanged', function(self, cache)
            local list = {split(cache)}
            local data = {}
            for i, v in ipairs(list) do
                data[v] = true
            end
            data.num = #list
            self:SetData(data)
        end)
    end
end
