
BuildEnv(...)

local Objectives = Addon:NewModule(ObjectiveTracker_GetModuleInfoTable(), 'Objectives', 'AceEvent-3.0', 'AceBucket-3.0', 'AceHook-3.0')

local function AnchorBlock(block, anchorBlock, checkFit)
    local module = block.module;
    local blocksFrame = module.BlocksFrame; 
    local offsetY = module.blockOffsetY;
    block:ClearAllPoints(); 
    if ( anchorBlock ) then
        if ( anchorBlock.isHeader ) then
            offsetY = module.fromHeaderOffsetY;
        end
        -- check if the block can fit
        if ( checkFit and (blocksFrame.contentsHeight + block.height - offsetY > blocksFrame.maxHeight) ) then
            return;
        end
        if ( block.isHeader ) then
            offsetY = offsetY + anchorBlock.module.fromModuleOffsetY;
            block:SetPoint("LEFT", OBJECTIVE_TRACKER_HEADER_OFFSET_X, 0);
        else
            block:SetPoint("LEFT", module.blockOffsetX, 0);     
        end
        block:SetPoint("TOP", anchorBlock, "BOTTOM", 0, offsetY);
    else
        offsetY = 0;
        -- check if the block can fit
        if ( checkFit and (blocksFrame.contentsHeight + block.height > blocksFrame.maxHeight) ) then
            return;
        end
        -- if the blocks frame is a scrollframe, attach to its scrollchild
        if ( block.isHeader ) then
            block:SetPoint("TOPLEFT", blocksFrame.ScrollContents or blocksFrame, "TOPLEFT", OBJECTIVE_TRACKER_HEADER_OFFSET_X, offsetY);
        else
            block:SetPoint("TOPLEFT", blocksFrame.ScrollContents or blocksFrame, "TOPLEFT", module.blockOffsetX, offsetY);
        end
    end
    return offsetY;
end

function Objectives:OnInitialize()
    self.updateReasonModule = 0x2000
    self.updateReasonEvents = 0
    self.usedBlocks = {}
    self.usedProgressBars = {}
    self:SetHeader(CreateFrame('Frame', nil, ObjectiveTrackerFrame.BlocksFrame, 'ObjectiveTrackerHeaderTemplate'), L['魔兽达人'], self.updateReasonModule)

    hooksecurefunc('ObjectiveTrackerProgressBar_SetValue', function(self, _, color)
        if not color then
            self.Bar:SetStatusBarColor(0.26, 0.42, 1)
        else
            self.Bar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end)
end

function Objectives:OnEnable()
    self:RegisterBucketEvent({'CALENDAR_UPDATE_EVENT_LIST', 'ENCOUNTER_END', 'BOSS_KILL'}, 1, function(event)
        RequestRaidInfo()
    end)

    self:RegisterBucketEvent({'UPDATE_FACTION', 'RECEIVED_ACHIEVEMENT_LIST'}, 1, 'UpdateProgressBar')

    self:RegisterMessage('COLLECTOR_TRACKLIST_UPDATE', 'Refresh')
    self:RegisterEvent('UPDATE_INSTANCE_INFO', 'Refresh')

    self:SecureHook('ObjectiveTracker_Update')

    if ObjectiveTrackerFrame.MODULES then
        self:Startup()
    else
        self:RegisterEvent('PLAYER_ENTERING_WORLD', function()
            self:UnregisterEvent('PLAYER_ENTERING_WORLD')
            self:Startup()
        end)
    end
end

function Objectives:OnDisable()
    self:Refresh()
    tDeleteItem(ObjectiveTrackerFrame.MODULES, self)
end

function Objectives:ObjectiveTracker_Update()
    if C_Scenario.IsInScenario() then
        return
    end
    if not BONUS_OBJECTIVE_TRACKER_MODULE.firstBlock or (not AUTO_QUEST_POPUP_TRACKER_MODULE.firstBlock and not QUEST_TRACKER_MODULE.firstBlock) then
        return
    end
    if ACHIEVEMENT_TRACKER_MODULE.firstBlock or not self.firstBlock then
        return
    end

    self.Header:ClearAllPoints()
    AnchorBlock(self.Header, BONUS_OBJECTIVE_TRACKER_MODULE.lastBlock)
end

function Objectives:Startup()
    tinsert(ObjectiveTrackerFrame.MODULES, self)
    self:Refresh()
