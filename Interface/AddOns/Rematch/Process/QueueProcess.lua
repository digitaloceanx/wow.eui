-- this module handles all of the queue mechanics (QueuePanel handles the UI side)
-- this is one of the few modules that needs to run even when the panels aren't up

local _,L = ...
local rematch = Rematch
local settings
local queue -- the actual leveling queue (settings.LevelingQueue)

local levelingPets = {} -- indexed by petID, lookup table of leveling pets (created in ProcessQueue)
local levelingLoadouts = {} -- slots occupied with a leveling pet (that's not manually slotted)

rematch.topPicks = {} -- list of petIDs in the order they should be slotted
rematch.skippedPicks = {} -- list of petIDs skipped due to preferences (for queue panel update)

rematch:InitModule(function()
	settings = RematchSettings
	queue = settings.LevelingQueue
end)

-- returns true (and the precise level) of a petID if it can level
function rematch:PetCanLevel(petID)
	if rematch:GetIDType(petID)=="pet" then
		local _,_,level,xp,maxXp,_,_,_,_,_,_,_,_,_,canBattle = C_PetJournal.GetPetInfoByPetID(petID)
		if level and level<25 and canBattle then
			return true,level+(xp/maxXp)
		end
	end
end

function rematch:IsPetLeveling(petID)
	return levelingPets[petID] and true
end

-- direction is -2 for top, -1 for up, 1 for down, 2 for bottom
function rematch:MovePetInQueue(petID,direction)
	if direction==-2 then
		rematch:InsertPetToQueue(1,petID)
	elseif direction==2 then
		rematch:InsertPetToQueue(#queue+1,petID)
	else
		-- we're moving up or down one position
		local index -- first find its position
		for i=1,#queue do
			if queue[i]==petID then
				index = i
				break
			end
		end
		if direction==-1 and index>1 then
			rematch:InsertPetToQueue(index-1,petID)
		elseif direction==1 and index<#queue then
			rematch:InsertPetToQueue(index+2,petID)
		end
	end
	rematch:ShowQueue(petID)
end

function rematch:UpdateQueue()
	rematch.queueNeedsProcessed = true
	rematch:UpdateUI()
end

-- as a part of UpdateUI, this is where the queue updates: it removes any pets in the queue
-- that can't level (due to hitting 25 or no longer existing), it slots the most
-- preferred pet to any active leveling slots, and toasts when the leveling pet changes
-- NOTE: all places that used to call ProcessQueue directly should now call UpdateQueue!!
function rematch:ProcessQueue()

	if Rematch5 then -- prevent two queues from fighting
		rematch.queueNeedsProcessed = nil
		return
	end

	-- if pets not loaded, come back in half a second to try again
	local numPets,owned = C_PetJournal.GetNumPets()
	if numPets==0 or owned==0 then
		return -- if pets aren't loaded, then don't do anything yet
	end
	-- can't swap pets; queue on hold while in combat/battle/queued for pvp
	if settings.QueuePaused or InCombatLockdown() or C_PetBattles.IsInBattle() or C_PetBattles.GetPVPMatchmakingInfo() then
		rematch.queueNeedsProcessed = true
		return
	end
	rematch.queueNeedsProcessed = nil

	local oldTopPetID = rematch.topPicks[1] -- note top-most pet in queue

	-- fill levelingLoadouts with the petIDs in the slots they're currently loaded (if any)
	-- this is later used to verify the proper leveling petIDs are loaded (or to load new ones to these slots)
	for i=1,3 do
		levelingLoadouts[i] = rematch:IsSlotQueueControlled(i,rematch.outgoingQueuedPetID,true)
	end
	rematch.outgoingQueuedPetID = nil -- we can stop caring about any pets leaving queue

	-- remove any pets that can't level (missing or level 25) and fill levelingPets with those that can
	wipe(levelingPets)
	for i=#queue,1,-1 do
		local canLevel, level = rematch:ValidateQueuedPet(i)
		local petID = queue[i]
		if canLevel and level and not levelingPets[petID] then
			levelingPets[petID] = level
			rematch:AddToSanctuary(petID,true) -- add pet to sanctuary if it wasn't there or update its stats
		else
			tremove(queue,i) -- remove pets that can't level (or that are already in queue)
		end
	end

	-- sort leveling pets if active sort enabled
	if settings.QueueActiveSort then
		rematch:SortQueue()
	end

	-- populate topLevelingPicks
	wipe(rematch.topPicks)
	wipe(rematch.skippedPicks)
	-- pick out preferred pets first and save which pets are skipped
	for _,petID in ipairs(queue) do
		if rematch:IsPetPickable(petID) then
			if #rematch.topPicks<3 then
				tinsert(rematch.topPicks,petID)
			end
		else
			rematch.skippedPicks[petID] = true
		end
	end
	-- if top 3 picks not made, get top-most that aren't already picked
	for _,petID in ipairs(queue) do
		if #rematch.topPicks<3 then
			if not tContains(rematch.topPicks,petID) then
				tinsert(rematch.topPicks,petID)
			end
		else
			break -- don't need to run through rest of queue if top 3 chosen
		end
	end

	local levelingPetSlotted -- will become true if new leveling pets are loaded

	-- if petIDs in levelingLoadouts don't match topPicks, load them
	local pickIndex = 1
	for i=1,3 do
		local petID = levelingLoadouts[i]
		if petID then
			local pickID = rematch.topPicks[pickIndex]
			if pickID and pickID~=petID then
				levelingPetSlotted = true
				rematch:SlotPet(i,pickID)
			end
			pickIndex = pickIndex + 1
		end
	end

	-- toast leveling pet if it changed and toast passed
	if oldTopPetID and levelingPetSlotted and rematch.topPicks[1]~=oldTopPetID then
		rematch:ToastNextLevelingPet(rematch.topPicks[1])
	end

	if rematch.Roster:GetFilter("Other","Leveling") or rematch.Roster:GetFilter("Other","NotLeveling") then
		-- if pets are filtered for leveling pets, update the list with every ProcessQueue
		rematch.Roster.needsUpdated = true
	end
end

-- this returns whether the indexed pet in the queue can level and its level+xp/maxXP
-- it will look in the sanctuary for a replacement if petID is not valid
function rematch:ValidateQueuedPet(index)
	local petID = queue[index]
	local _,_,level,xp,maxXp,_,_,_,_,_,_,_,_,_,canBattle = C_PetJournal.GetPetInfoByPetID(petID)
	if level then -- petID is valid
		if level<25 and canBattle then
			return true,level+(xp/maxXp) -- pet can level (include its partial level)
		end
	else -- petID is not valid, pet is caged/released or its petID changed
		local newPetID,level = rematch:FindReplacementQueuePet(petID)
		if newPetID and level then
			queue[index] = newPetID -- replace queued petID with new one
			return true,level -- and return that it can level as if nothing happened
		end
	end
end

-- returns nil if the pet loaded in a loadoutslot (1-3) is not under queue control
-- returns the petID of the loaded pet if the slot should be under queue control
-- returns true if passed outgoingPetID leveling pet is in the slot
-- forProcessQueue is true when this is for the start of a ProcessQueue
function rematch:IsSlotQueueControlled(slot,outgoingPetID,forProcessQueue)
	local loadedTeam = RematchSaved[settings.loadedTeam]
	local petID = C_PetJournal.GetPetLoadOutInfo(slot)
	if not petID then
		return -- no pet loaded in this slot
	elseif loadedTeam and (loadedTeam[1][1]==petID or loadedTeam[2][1]==petID or loadedTeam[3][1]==petID) then
		return -- pets are saved as themselves in this slot, don't replace it (do nothing)
	elseif settings.ManuallySlotted[petID] then
		return -- pet was manually slotted, leave it alone
	elseif petID==outgoingPetID then
		return true -- special case for outgoing pet (it's not in queue) to replace
	elseif forProcessQueue and tContains(queue,petID) then
		-- otherwise if pet is in the queue, send back petID to mark it for replacement
		-- (need to tContains since new pets can be added to levelingPets table before this runs)
		return petID
	elseif levelingPets[petID] then
		return true -- if not for ProcessQueue then a quick lookup is preferred over tContains
	end
end

-- returns true if petID meets the conditions of the current preferences
function rematch:IsPetPickable(petID)
	local health,maxHealth = C_PetJournal.GetPetStats(petID)
	if C_PetJournal.PetIsSummonable(petID) or (health and health<1) then
		-- passed first test, pet is summonable (or dead)

		if health and settings.QueueSkipDead then
			if health<1 then
				return false -- Prefer Living Pets checked, don't want dead pets
			end
			if settings.QueuePreferFullHP and health<maxHealth then
				return false -- And At Full Health also checked, skip those too
			end
		end

		if settings.loadedTeam and not settings.QueueNoPreferences then
			local minHP = rematch:GetPrefStatValue("minHP",nil,nil,true)
			if minHP then
				local petType = select(10,C_PetJournal.GetPetInfoByPetID(petID))
				local expectedDD = rematch:GetPrefStatValue("expectedDD",nil,nil,true)
				if expectedDD then -- expected damage defined, adjust minHP for expected damage
					if rematch.hintsOffense[expectedDD][1]==petType then
						minHP = minHP*1.5
					elseif rematch.hintsOffense[expectedDD][2]==petType then
						minHP = minHP*2/3
					end
				end
				if health<=minHP then
					if not ((petType==6 or petType==10) and rematch:GetPrefStatValue("allowMM",nil,nil,true)) then
						return false -- if minHP defined, health is less than minHP and allowMM not enabled, failed
					end
				end
			end
			local maxHP = rematch:GetPrefStatValue("maxHP",nil,nil,true)
			if maxHP then
				if health>=maxHP then
					return false
				end
			end
			local maxXP = rematch:GetPrefStatValue("maxXP",nil,nil,true)
			if maxXP then
				local roundedXP = floor(maxXP)
				if roundedXP==maxXP and floor(levelingPets[petID])>roundedXP then
					return false -- if maxXP is a whole number, limit levels by whole numbers
				elseif roundedXP~=maxXP and levelingPets[petID]>maxXP then
					return false -- if maxXP has a partial level, limit levels by the same amount
				end
			end
			local minXP = rematch:GetPrefStatValue("minXP",nil,nil,true)
			if minXP then
				local roundedXP = floor(minXP)
				if roundedXP==minXP and floor(levelingPets[petID])<roundedXP then
					return false
				elseif roundedXP~=minXP and levelingPets[petID]<minXP then
					return false
				end
			end
		end
		return true
	end
end

-- this should be the only place to add/move a single pet in the queue
-- to add/move a pet to the top of the queue: index=1
-- to add/move a pet to the end of the queue: index=#queue+1
function rematch:InsertPetToQueue(index,petID)
	local isNew = true -- assume pet is new
	local oldQueueSize = #queue -- before we add something, note size of queue
	-- check if pet already exists in queue; if so replace it with a placeholder 0
	for i=1,#queue do
		if queue[i]==petID then
			isNew = nil -- it's not a new one
			queue[i] = 0 -- placeholder only, removing this index would change the size of the queue
		end
	end
	if index>0 then
		tinsert(queue,index,petID) -- insert pet into given index
	else
		tinsert(queue,petID) -- -1 index adds to end of queue
	end
	for i=#queue,1,-1 do
		if queue[i]==0 then
			tremove(queue,i) -- and remove where it existed before (if it existed before)
		end
	end
	if index==1 and settings.ManuallySlotted[petID] then
		settings.ManuallySlotted[petID] = nil -- if manually slotted pet is being sent to the start of the queue, remove its manually slotted status
	end
	if isNew and oldQueueSize<3 then -- queue was near empty, see if this new pet should be slotted for ProcessQueue to control
		rematch:MaybeSlotNewLevelingPet(petID)
	end
	rematch:UpdateQueue()
end

function rematch:RemovePetFromQueue(petID)
	for i=#queue,1,-1 do
		if queue[i]==petID then
			tremove(queue,i)
		end
	end
	rematch.outgoingQueuedPetID = petID -- note this pet for ProcessQueue within the UpdateUI
	rematch:UpdateQueue()
end

-- this should be the only place to add many pets to the end of the queue
-- petID is a list of petIDs to add {"BattlePet-0-etc","BattlePet-0-etc",etc}
function rematch:InsertManyPetsToQueue(petTable)
	local hasNew
	local oldQueueSize = #queue
	for _,petID in ipairs(petTable) do
		if not tContains(queue) then
			tinsert(queue,petID)
			hasNew = true
		end
	end
	if hasNew and oldQueueSize<3 then
		rematch:MaybeSlotNewLevelingPet(petTable[1],petTable[2],petTable[3])
	end
	rematch:UpdateQueue()
end

-- this is to be called in InsertPetToQueue and InsertManyPetsToQueue right before
-- ProcessQueue. if a loaded team has leveling pets assigned but no leveling pets
-- in their slots (for instance if queue is empty), then just before processing
-- the queue this will move the incoming petID(s) into a slot that doesn't already
-- have a petID
function rematch:MaybeSlotNewLevelingPet(...)
	for slot=1,select("#",...) do
		local petID = select(slot,...)
		local team = RematchSaved[settings.loadedTeam]
		if team and petID and (not C_PetJournal.PetIsSlotted(petID)) and (team[1][1]==0 or team[2][1]==0 or team[3][1]==0) then
			for i=1,3 do
				local loadedID = C_PetJournal.GetPetLoadOutInfo(i)
				if team[i][1]==0 and not rematch:IsPetLeveling(loadedID) then
					rematch:SlotPet(i,petID)
					return
				end
			end
		end
	end
end

-- pauses the queue for "user" (clicked pause button), "combat", "battle" or "pvp"
function rematch:PauseQueue(reason)
	if settings.QueuePaused=="user" then
		settings.userPausedQueue = true
	end
	settings.QueuePaused = reason
	rematch:UpdateUI()
end

-- to prevent timing issues, any resume request delays half a second to let transitions happen
function rematch:ResumeQueue(updateUI)
	rematch:StartTimer("ResumeQueue",0.5,updateUI and rematch.ResumeQueueWithUpdateUI or rematch.ResumeQueueBasic)
end

-- this is called just to clear/set the QueuePaused status without updating the UI
-- this is called after login (in case they logged out in battle on one character and logged in out of battle on another)
function rematch:ResumeQueueBasic()
	local reason
	if rematch.pvpProposalAccepted then return end
	if InCombatLockdown() then
		reason = "combat"
	elseif C_PetBattles.IsInBattle() then
		reason = "battle"
	elseif C_PetBattles.GetPVPMatchmakingInfo() then
		reason = "pvp"
	end
	settings.QueuePaused = reason
end

function rematch:ResumeQueueWithUpdateUI()
	rematch:ResumeQueueBasic()
	rematch:UpdateUI()
end

-- called in ProcessQueue for ActiveSort and from queue menu, performs a sort
function rematch:SortQueue()
	table.sort(queue,rematch.SortQueueTable)
end

-- table.sort where e1 and e2 are petIDs
-- Levels sort by level, then name, then petID.
-- Type sorts by type, then ascending level, then name, then petID.
function rematch.SortQueueTable(e1,e2)
	local order = settings.QueueSortOrder

	local name1, name2, type1, type2

	if order==4 then -- for type sort
		name1,_,type1 = select(8,C_PetJournal.GetPetInfoByPetID(e1))
		name2,_,type2 = select(8,C_PetJournal.GetPetInfoByPetID(e2))
		if type1 < type2 then
			return true
		elseif type1 > type2 then
			return false
		end
		-- if petType1 == petType2, continue to sort by level
	end

	local level1 = levelingPets[e1]
	local level2 = levelingPets[e2]
	if order==3 then -- for median sort, levels are distance from 10.5
		level1 = abs(level1-10.5)
		level2 = abs(level2-10.5)
	end
	if level1==level2 then -- if levels are the same, sort by their name next
		if not name1 then
			name1 = select(8,C_PetJournal.GetPetInfoByPetID(e1))
			name2 = select(8,C_PetJournal.GetPetInfoByPetID(e2))
		end
		if name1==name2 then -- if names are the same, sort by the petID for a stable sort
			return e1<e2
		else
			return name1<name2
		end
	else
		if order==2 then -- if descending, higher levels first
			return level1>level2
		else -- if ascending or median, lower levels (or distance from 10.5) first
			return level1<level2
		end
	end
end

function rematch:FillQueue(countOnly,fillMore)
	local species = rematch.info -- lookup table to see if we added this species already
	local roster = rematch.Roster
	local petTable = {} -- petIDs for InsertManyPetsToTable
	local count = 0
	wipe(species)
	local speciesAt25 = rematch:GetTempTable("SpeciesAt25")

	-- if fillMore is false, we don't want species that have a 25 version or are already in the queue.
	-- flag those species as already encountered
	if not fillMore then
		for _,petID in ipairs(roster.petList) do
			if type(petID)=="string" then
				local speciesID = C_PetJournal.GetPetInfoByPetID(petID)
				if rematch:IsPetLeveling(petID) or speciesAt25[speciesID] then
					species[speciesID] = true
				end
			end
		end
	end

	-- now add each un-encountered species from roster.petList (filtered list)
	for _,petID in ipairs(roster.petList) do
		if type(petID)=="string" then
			local speciesID = C_PetJournal.GetPetInfoByPetID(petID)
			-- if pet not already in queue, and not an encountered species, and it can level
			if not rematch:IsPetLeveling(petID) and not species[speciesID] and rematch:PetCanLevel(petID) then
				if not countOnly then
					tinsert(petTable,petID)
				end
				count = count + 1
				species[speciesID] = true
			end
		end
	end

	if not countOnly then
		rematch:InsertManyPetsToQueue(petTable)
	end
	rematch:WipeTempTables()
	return count
end

-- does a "criterea" toast to alert that the leveling pet has changed
function rematch:ToastNextLevelingPet(petID)
	if settings.HidePetToast then
		return -- aww :(
	end
	if not rematch.LevelingToastSystem then
		local function toastSetup(frame,petID)
			frame.Title:SetText(petID and L["Now leveling:"] or L["Rematch's leveling queue is empty"])
			frame.Name:SetText(petID and rematch:GetPetName(petID) or L["All done leveling pets!"])
			frame.Icon.Texture:SetTexture(petID and rematch:GetPetIcon(petID) or "Interface\\Icons\\INV_Pet_Achievement_WinAPetBattle")
		end
		rematch.LevelingToastSystem = AlertFrame:AddQueuedAlertFrameSubSystem("RematchLevelingToastTemplate", toastSetup, 2, 0)
	end
	rematch.LevelingToastSystem:AddAlert(petID)
end
