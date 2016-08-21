local E, L, V, P, G, _ = unpack(ElvUI); --Engine

local AD = LibStub('AceAddon-3.0')
local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
local DisableAddOn = DisableAddOn
local EnableAddOn = EnableAddOn
local IsAddOnLoaded = IsAddOnLoaded
local SetCVar = SetCVar
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

local tmpToggle, tmpToggle2, tmpToggle3, tmpToggle4, tmpToggle5
E.Options.args.singleFunc = {
	type = "group",
	name = E.ValColor..'15.'..L['singleFunc']..'|r',
	desc = L['singleFunc desc'],
	childGroups = 'tree',
	get = function(info) return E.db.single[ info[#info] ] end,
	set = function(info, value) E.db.single[ info[#info] ] = value end,
	args = {
		EuiGarrisonHeader = {
			order = 0,
			type = "header",
			name = L["EuiGarrison"],
		},	
		EuiGarrison = {
			order = 1,
			type = 'execute',
			name = L["Enable/Disable"]..L["EuiGarrison"],
			func = function() 
				if E:IsConfigurableAddOn('EuiGarrison') then
					E:Print(L['Disabled']..L["EuiGarrison"]);
					DisableAddOn('EuiGarrison');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["EuiGarrison"]);
					EnableAddOn('EuiGarrison');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		gmm = {
			order = 2,
			type = 'toggle',
			name = L["GarrisonMissionManager"],
			get = function(info) return E.db.euiscript.gmm; end,
			set = function(info, value)
				E.db.euiscript.gmm = value;
				E:StaticPopup_Show("CONFIG_RL");
			end,
		},
		BodyGuardAway = {
			order = 3,
			type = 'toggle',
			name = L["BodyGuardAway"],
			name = L["Hold CTRL while clicking the bodyguard, show DiagFrame"],
			get = function(info) return E.db.euiscript.BodyGuardAway; end,
			set = function(info, value)
				E.db.euiscript.BodyGuardAway = value;
				EUIBODYGUARDAWAY:Toggle()
			end,
		},
		ExtraCDHeader = {
			order = 6,
			type = "header",
			name = L['ExtraCD'],
		},		
		ExtraCD = {
			order = 7,
			type = 'execute',
			name = L["Enable/Disable"]..L["ExtraCD"],
			func = function() 
				if E:IsConfigurableAddOn('ExtraCD') then
					E:Print(L['Disabled']..L["ExtraCD"]);
					DisableAddOn('ExtraCD');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["ExtraCD"]);
					EnableAddOn('ExtraCD');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		ShowExtraCDOpt = {
			order = 8,
			type = 'execute',
			name = L['Show ExtraCD Config'],
			disabled = function() return not IsAddOnLoaded('ExtraCD'); end,
			func = function()
				if not ExtraCD.optionFrames then
					ExtraCD:OnOptionCreate();
				end
				InterfaceOptionsFrame_OpenToCategory(ExtraCD.optionFrames.profiles)
				InterfaceOptionsFrame_OpenToCategory(ExtraCD.optionFrames.general)
				E:ToggleConfig();
			end,
		},
		HandyNotes_DraenorTreasuresHeader = {
			order = 9,
			type = "header",
			name = L['HandyNotes_DraenorTreasures'],
		},		
		HandyNotes_DraenorTreasures = {
			order = 10,
			type = 'execute',
			name = L["Enable/Disable"]..L["HandyNotes_DraenorTreasures"],
			func = function() 
				if E:IsConfigurableAddOn('HandyNotes_DraenorTreasures') then
					E:Print(L['Disabled']..L["HandyNotes_DraenorTreasures"]);
					DisableAddOn('HandyNotes_DraenorTreasures');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["HandyNotes_DraenorTreasures"]);
					EnableAddOn('HandyNotes_DraenorTreasures');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		ShowHandyNotes_DraenorTreasuresCfg = {
			order = 11,
			type = 'execute',
			name = L['Show HandyNotes_DraenorTreasures Config'],
			disabled = function() return not IsAddOnLoaded('HandyNotes_DraenorTreasures'); end,
			func = function()
				ACD:Open("HandyNotes");
				E:ToggleConfig();
			end,
		},	
		MikScrollingBattleTextHeader = {
			order = 12,
			type = "header",
			name = L['MikScrollingBattleText'],
		},		
		MikScrollingBattleText = {
			order = 13,
			type = 'execute',
			name = L["Enable/Disable"]..L["MikScrollingBattleText"],
			func = function() 
				if E:IsConfigurableAddOn('MikScrollingBattleText') then
					E:Print(L['Disabled']..L["MikScrollingBattleText"]);
					DisableAddOn('MikScrollingBattleText');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["MikScrollingBattleText"]);
					EnableAddOn('MikScrollingBattleText');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		ShowMSBTOpt = {
			order = 14,
			type = 'execute',
			name = L['Show MikScrollingBattleText Config'],
			disabled = function() return not IsAddOnLoaded('MikScrollingBattleText'); end,
			func = function()
				if E:IsDisabledAddon('MSBTOptions') then
					EnableAddOn('MSBTOptions')
					E:StaticPopup_Show("CONFIG_RL");
				end
				if (not IsAddOnLoaded('MSBTOptions')) then
					LoadAddOn('MSBTOptions');
				end
				if (IsAddOnLoaded('MSBTOptions')) then
					MSBTOptions.Main.ShowMainFrame();
					E:ToggleConfig();
				end
			end,					
		},		
		ToggleBlzCombat = {
			order = 15,
			type = 'toggle',
			name = L['Disable Blz CombatText'],
			get = function(info) return E.db.euiscript.disableBLZCombatText; end,
			set = function(info, value)
				E.db.euiscript.disableBLZCombatText = value;
				local toggle = "1"
				if value then toggle = "0"; end
				SetCVar("floatingCombatTextCombatHealing", toggle) --(此为治疗数字，把0改成1)
				SetCVar("floatingCombatTextCombatDamage", toggle) --(此为伤害数字，把0改成1)
				SetCVar("enableFloatingCombatText", toggle)
			end,
		},
		DBM_CoreHeader = {
			order = 16,
			type = "header",
			name = L['DBM-Core'],
		},			
--[[	DBM_Core = {
			order = 16,
			type = 'toggle',
			name = L['DBM-Core'],
			set = function(info, value)
				E.db.single.DBM_Core = value;
				if value then
					if E:IsConfigurableAddOn('DBM-Core') then
						if (not IsAddOnLoaded('DBM-Core')) then
							LoadAddOn('DBM-Core');
							LoadAddOn('DBM-StatusBarTimers')
							LoadAddOn('DBM-DefaultSkin')
						end
						if AddOnSkins then
							E.private.addonskins.DBM = true;
						end
					end
				else
					if E:IsConfigurableAddOn('DBM-Core') then
						if IsAddOnLoaded('DBM-Core') then
							E:StaticPopup_Show("CONFIG_RL");
							E.private.addonskins.DBM = false
						end
					end					
				end
			end,
		},]]
		ShowDBMOpt = {
			order = 17,
			type = 'execute',
			name = L['Show DBM Config'],
			disabled = function() return not IsAddOnLoaded('DBM-Core'); end,
			func = function()
				DBM:LoadGUI();
				E:ToggleConfig();
			end,					
		},
		TestDBMSound = {
			order = 18,
			type = 'execute',
			name = L['Test DBM Sound'],
			disabled = function() return not IsAddOnLoaded('DBM-Core'); end,
			func = function()
				if E:IsConfigurableAddOn('DBM-Core') then
					DBM:DemoMode();
					E:ToggleConfig();
				end
			end,
		},	
		OffileDataCenterHeader = {
			order = 19,
			type = "header",
			name = L['OffileDataCenter'],
		},		
		OffileDataCenter = {
			order = 20,
			type = 'execute',
			name = L["Enable/Disable"]..L["OffileDataCenter"],
			func = function() 
				if E:IsConfigurableAddOn('OffileDataCenter') then
					E:Print(L['Disabled']..L["OffileDataCenter"]);
					DisableAddOn('OffileDataCenter');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["OffileDataCenter"]);
					EnableAddOn('OffileDataCenter');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		ShowODCFrame = {
			order = 21,
			type = 'execute',
			name = L['Show OfflineDataCenter Frame'],
			disabled = function() return not IsAddOnLoaded('OffileDataCenter'); end,
			func = function()
				AD:GetAddon("OfflineDataCenter"):ToggleWindow();
				E:ToggleConfig();
			end,
		},
		ShowODCCfg = {
			order = 22,
			type = 'execute',
			name = L['Show OfflineDataCenter Config Frame'],
			disabled = function() return not IsAddOnLoaded('OffileDataCenter'); end,
			func = function()
				ODCFrameSettingSubFrame.configdialog:Click();
				E:ToggleConfig();
			end,
		},
		RaidBuilderHeader = {
			order = 23,
			type = "header",
			name = L['RaidBuilder'],
		},		
		RaidBuilder = {
			order = 24,
			type = 'execute',
			name = L["Enable/Disable"]..L["RaidBuilder"],
			func = function() 
				if E:IsConfigurableAddOn('MeetingStone') then
					E:Print(L['Disabled']..L["RaidBuilder"]);
					DisableAddOn('MeetingStone');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["RaidBuilder"]);
					EnableAddOn('MeetingStone');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		ShowRaidBuilderFrame = {
			order = 25,
			type = 'execute',
			name = L['Show RaidBuilder Config Frame'],
			disabled = function() return not IsAddOnLoaded('MeetingStone'); end,
			func = function()
				AD:GetAddon('MeetingStone'):ToggleModule('MainPanel');
				E:ToggleConfig();
			end,
		},
		ToggleRaidBuilderBrokerPanel = {
			order = 26,
			type = 'execute',
			name = L['Toggle RaidBuilder BrokerPanel'],
			disabled = function() return not IsAddOnLoaded('MeetingStone'); end,
			func = function()
				if AD:GetAddon('MeetingStone'):GetModule('DataBroker').BrokerPanel:IsShown() then
					AD:GetAddon('MeetingStone'):GetModule('DataBroker').BrokerPanel:Hide()
				else
					AD:GetAddon('MeetingStone'):GetModule('DataBroker').BrokerPanel:Show()
				end
			end,
		},		
		SkadaHeader = {
			order = 27,
			type = "header",
			name = L['Skada'],
		},
		Skada = {
			order = 28,
			type = 'execute',
			name = L["Enable/Disable"]..L["Skada"],
			func = function() 
				if E:IsConfigurableAddOn('Skada') then
					E:Print(L['Disabled']..L["Skada"]);
					DisableAddOn('Skada');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["Skada"]);
					EnableAddOn('Skada');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},			
		ShowSkadaConfig = {
			order = 29,
			type = 'execute',
			name = L['Show Skada Config Frame'],
			disabled = function() return not IsAddOnLoaded('Skada'); end,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(Skada.optionsFrame)
				InterfaceOptionsFrame_OpenToCategory(Skada.optionsFrame)
				E:ToggleConfig();
			end,
		},
		ToggleSkadaWindow = {
			order = 30,
			type = 'execute',
			name = L['Toggle Skada Window'],
			disabled = function() return not IsAddOnLoaded('Skada'); end,
			func = function()
				Skada:ToggleWindow();
				E:ToggleConfig();
			end,
		},
		ResetSkadaProfile = {
			order = 31,
			type = 'execute',
			width = 'full',
			name = L['Reset Skada Profile'],
			disabled = function() return not IsAddOnLoaded('Skada'); end,
			func = function()
				Skada.db:ResetProfile();
				E:ToggleConfig();
			end,
		},
		HPetBattleAnyHeader = {
			order = 41,
			type = "header",
			name = L["HPetBattleAny"],
		},
		HPetBattleAnyToggle = {
			order = 42,
			type = "execute",
			name = L["Enable/Disable"]..L["HPetBattleAny"],
			func = function()
				if E:IsConfigurableAddOn('HPetBattleAny') then
					E:Print(L['Disabled']..L["HPetBattleAny"]);
					DisableAddOn('HPetBattleAny');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["HPetBattleAny"]);
					EnableAddOn('HPetBattleAny');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		HPetBattleAnyFrame = {
			order = 43,
			type = "execute",
			name = L["HPetBattleAny Config Frame"],
			disabled = function() return not IsAddOnLoaded('HPetBattleAny'); end,
			func = function()
				if E:IsConfigurableAddOn('HPetBattleAny') then
					HPetOption:Toggle()
					E:ToggleConfig();
				end
			end,
		},
		RematchAnyHeader = {
			order = 45,
			type = "header",
			name = L["Rematch"],
		},
		RematchToggle = {
			order = 46,
			type = "execute",
			name = L["Enable/Disable"]..L["Rematch"],
			func = function()
				if E:IsConfigurableAddOn('Rematch') then
					E:Print(L['Disabled']..L["Rematch"]);
					DisableAddOn('Rematch');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["Rematch"]);
					EnableAddOn('Rematch');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		RematchFrame = {
			order = 47,
			type = "execute",
			name = L["Rematch Config Frame"],
			disabled = function() return not IsAddOnLoaded('Rematch'); end,
			func = function()
				if E:IsConfigurableAddOn('Rematch') then
					Rematch.Frame:Toggle()
					E:ToggleConfig();
				end
			end,
		},
		RareScannerHeader = {
			order = 51,
			type = "header",
			name = L['RareScanner'],
		},	
		RareScanner = {
			order = 52,
			type = 'execute',
			name = L["Enable/Disable"]..L["RareScanner"],
			func = function() 
				if E:IsConfigurableAddOn('RareScanner') then
					E:Print(L['Disabled']..L["RareScanner"]);
					DisableAddOn('RareScanner');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["RareScanner"]);
					EnableAddOn('RareScanner');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},	
		RareScannerConfigFrame = {
			order = 53,
			type = 'execute',
			name = L['RareScanner Config Frame'],
			disabled = function() return not IsAddOnLoaded('RareScanner'); end,
			func = function()
				if E:IsConfigurableAddOn('RareScanner') then
					InterfaceOptionsFrame_OpenToCategory(AD:GetAddon("RareScanner").optionsFrame)
					InterfaceOptionsFrame_OpenToCategory(AD:GetAddon("RareScanner").optionsFrame)
					E:ToggleConfig();
				end
			end,
		},	
		GearStatsSummaryHeader = {
			order = 57,
			type = "header",
			name = L['GearStatsSummary'],
		},
		GearStatsSummary = {
			order = 58,
			type = 'execute',
			name = L["Enable/Disable"]..L["GearStatsSummary"],
			func = function() 
				if E:IsConfigurableAddOn('GearStatsSummary') then
					E:Print(L['Disabled']..L["GearStatsSummary"]);
					DisableAddOn('GearStatsSummary');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["GearStatsSummary"]);
					EnableAddOn('GearStatsSummary');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},	
		IskarAssistHeader = {
			order = 59,
			type = "header",
			name = L['IskarAssist'],
		},
		IskarAssist = {
			order = 60,
			type = 'execute',
			name = L["Enable/Disable"]..L["IskarAssist"],
			func = function() 
				if E:IsConfigurableAddOn('IskarAssist') then
					E:Print(L['Disabled']..L["IskarAssist"]);
					DisableAddOn('IskarAssist');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["IskarAssist"]);
					EnableAddOn('IskarAssist');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		IskarAssistConfigFrame = {
			order = 61,
			type = 'execute',
			name = L['Toggle IskarAssist Frame'],
			disabled = function() return not IsAddOnLoaded('IskarAssist'); end,
			func = function()
				if E:IsConfigurableAddOn('IskarAssist') then
					SlashCmdList.IskarAssist('');
					E:ToggleConfig();
				end
			end,
		},
		IskarAssistResetFrame = {
			order = 62,
			type = 'execute',
			name = L['Reset IskarAssist Frame'],
			disabled = function() return not IsAddOnLoaded('IskarAssist'); end,
			func = function()
				if E:IsConfigurableAddOn('IskarAssist') then
					SlashCmdList.IskarAssist('resetpos');
					E:ToggleConfig();
				end
			end,
		},
		MapsterHeader = {
			order = 67,
			type = "header",
			name = L['Mapster'],
		},		
		Mapster = {
			order = 68,
			type = 'execute',
			name = L["Enable/Disable"]..L["Mapster"],
			func = function() 
				if E:IsConfigurableAddOn('Mapster') then
					E:Print(L['Disabled']..L["Mapster"]);
					DisableAddOn('Mapster');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["Mapster"]);
					EnableAddOn('Mapster');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		ShowMapsterFrame = {
			order = 69,
			type = 'execute',
			name = L['Show Mapster Frame'],
			disabled = function() return not IsAddOnLoaded('Mapster'); end,
			func = function()
				if not WorldMapFrame:IsShown() then
					ToggleWorldMap()
				end
				E:ToggleConfig();
			end,
		},	
		ToggleWorldFlightMap = {
			order = 70,
			type = 'toggle',
			name = L['Toggle World Flight Map'],
			disabled = function() return not IsAddOnLoaded('Mapster'); end,
			get = function() return E.db.SingleAddons.WorldFlightMap; end,
			set = function(info,value)
				if E:IsConfigurableAddOn('Mapster') then
					E.db.SingleAddons.WorldFlightMap = value;
					EUIWorldFlightMap_Toggle(value);
				end
			end,
		},
		OutfitterHeader = {
			order = 71,
			type = "header",
			name = L['Outfitter'],
		},
		Outfitter = {
			order = 72,
			type = 'execute',
			name = L["Enable/Disable"]..L["Outfitter"],
			func = function() 
				if E:IsConfigurableAddOn('Outfitter') then
					E:Print(L['Disabled']..L["Outfitter"]);
					DisableAddOn('Outfitter');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["Outfitter"]);
					EnableAddOn('Outfitter');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		OutfitterConfigFrame = {
			order = 73,
			type = 'execute',
			name = L['Toggle Outfitter Frame'],
			disabled = function() return not IsAddOnLoaded('Outfitter'); end,
			func = function()
				if E:IsConfigurableAddOn('Outfitter') then
					Outfitter:ToggleUI(true)
					E:ToggleConfig();
				end
			end,
		},
		TDDpsHeader = {
			order = 74,
			type = "header",
			name = L['TDDps'],
		},
		TDDps = {
			order = 75,
			type = 'execute',
			name = L["Enable/Disable"]..L["TDDps"],
			func = function() 
				if E:IsConfigurableAddOn('TDDps') then
					E:Print(L['Disabled']..L["TDDps"]);
					DisableAddOn('TDDps');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["TDDps"]);
					EnableAddOn('TDDps');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		TDDpsConfigFrame = {
			order = 76,
			type = 'execute',
			name = L['Toggle TDDps Frame'],
			disabled = function() return not IsAddOnLoaded('TDDps'); end,
			func = function()
				if E:IsConfigurableAddOn('TDDps') then
					InterfaceOptionsFrame_OpenToCategory(TDDps_Temp.optionFrame)
					InterfaceOptionsFrame_OpenToCategory(TDDps_Temp.optionFrame)
					E:ToggleConfig();
				end
			end,
		},
--[[		OregorgerTrackerHeader = {
			order = 62,
			type = "header",
			name = L['OregorgerTracker'],
		},
		OregorgerTracker = {
			order = 63,
			type = 'execute',
			name = L["Enable/Disable"]..L["OregorgerTracker"],
			func = function() 
				if E:IsConfigurableAddOn('OregorgerTracker') then
					E:Print(L['Disabled']..L["OregorgerTracker"]);
					DisableAddOn('OregorgerTracker');
					E:StaticPopup_Show("CONFIG_RL");
				else
					E:Print(L["Enabled"]..L["OregorgerTracker"]);
					EnableAddOn('OregorgerTracker');
					E:StaticPopup_Show("CONFIG_RL");
				end
			end,
		},
		OregorgerTrackerUnlock = {
			order = 64,
			type = 'execute',
			name = L['Unlock OregorgerTracker'],
			disabled = function() return not IsAddOnLoaded('OregorgerTracker'); end,
			func = function()
				if E:IsConfigurableAddOn('OregorgerTracker') then
					SlashCmdList["OREGORGERTRACKER"]('lock')
					E:Print(L["Drag arrow to move OregorgerTracker frame postion."])
				end
			end,
		},	
		OregorgerTrackerLock = {
			order = 65,
			type = 'execute',
			name = L['Lock OregorgerTracker'],
			disabled = function() return not IsAddOnLoaded('OregorgerTracker'); end,
			func = function()
				if E:IsConfigurableAddOn('OregorgerTracker') then
					SlashCmdList["OREGORGERTRACKER"]('lock')
				end
			end,
		},		]]
	},
}