end

function Objectives:Refresh()
    _G.ObjectiveTracker_Update(self.updateReasonModule)
end

function Objectives:UpdateProgressBar()
    for i, plan in ipairs(Profile:GetPlanList()) do
        local item = plan:GetObject()
        if item:GetProgressObject() then
            local block = self:GetExistingBlock(plan:GetToken())
            if block then
                local bar = self.usedProgressBars[block] and self.usedProgressBars[block][self:GetLine(block, 'ProgressBar')]
                if bar then
                    ObjectiveTrackerProgressBar_SetValue(bar, item:GetProgressRate() * 100, item:GetProgressColor())
                end
            end
        end
    end
end

function Objectives:_SetState(block, plan)
    local state = plan:GetObject():IsCanKill()
    if state == nil then
        return
    end

    local text
    local color
    if state == true then
        text = BOSS_ALIVE
        color = GREEN_FONT_COLOR
    elseif state == false then
        text = BOSS_DEAD
        color = RED_FONT_COLOR
    end
    if text then
        self:AddObjective(block, 'BossKill', text, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, color)
    end
end

function Objectives:Update()
    self:BeginLayout()
    self:Layout()
    self:EndLayout()
end

function Objectives:Layout()
    if not self:IsEnabled() then
        return
    end

    for i, plan in ipairs(Profile:GetTrackList()) do
        local block = self:GetBlock(plan:GetToken())
        local item = plan:GetObject()

        self:SetBlockHeader(block, item:GetName())
        
        self:_SetState(block, plan)

        if item:GetProgressObject() then
            self:AddProgressBar(block, self:AddObjective(block, 'ProgressBar', item:GetProgressName(), nil, nil, OBJECTIVE_DASH_STYLE_SHOW), item:GetProgressRate() * 100, item:GetProgressColor())
        end

        if not self:AddBlock(block) then
            break
        end
    end
end

function Objectives:AddBlock(block)
    local state = ObjectiveTracker_AddBlock(block)
    if state then
        block:Show()
        block:SetHeight(block.height)
        self:FreeUnusedLines(block)
    else
        block.used = false
    end
    return state
end

function Objectives:AddProgressBar(block, line, percent, color)
    local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line]
    if ( not progressBar ) then
        local numFreeProgressBars = #self.freeProgressBars
        local parent = block.ScrollContents or block
        if ( numFreeProgressBars > 0 ) then
            progressBar = self.freeProgressBars[numFreeProgressBars]
            tremove(self.freeProgressBars, numFreeProgressBars)
            progressBar:SetParent(parent)
            progressBar:Show()
        else
            progressBar = CreateFrame('Frame', nil, parent, 'ObjectiveTrackerProgressBarTemplate')
            progressBar.height = progressBar:GetHeight()
        end
        if ( not self.usedProgressBars[block] ) then
            self.usedProgressBars[block] = { }
        end
        self.usedProgressBars[block][line] = progressBar
        progressBar:Show()
        progressBar.Bar.Label:Hide()

        ObjectiveTrackerProgressBar_SetValue(progressBar, percent, color)
    end 
    -- anchor the status bar
    local anchor = block.currentLine or block.HeaderText
    if ( anchor ) then
        progressBar:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -block.module.lineSpacing)
    else
        progressBar:SetPoint('TOPLEFT', 0, -block.module.lineSpacing)
    end
    progressBar.block = block
    

    line.ProgressBar = progressBar
    block.height = block.height + progressBar.height + block.module.lineSpacing
    block.currentLine = progressBar
    return progressBar
end

function Objectives:OnBlockHeaderClick(block, button)
    local plan = Plan:GetByToken(block.id)
    if button == 'LeftButton' then
        if IsShiftKeyDown() then
            Profile:DelTrack(plan:GetCollectType(), plan:GetID())
        else
            Addon:TogglePlanPanel(plan)
        end
    elseif button == 'RightButton' then
        GUI:ToggleMenu(block, function()
            if plan:GetCollectType() == COLLECT_TYPE_MOUNT then
                return MountPanel:GetMountMenuTable(plan:GetObject())
            elseif plan:GetCollectType() == COLLECT_TYPE_PET then
                return PetPanel:GetPetMenuTable(plan:GetObject():GetID())
            end
        end, 'cursor')
    end
end
