
BuildEnv(...)

Misc = Addon:NewModule('Misc', 'AceEvent-3.0', 'AceHook-3.0')

function Misc:OnInitialize()
    -- local NotCollectedCount = CollectionsMicroButton:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall') do
    --     NotCollectedCount:SetPoint('BOTTOM')
    -- end

    -- local NotCollectedFlash = GUI:GetClass('AlphaFlash'):New(CollectionsMicroButton) do
    --     NotCollectedFlash:SetPoint('TOPLEFT', -2, -18)
    --     NotCollectedFlash:SetSize(64, 64)
    --     NotCollectedFlash:SetTexture([[Interface\Buttons\Micro-Highlight]])
    --     NotCollectedFlash:Hide()
    -- end

    -- self.NotCollectedCount = NotCollectedCount
    -- self.NotCollectedFlash = NotCollectedFlash

    -- self:RegisterMessage('COLLECTOR_AREA_CHANGED')
    -- self:RegisterMessage('COLLECTOR_MOUNTLIST_UPDATE')

    local DropMenu = GUI:GetClass('DropMenu'):New(UIParent, 'MENU', true) do
        DropMenu.IsMouseOver = function()
            return DropDownList1:IsVisible()
        end
        DropMenu.AutoHide:SetCallback('OnUpdateCheck', function()
            return not DropDownList1.dropdown.unit
        end)
    end

    -- self:SecureHook('UnitPopup_HideButtons', function()
    --     if not UnitIsPlayer(UIDROPDOWNMENU_INIT_MENU.unit) then
    --         UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][1] = 0
    --     end
    -- end, true)

    -- self:SecureHook('UnitPopup_OnClick', function(self)
    --     if self.value == 'FIND_MOUNT' then
    --         print(111)
    --     end
    -- end, true)

    self:SecureHook('UnitPopup_ShowMenu', function(dropdownMenu, which, unit)
        if InCombatLockdown() then
            return
        end
        -- if UnitIsUnit('player', unit) then
        --     return
        -- end
        if not UnitIsPlayer(unit) then
            return
        end

        local spellID = self:FindUnitMount(unit)
        if not spellID then
            return
        end

        local mount = Mount:Get(spellID)

        DropMenu:Open(1, {
            {
                text = '魔兽达人',
                isTitle = true,
            },
            {
                text = mount:GetName(),
                func = function()
                    CloseDropDownMenus(1)
                    mount:TogglePanel()
                end
            }
        }, DropDownList1, 'TOPLEFT', DropDownList1, 'BOTTOMLEFT')
    end)

    CollectionsMicroButton:HookScript('OnEnter', function(button)
        if InCombatLockdown() then
            return
        end

        local mount, pet = Area:Get(Addon:GetCurrentAreaInfo()):GetNotCollectedCount()
        if mount > 0 or pet > 0 then
            GameTooltip:AddLine(format(L['你在当前区域有|cffffffff%d|r个未收集坐骑'], mount), 0.91, 0.47, 0.22)
            GameTooltip:AddLine(format(L['你在当前区域有|cffffffff%d|r个未收集宠物'], pet), 0.91, 0.47, 0.22)
            GameTooltip:Show()
        end
    end)
end

-- function Misc:OnEnable()
--     self:COLLECTOR_AREA_CHANGED()
-- end

-- function Misc:COLLECTOR_AREA_CHANGED()
--     local mount, pet = Area:Get(Addon:GetCurrentAreaInfo()):GetNotCollectedCount()
--     if mount == 0 then
--         self.NotCollectedFlash:Hide()
--         self.NotCollectedCount:SetText('')
--     else
--         self.NotCollectedFlash:Show()
--         self.NotCollectedCount:SetText(count)
--     end
-- end

-- function Misc:COLLECTOR_MOUNTLIST_UPDATE()
--     self.NotCollectedCount:SetText(Area:Get(Addon:GetCurrentAreaInfo()):GetNotCollectedCount())
-- end

function Misc:FindUnitMount(unit)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, i)
        if not name then
            break
        end
        if MOUNT_ID_TO_INDEX[spellID] then
            return spellID
        end
        i = i + 1
    end
end

-- UnitPopupButtons['FIND_MOUNT'] = { text = '查看玩家坐骑', dist = 0 }

-- tinsert(UnitPopupMenus['SELF'], 1, 'FIND_MOUNT')
-- tinsert(UnitPopupMenus['PARTY'], 1, 'FIND_MOUNT')
-- tinsert(UnitPopupMenus['PLAYER'], 1, 'FIND_MOUNT')
-- tinsert(UnitPopupMenus['RAID_PLAYER'], 1, 'FIND_MOUNT')
-- tinsert(UnitPopupMenus['RAID'], 1, 'FIND_MOUNT')
-- tinsert(UnitPopupMenus['TARGET'], 1, 'FIND_MOUNT')
-- tinsert(UnitPopupMenus['FOCUS'], 1, 'FIND_MOUNT')
