﻿local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule("Distributor")
local B = E:GetModule("Blizzard")
local AceGUI = LibStub("AceGUI-3.0")

local tsort, tinsert = table.sort, table.insert
local floor, ceil = math.floor, math.ceil
local format = string.format
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
local AC = LibStub("AceConfig-3.0-ElvUI")
local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
local ACR = LibStub("AceConfigRegistry-3.0-ElvUI")

AC:RegisterOptionsTable("ElvUI", E.Options)
ACD:SetDefaultSize("ElvUI", DEFAULT_WIDTH, DEFAULT_HEIGHT)

--Function we can call on profile change to update GUI
function E:RefreshGUI()
	self:RefreshCustomTextsConfigs()
	ACR:NotifyChange("ElvUI")
end
E.Options.name = E.UIName
E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = L["Version"]..format(": |cff99ff33%s|r",E.version).." Build"..format(": |cffFFFFFF%s|r",E.build),
		width = "full",
	},
	LoginMessage = {
		order = 2,
		type = 'toggle',
		name = L["Login Message"],
		get = function(info) return E.db.general.loginmessage end,
		set = function(info, value) E.db.general.loginmessage = value end,
	},
	ToggleTutorial = {
		order = 3,
		type = 'execute',
		name = L["Toggle Tutorials"],
		func = function() E:Tutorials(true); E:ToggleConfig()  end,
	},
	Install = {
		order = 4,
		type = 'execute',
		name = L["Install"],
		desc = L["Run the installation process."],
		func = function() E:Install(); E:ToggleConfig() end,
	},
	ToggleAnchors = {
		order = 5,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:ToggleConfigMode() end,
	},
	ResetAllMovers = {
		order = 6,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI() end,
	},
}

E.Options.args.general = {
	type = "group",
	name = '01.'..L["General"],
	order = 1,
	childGroups = "tab",
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,
	args = {
		animateConfig = {
			order = 1,
			type = "toggle",
			name = L["Animate Config"],
			get = function(info) return E.global.general.animateConfig end,
			set = function(info, value) E.global.general.animateConfig = value; E:StaticPopup_Show("GLOBAL_RL") end,
		},
		spacer = {
			order = 2,
			type = "description",
			name = "",
			width = "full",
		},
		intro = {
			order = 3,
			type = "description",
			name = L["ELVUI_DESC"]:gsub('ElvUI', E.UIName),
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				pixelPerfect = {
					order = 2,
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					type = 'toggle',
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				interruptAnnounce = {
					order = 3,
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['SAY'] = SAY,
						['PARTY'] = L["Party Only"],
						['RAID'] = L["Party / Raid"],
						['RAID_ONLY'] = L["Raid Only"],
						["EMOTE"] = CHAT_MSG_EMOTE,
					},
				},
				autoRepair = {
					order = 4,
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['GUILD'] = GUILD,
						['PLAYER'] = PLAYER,
					},
				},
				autoAcceptInvite = {
					order = 5,
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."],
					type = 'toggle',
				},
				vendorGrays = {
					order = 6,
					name = L["Vendor Grays"],
					desc = L["Automatically vendor gray items when visiting a vendor."],
					type = 'toggle',
				},
				autoRoll = {
					order = 7,
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					type = 'toggle',
					disabled = function() return not E.private.general.lootRoll end
				},
				loot = {
					order = 8,
					type = "toggle",
					name = L["Loot"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				lootRoll = {
					order = 9,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoScale = {
					order = 10,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",
					get = function(info) return E.global.general.autoScale end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				minUiScale = {
					order = 11,
					type = "range",
					name = L["Lowest Allowed UI Scale"],
					min = 0.32, max = 0.64, step = 0.01,
					get = function(info) return E.global.general.minUiScale end,
					set = function(info, value) E.global.general.minUiScale = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				uiscale = {
					order = 12,
					name = L["UI Scale"],
					desc = L["Controls the scaling of the entire User Interface"],
					disabled = function(info) return E.global.general.autoScale end,
					type = "range",
					min = 0.64, max = 1.15, step = 0.01,
					isPercent = true,
					set = function(info, value) SetCVar("uiScale", value); E:StaticPopup_Show('CONFIG_RL') end,
					get = function() return tonumber(format('%.2f', GetCVar('uiScale'))) end,
				},
				eyefinity = {
					order = 13,
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					type = "toggle",
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				hideErrorFrame = {
					order = 14,
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					type = "toggle"
				},
				taintLog = {
					order = 15,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				bottomPanel = {
					order = 16,
					type = 'toggle',
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.bottomPanel end,
					set = function(info, value) E.db.general.bottomPanel = value; E:GetModule('Layout'):BottomPanelVisibility() end
				},
				topPanel = {
					order = 16,
					type = 'toggle',
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.topPanel end,
					set = function(info, value) E.db.general.topPanel = value; E:GetModule('Layout'):TopPanelVisibility() end
				},
				afk = {
					order = 17,
					type = 'toggle',
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					get = function(info) return E.db.general.afk end,
					set = function(info, value) E.db.general.afk = value; E:GetModule('AFK'):Toggle() end

				},
				enhancedPvpMessages = {
					order = 18,
					type = 'toggle',
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				disableTutorialButtons = {
					order = 19,
					type = 'toggle',
					name = L["Disable Tutorial Buttons"],
					desc = L["Disables the tutorial button found on some frames."],
					get = function(info) return E.global.general.disableTutorialButtons end,
					set = function(info, value) E.global.general.disableTutorialButtons = value; E:StaticPopup_Show("GLOBAL_RL") end,
				},
				talkingHeadFrameScale = {
					order = 20,
					type = "range",
					name = L["Talking Head Scale"],
					isPercent = true,
					min = 0.5, max = 2, step = 0.01,
					get = function(info) return E.db.general.talkingHeadFrameScale end,
					set = function(info, value) E.db.general.talkingHeadFrameScale = value; B:ScaleTalkingHeadFrame() end,
				},
				objectiveFrameHeaderSpacing = {
					order = 29,
					type = "description",
					name = " ",
				},
				objectiveFrameHeader = {
					order = 30,
					type = "header",
					name = L["Objective Frame"],
				},
				objectiveFrameHeight = {
					order = 31,
					type = 'range',
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					get = function(info) return E.db.general.objectiveFrameHeight end,
					set = function(info, value) E.db.general.objectiveFrameHeight = value; E:GetModule('Blizzard'):ObjectiveFrameHeight(); end,
				},
				bonusObjectivePosition = {
					order = 32,
					type = 'select',
					name = L["Bonus Reward Position"],
					desc = L["Position of bonus quest reward frame relative to the objective tracker."],
					get = function(info) return E.db.general.bonusObjectivePosition end,
					set = function(info, value) E.db.general.bonusObjectivePosition = value; end,
					values = {
						['RIGHT'] = L["Right"],
						['LEFT'] = L["Left"],
						['AUTO'] = L["Auto"],
					},
				},
				threatHeaderSpacing = {
					order = 39,
					type = "description",
					name = " ",
				},
				threatHeader = {
					order = 40,
					type = "header",
					name = L["Threat"],
				},
				threatEnable = {
					order = 41,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return E.db.general.threat.enable end,
					set = function(info, value) E.db.general.threat.enable = value; E:GetModule('Threat'):ToggleEnable()end,
				},
				threatPosition = {
					order = 42,
					type = 'select',
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						['LEFTCHAT'] = L["Left Chat"],
						['RIGHTCHAT'] = L["Right Chat"],
					},
					get = function(info) return E.db.general.threat.position end,
					set = function(info, value) E.db.general.threat.position = value; E:GetModule('Threat'):UpdatePosition() end,
				},
				threatTextSize = {
					order = 43,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
					get = function(info) return E.db.general.threat.textSize end,
					set = function(info, value) E.db.general.threat.textSize = value; E:GetModule('Threat'):UpdatePosition() end,
				},
			},
		},
		media = {
			order = 5,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[ info[#info] ] end,
			set = function(info, value) E.db.general[ info[#info] ] = value end,
			args = {
				fontHeader = {
					order = 1,
					type = "header",
					name = L["Fonts"],
				},
				fontSize = {
					order = 2,
					name = L["Font Size"],
					desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
					type = "range",
					min = 4, max = 212, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				questfontSize = {
					order = 3,
					name = L["Quest Font Size"],
					type = "range",
					min = 4, max = 22, step = 1,
					set = function(info, value) ObjectiveFont:SetFont(E.media.normFont,value);E.db.general.questfontSize=value; end,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 4,
					name = L["Default Font"],
					desc = L["The font that the core of the UI will use."],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				applyFontToAll = {
					order = 5,
					type = 'execute',
					name = L["Apply Font To All"],
					desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
					func = function()
						local font = E.db.general.font
						local fontSize = E.db.general.fontSize

						E.db.bags.itemLevelFont = font
						E.db.bags.itemLevelFontSize = fontSize
						E.db.bags.countFont = font
						E.db.bags.countFontSize = fontSize
						E.db.nameplates.font = font
						--E.db.nameplate.fontSize = fontSize --Dont use this because nameplate font it somewhat smaller than the rest of the font sizes
						--E.db.nameplate.buffs.font = font
						--E.db.nameplate.buffs.fontSize = fontSize  --Dont use this because nameplate font it somewhat smaller than the rest of the font sizes
						--E.db.nameplate.debuffs.font = font
						--E.db.nameplate.debuffs.fontSize = fontSize   --Dont use this because nameplate font it somewhat smaller than the rest of the font sizes
						E.db.actionbar.font = font
						--E.db.actionbar.fontSize = fontSize	--This may not look good if a big font size is chosen
						E.db.auras.font = font
						E.db.auras.fontSize = fontSize
						E.db.chat.font = font
						E.db.chat.fontSize = fontSize
						E.db.chat.tabFont = font
						E.db.chat.tapFontSize = fontSize
						E.db.datatexts.font = font
						E.db.datatexts.fontSize = fontSize
						E.db.tooltip.font = font
						E.db.tooltip.fontSize = fontSize
						E.db.tooltip.headerFontSize = fontSize
						E.db.tooltip.textFontSize = fontSize
						E.db.tooltip.smallTextFontSize = fontSize
						E.db.tooltip.healthBar.font = font
						--E.db.tooltip.healthbar.fontSize = fontSize -- Size is smaller than default
						E.db.unitframe.font = font
						--E.db.unitframe.fontSize = fontSize  -- Size is smaller than default
						E.db.unitframe.units.party.rdebuffs.font = font
						E.db.unitframe.units.raid.rdebuffs.font = font
						E.db.unitframe.units.raid40.rdebuffs.font = font

						E:UpdateAll(true)
					end,
				},
				dmgfont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 6,
					name = L["CombatText Font"],
					desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				namefont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 7,
					name = L["Name Font"],
					desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				replaceBlizzFonts = {
					order = 8,
					type = 'toggle',
					name = L["Replace Blizzard Fonts"],
					desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				texturesHeaderSpacing = {
					order = 19,
					type = "description",
					name = " ",
				},
				texturesHeader = {
					order = 20,
					type = "header",
					name = L["Textures"],
				},
				normTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 21,
					name = L["Primary Texture"],
					desc = L["The texture that will be used mainly for statusbars."],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value)
						local previousValue = E.private.general[ info[#info] ]
						E.private.general[ info[#info] ] = value;

						if(E.db.unitframe.statusbar == previousValue) then
							E.db.unitframe.statusbar = value
							E:UpdateAll(true)
						else
							E:UpdateMedia()
							E:UpdateStatusBars()
						end

					end
				},
				glossTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 22,
					name = L["Secondary Texture"],
					desc = L["This texture will get used on objects like chat windows and dropdown menus."],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value)
						E.private.general[ info[#info] ] = value;
						E:UpdateMedia()
						E:UpdateFrameTemplates()
					end
				},
				applyFontToAll = {
					order = 23,
					type = 'execute',
					name = L["Apply Texture To All"],
					desc = L["Applies the primary texture to all statusbars."],
					func = function()
						local texture = E.private.general.normTex
						E.db.unitframe.statusbar = texture
						E:UpdateAll(true)
					end,
				},
				colorsHeaderSpacing = {
					order = 29,
					type = "description",
					name = " ",
				},
				colorsHeader = {
					order = 30,
					type = "header",
					name = L["Colors"],
				},
				bordercolor = {
					type = "color",
					order = 31,
					name = L["Border Color"],
					desc = L["Main border color of the UI. |cffFF0000This is disabled if you are using the Thin Border Theme.|r"],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBorderColors()
					end,
					disabled = function() return E.PixelMode end,
				},
				backdropcolor = {
					type = "color",
					order = 32,
					name = L["Backdrop Color"],
					desc = L["Main backdrop color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,
				},
				backdropfadecolor = {
					type = "color",
					order = 33,
					name = L["Backdrop Faded Color"],
					desc = L["Backdrop color of transparent frames"],
					hasAlpha = true,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,
				},
				valuecolor = {
					type = "color",
					order = 34,
					name = L["Value Color"],
					desc = L["Color some texts use."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b, a)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
					end,
				},
				transparent = {
					type = "toggle",
					order = 35,
					name = L["Transparent Theme"],
					desc = L["Transparent Theme desc"],
					set = function(info, value)
						E.db.general.transparent = value
						E.db.unitframe.transparent = value
						if value then E:SetupTheme("transparent", true) else E:SetupTheme("classic", true) end
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				transparentStyle = {
					type = "range",
					order = 36,
					min = 1, max = 2, step = 1,
					name = L['Transparent Theme Style'],
					desc = L["1:New Style;\n2:Old Style"],
					disabled = function() return not E.db.general.transparent end,
					set = function(info, value)
						E.db.general.transparentStyle = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				ShadowEnable = {
					type = "toggle",
					order = 37,
					name = L["Shadow"],
					set = function(info, value)
						E.db.general.ShadowEnable = value;
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				ShadowWidth = {
					type = "range",
					order = 38,
					min = 1, max = 10, step = 1,
					name = L["Shadow Width"],
				--	disabled = function() return not E.db.general.ShadowEnable end,
					set = function(info, value)
						E.db.general.ShadowWidth = value;
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				ShadowAlpha = {
					type = "range",
					min = 0, max = 1, step = 0.1,
					order = 39,
					name = L["Shadow Alpha"],
					disabled = function() return not E.db.general.ShadowEnable end,
					set = function(info, value)
						E.db.general.ShadowAlpha = value;
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
			},
		},
		minimap = {
			order = 6,
			get = function(info) return E.db.general.minimap[ info[#info] ] end,
			type = "group",
			name = MINIMAP_LABEL,
			args = {
				header = {
					order = 1,
					type = "header",
					name = MINIMAP_LABEL,
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the minimap datatexts.|r"],
					get = function(info) return E.private.general.minimap[ info[#info] ] end,
					set = function(info, value) E.private.general.minimap[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					desc = L["Adjust the size of the minimap."],
					min = 120, max = 250, step = 1,
					set = function(info, value) E.db.general.minimap[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
					disabled = function() return not E.private.general.minimap.enable end,
				},
				locationText = {
					order = 4,
					type = 'select',
					name = L["Location Text"],
					desc = L["Change settings for the display of the location text that is on the minimap."],
					get = function(info) return E.db.general.minimap.locationText end,
					set = function(info, value) E.db.general.minimap.locationText = value; E:GetModule('Minimap'):UpdateSettings(); E:GetModule('Minimap'):Update_ZoneText() end,
					values = {
						['MOUSEOVER'] = L["Minimap Mouseover"],
						['SHOW'] = L["Always Display"],
						['HIDE'] = L["Hide"],
					},
					disabled = function() return not E.private.general.minimap.enable end,
				},
				spacer = {
					order = 5,
					type = "description",
					name = "\n",
				},
				icons = {
					order = 6,
					type = 'group',
					name = L["Minimap Buttons"],
					args = {
						classHall = {
							order = 1,
							type = 'group',
							name = GARRISON_LANDING_PAGE_TITLE,
							get = function(info) return E.db.general.minimap.icons.classHall[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.classHall[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									disabled = function() return E.private.general.minimap.hideClassHallReport end,
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideClassHallReport end,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideClassHallReport end,
								},
								hideClassHallReport = {
									order = 5,
									type = 'toggle',
									name = L["Hide"],
									get = function(info) return E.private.general.minimap.hideClassHallReport end,
									set = function(info, value) E.private.general.minimap.hideClassHallReport = value; E:StaticPopup_Show("PRIVATE_RL") end,
								},
							},
						},
						calendar = {
							order = 2,
							type = 'group',
							name = L["Calendar"],
							get = function(info) return E.db.general.minimap.icons.calendar[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.calendar[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									disabled = function() return E.private.general.minimap.hideCalendar end,
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideCalendar end,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideCalendar end,
								},
								hideCalendar = {
									order = 5,
									type = 'toggle',
									name = L["Hide"],
									get = function(info) return E.private.general.minimap.hideCalendar end,
									set = function(info, value) E.private.general.minimap.hideCalendar = value; E:GetModule('Minimap'):UpdateSettings() end,
								},
							},
						},
						mail = {
							order = 3,
							type = 'group',
							name = MAIL_LABEL,
							get = function(info) return E.db.general.minimap.icons.mail[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.mail[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						lfgEye = {
							order = 3,
							type = 'group',
							name = L["LFG Queue"],
							get = function(info) return E.db.general.minimap.icons.lfgEye[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.lfgEye[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						difficulty = {
							order = 4,
							type = 'group',
							name = L["Instance Difficulty"],
							get = function(info) return E.db.general.minimap.icons.difficulty[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.difficulty[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						challengeMode = {
							order = 5,
							type = 'group',
							name = CHALLENGE_MODE,
							get = function(info) return E.db.general.minimap.icons.challengeMode[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.challengeMode[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						vehicleLeave = {
							order = 5,
							type = 'group',
							name = LEAVE_VEHICLE,
							get = function(info) return E.db.general.minimap.icons.vehicleLeave[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.vehicleLeave[ info[#info] ] = value; E:GetModule('ActionBars'):UpdateVehicleLeave() end,
							args = {
								size = {
									order = 1,
									type = 'range',
									name = L["Size"],
									min = 10, max = 40, step = 1,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
								hide = {
									order = 5,
									type = 'toggle',
									name = L["Hide"],
								},
							},
						},
						ticket = {
							order = 6,
							type = 'group',
							name = L["Open Ticket"],
							get = function(info) return E.db.general.minimap.icons.ticket[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.ticket[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
					},
				},
			},
		},
		totems = {
			order = 8,
			type = "group",
			name = L["Class Bar"],
			get = function(info) return E.db.general.totems[ info[#info] ] end,
			set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):PositionAndSize() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Class Bar"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):ToggleEnable() end,
				},
				size = {
					order = 3,
					type = 'range',
					name = L["Button Size"],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 4,
					type = 'range',
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1,
				},
				sortDirection = {
					order = 5,
					type = 'select',
					name = L["Sort Direction"],
					values = {
						['ASCENDING'] = L["Ascending"],
						['DESCENDING'] = L["Descending"],
					},
				},
				growthDirection = {
					order = 6,
					type = 'select',
					name = L["Bar Direction"],
					values = {
						['VERTICAL'] = L["Vertical"],
						['HORIZONTAL'] = L["Horizontal"],
					},
				},
			},
		},
		cooldown = {
			type = "group",
			order = 9,
			name = L["Cooldown Text"],
			get = function(info)
				local t = E.db.cooldown[ info[#info] ]
				local d = P.cooldown[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.cooldown[ info[#info] ] = {}
				local t = E.db.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				E:UpdateCooldownSettings();
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Cooldown Text"],
				},
				enable = {
					type = "toggle",
					order = 2,
					name = L["Enable"],
					desc = L["Display cooldown text on anything with the cooldown spiral."],
					get = function(info) return E.private.cooldown[ info[#info] ] end,
					set = function(info, value) E.private.cooldown[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				threshold = {
					type = 'range',
					order = 3,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					get = function(info) return E.db.cooldown[ info[#info] ] end,
					set = function(info, value)
						E.db.cooldown[ info[#info] ] = value
						E:UpdateCooldownSettings();
					end,
				},
				expiringColor = {
					type = 'color',
					order = 4,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
				},
				secondsColor = {
					type = 'color',
					order = 5,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
				},
				minutesColor = {
					type = 'color',
					order = 6,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
				},
				hoursColor = {
					type = 'color',
					order = 7,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
				},
				daysColor = {
					type = 'color',
					order = 8,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
				},
				fontSize = {
					type = 'range',
					order = 9,
					name = L["Font Size"],
					min = 4, max = 50, step = 1,
				},
			},
		},
		chatBubbles = {
			order = 11,
			type = "group",
			name = L["Chat Bubbles"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"],
				},
				style = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					get = function(info) return E.private.general.chatBubbles end,
					set = function(info, value) E.private.general.chatBubbles = value; E:StaticPopup_Show("PRIVATE_RL") end,
					values = {
						['backdrop'] = L["Skin Backdrop"],
						['nobackdrop'] = L["Remove Backdrop"],
						['backdrop_noborder'] = L["Skin Backdrop (No Borders)"],
						['disabled'] = L["Disabled"]
					}
				},
				classColorMentionsSpeech = {
					order = 2,
					type = "toggle",
					name = L["Class Color Mentions"],
					desc = L["Use class color for the names of players when they are mentioned."],
					get = function(info) return E.private.general.classColorMentionsSpeech end,
					set = function(info, value) E.private.general.classColorMentionsSpeech = value; E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
				},
				font = {
					order = 3,
					type = "select",
					name = L["Font"],
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general.chatBubbleFont end,
					set = function(info, value) E.private.general.chatBubbleFont = value; E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
				},
				fontSize = {
					order = 4,
					type = "range",
					name = L["Font Size"],
					get = function(info) return E.private.general.chatBubbleFontSize end,
					set = function(info, value) E.private.general.chatBubbleFontSize = value; E:StaticPopup_Show("PRIVATE_RL") end,
					min = 4, max = 212, step = 1,
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
				},
			},
		},
	},
}


local DONATOR_STRING = ""
local CNDONATOR_STRING = ""
local CNDONATOR_STRING2 = ""
local CNDONATOR_STRING3 = ""
local DEVELOPER_STRING = ""
local TESTER_STRING = ""
local LINE_BREAK = "\n"
local DONATORS = {
	'bK(UrMUVnM(',
	'GOIoK92s67gz6tgi',
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg"
}

local CNDONATORS = {
	"wxbbf",
	"sammyda",
	"zmmjoy1028",
	"lileimu0126",
	"happy_fly_pig",
	"lulu5205200701",
	"qq52776758",
	"lulu5205200701",
	"玩酷轨迹",
	"泉0510",
	"皮蛋oo",
	"雨季雷",
	"lmnno",
	"feliciagao",
	"炽天使zz",
	"忘归猪",
	"marger52",
	"maimang",
	"凌乱兰花",
	"不会吐泡的鱼",
	"gd2933",
	"realzhumen",
	"itachi_203",
	"wzadjl",
	"chaoyi3456",
	"shameless_pig",
	"chise1",
	"默默远去",
	"大只标",
	"波谲云诡1314",
	"大唐风羽",
	"叹息的足迹",
	"曦月刃语",
	"samwoody",
	"oinoon",
	"tb379270_2012",
	"被人踹下天",
	"风之路人11",
	"wargreymon1234",
	"chris6522",
	"情侣t恤",
	"lyq402631678",
	"silverhawx",
	"terrymu",
	"jianxinbang",
	"yydatou2",
	"liubin5381",
	"jh967354",
	"shome",
	"santon123",
	"chenyunlong00",
	"kaminakeita",
	"gypazyy",
	"belthil17",
	"deathduo",
	"吧嗒吧嗒大学生",
	"路过的羽毛",
	"open1648",
	"bigzmeng617",
	"geenar",
	"fxymike",
	"叶落心安",
	"duyu75526150",
	"jiangxuxing1985_",
	"上帝的知己",
	"atcc7212",
	"gugg594254843",
	"wawq919",
	"arler",
	"listzj",
	"xiaoxiao4433",
	"皮蛋仔sean",
	"路过的羽毛",
	"miaofu1982",
	"jedi_chen",
	"ryumiya",
	"孤独的饼子",
	"chenyn66",
	"醉恋琉璃",
	"ye2311",
	"cityrat",
	"zhaopeng0905",
	"hanuqq",
	"tb69493153",
	"亲亲丶亲爱的",
	"qcdz008",
	"来自淮安",
	"立派的变态",
	"快播小百合",
	"尤娜天使",
	"天国沙迦",
	"isyours",
	"xiaoshoushi",
	"chenguobao369",
	"刘晨曦1984",
	"许海飞xhf",
	"starryson",
	"lsy9202",
	"zpwbmw",
	"cz_lingling",
	"惋水语自然",
	"forpyp",
	"路过的羽毛",
	"66272089w",
	"wowmojovan",
	"huojey",
	"dlsdccdcc",
	"wuge19870501",
	"dongyizhi90",
	"奉天笑笑生",
	"fzh冯子豪",
	"玩酷轨迹",
	"wang730122wxk",
	"紫夜灬毒酒", --"卩灬丶丿王丶爷"
	"archer0808",
	"dark09",
	"ggl_axs",
	"宁夏红丶",
	"luxuxin530754137",
	"jyy402",
	"azur2e",
	"tb5187319_88",
	"豆子丶",
	"tb497346_2011",
	"橙子酱53105981",
	"foxsmely",
	"gorden_gan",
	"pjh79",
	"御剑乘风酒剑仙",
	"天若o有情_2009",
	"renchao15",
	"aierlanhai",
	"曾经丶烽",
	"linbin814619",
	"bysharrka",
	"ywj373303873",
	"aslick",
	"maling871128",
	"zhaokeith",
	"esc丶卟点",
	"shortland",
	"szc0635",
	"tatsuyahome",
	"aeon_sakura",
	"eddiegsp3",
	"血鹰幽灵",
	"levisli888",
	"jianshen3868",
	"elafor",
	"knight_5201314",	
	"咆哮的柴郡猫",
	"立派的变态",
	"yirong_sun",
	"永远的亚瑟",
	"孤星丶夜",
	"最帅的牛", --ianliuh
	"fht112233",
	"a503113120",
	"天王永存",
	"xiaoshoushi",
	"sasoricat",
	"巨烦人",
	"demodevil",
	"sandylester88",
	"临界冰封",
	"shxx_lee",
	"xiaxiaowei_516",
	"gongyong982715",
	"ivan90511",
	"kingyb26",
	"tb337033_99",
	"iverson21cn",
	"zoorre",
	"boatman13",
	"抢啊抢啊抢",
	"我是山猪2011",
	"Paramahamsa",  --shhope
	"bibi6",
	"肾不由己1989",
	"qyzod",
	"joydarken",
	"slovxy",
	"achongnrg",
	"leebv",
	"xj138154",
	"ley2008",
	"路过的羽毛",
	"wsyf8754210",
	"samsung_55",
	"q301076955",
	"宁静之神46566",
	"a13656506079",
	"hlcwin",
	"游离之魂",
	"sybasta",
	"orbneil",
	"好人fk",
	"sy04816leo",
	"heaven589",
	"zhouhao27",
	"feng9016",
	"kyuubifox",
	"tb425775_00",
	"kalrend",
	"lyqhzls14",
	"夭夭茶",
	"daftjoker",
	"我是山猪2011",
	"cfjie",
	"zuiairongx",
	"nomibuy",
	"小虎第一小虎第一",	
}
local CNDONATORS2 = {
	"买东西的jlu",
	"dizzy11",
	"baixf0703",
	"tb425775_00",
	"卷囡囡",
	"羽毛的标准",
	"fightingbug",
	"indigo0000",
	"tom60876",
	"mijiemijie198610",
	"akonwang1988 ",
	"tzlsj00",
	"杨柳岸残钺",
	"q489842856",
	"suancaihit",
	"dlsdccdcc",
	"我是山猪2011",
	"起床嘘嘘",
	"liudilin1992",
	"diyun0607",
	"yaibj",
	"雪线伊人",
	"k100992994",
	"小萨乐",
	"末日呈",
	"cesarmarui",
	"aihooo",
	"shadow477",
	"曲建行",
	"tessaex",
	"encili",
	"cutlass_sz",
	"c27346734",
	"computer0102",
	"jsjhgp1989",
	"caoshui_2008",
	"mingxiuyu",
	"123321awy",
	"藍幽魅兒",
	"hlf9527",
	"像雨一样忧伤",
	"hujintao8",
	"落雪无痕9371",
	"sunnying1218",
	"oenzoo",
	"一死谢天下",
	"shihaomrzhang",
	"jurane",
	"胖熊回家",
	"shajia221",
	"fzq5201",
	"sirius冲儿",
	"咆哮的柴郡猫",
	"sm00haha",
	"潘德威",
	"earldliu",
	"dubaoli060431",
	"醉爱无痕",
	"喜欢jing3",
	"蒋松儒",
	"sophie000088",
	"my58026",
	"ayoko",
	"狂暴之魂",
	"浮云丶寂凉",
	"clampjay12",
	"辛晓康",
	"ley2008",
	"awgy97",
	"longzi1439",
	"臭蛋小超人",
	"manstein623",
	"daivd_dai",
	"liangrouchang",
	"拉拉kop",
	"2wsx2005",
	"颓废的食神",
	"zhou_love_zhu",
	"makiyo0218",
	"ajijiawei1",
	"wjzh19940530",
	"林吴珂",
	"cjy530qs",
	"tb3182534_2011",
	"washhongname",
	"seven_夜",
	"豆子丶",
	"曹晨阳",
	"欧阳义煌",
	"sabarwow2",
	"qianjx8888",
	"ankang1666",
	"世界神殿",
	"dulluke",
	"xcx2200",
	"ss19880630",
	"a13946283",
	"tb425775_00",
	"木易念_张",
	"wangde649868",
	"tb843273_2011",
	"晨曦星",
	"cqing888",
	"wkw533038",
	"lxjdsmm",
	"口袋里的坦克",
	"tb95188807",
	"ghp1165",
	"remix熙",
	"马雁阳",
	"花已落下",
	"柒小7_7",
	"茶靡花事了",
	"riley1983",
	"shyzd",
	"與汝同思",
	"云蛋风轻kimi",
	"insov",
	"zp1989717",
	"ginraiy",
	"youdianfano",
	"东腿爸爸",
	"han30_0213",
	"asdf01989119",
	"gangerster",
	"msmicrosoft",
	"wenjianbin115",
	"wyang1027",
	"mdoexeryher",
	"堕落刺客.m",
	"polinell",
	"tb_ljx",
	"merkava3",
	"jaminjing",
	"雷亦歌",
	"vishnv",
	"布布的布",
	"摇不尽的风情", --max1032
	"zmy4528",
	"hlf9527",
	"枸杞子西洋参",
	"itoluthp",
	"lightbring",
	"thecrucifix",
	"a308253730",
	"chongchongok",
	"zerocraft",
	"上帝的知己",
	"月华无双",
	"马路西安",
	"龙骨平原-Drusus", --赵世康1
	"紫苑迷娈",
	"yoyo1943123",
	"爱的no1",
	"zytzx",
	"ajax1035",
	"一叫千门万户开",
	"b蜗牛",
	"wangziyueaacom",
	"x363170927",
	"青空的留白",
	"风蓝夕颜",
	"yxaml",
	"cumt001",
	"闫小幸0806",
	"wasky520",
	"快乐吖点",
	"冷芯琥珀",
	"tb267280_2013",
	"ouchukun",
	"wangzihyf",
	"mars89326",
	"mybackbone",
	"dubaoli060431",
	"markeloff95",
	"jxaa011975",
	"q87799",
	"68xing",
	"黄冬冬丶",
	"圣光一闪",--gaoqiyuan
	"乐taotao",
	"南宫之宇",
	"hotandcool",
	"cd86757",
	"薛云月11",
	"wsheng82",
	"买东西滴1982",
	"ph851112",
	"大藏乡",
	"wht3833",
	"传说有钱人",
	"sakrar",
	"飞火流枫",
	"小小woman",
	"bingheyizu",
	"x363170927",
	"且看风去风留d",
	"ephraimjj",
	"li729253213",
	"百羽百末",
	"li729253213",
	"guobenjing1992",
	"li729253213",
	"酃恋辰兮",
	"znxts",
	"li729253213",
	"默默远去",
	"laodiaozl",
	"soi一fong",
	"qwpmom",
	"丶丶丶夜冬 ",
	"起个b名想一周",
	"zhangqibei1993316",
	"春奈酱",--crazy9287
	"丨小小苏丨",
	"陨落的半神",--tb_2365641
	"ypy283217",
	"tb858705_22",
	"zkshahaha",
	"暧沐涕",
	"morrisduan",
	"大德无德",
	"lilolau",
	"王飞爱朦朦",
	"hisyf",
	"flynewhome",
	
}

local CNDONATORS3 = {
	"niwei831206",
	"霜月球",
	"ftx121416",
	"卫原明",
	"牛德华不牛",
	"jasonmaker",
	"insee884",
	"小新09180",
	"相思蓝枫叶",
	"q6890338",
	"kdiwang",
	"jqllove2",
	"ykp2008q",
	"tyadan",
	"52dulang",
	"国产金刚互撸娃",
	"antaxzj",
	"剧毒创伤",
	"我是山猪2011",
	"如风灬似水",
	"最爱回锅肉", --zhwfrank
	"zhpeng120",
	"psp星痕",
	"caatkl",
	"tb92330716",
	"gxy3223553",
	"lean28",
	"白403600533",
	"wwhdd96727",
	"波风皆人1314",
	"xlssce",
	"dwnokia",
	"aiken2132",
	"桔子的崩坏",
	"donkey_41",
	"a244988253",
	"跋扈的飞扬",
	"一筐包子",
	"miss采薇",
	"爱yy的蜗牛",
	"luanshun1",
	"诚意拍拍工作室",
	"a6322978",
	"mrxux",
	"nayazj",
	"ksanasetsuna",
	"cd122431897",
	"junny9985",
	"tb5370284_2011",
	"small871204",
	"yl50420031",
	"nj966",
	"zhao466807256",
	"丶丢雷劳模", --qq524991989  
	"牙牙xb",
	"zhouyx5",
	"testb35513",
	"爱购320",
	"freejansen",
	"ksanasetsuna",
	"何晓宇1993",
	"死亡之翼利维坦",--zhuyukai_kai
	"tb22004_34",
	"lxgxy520lx",
	"tb44963",
	"kiraxfree",
	"好名字全让取了",
	"天真的创伤",--myth家驹03
	"小小的皓轩",
	"影子_同学",
	"gangerster",
	"躺在七楼",
	"chaoren18ac",
	"salaleenom",
	"炫紫忧梦",
	"tb9769994",
	"口袋里的坦克",
	"罗凯健",
	"sagacityshen",
	"金大奇奇",
	"飘落的冰晶缘",
	"not_animals",
	"yszdlm2009",
	"wusi19821211",
	"丫丫的大唐",
	"铭记丶回忆",
	"a18627814951",
	"wuhao290",
	"春哥很疯狂",
	"王颛321",
	"春奈酱",--crazy9287
	"me丨白",
	"laolv198811",
	"zeratul44",
	"tonken2046",
	"kid_9463",
	"qiutiangoal",
	"jikai01c",
	"dcdb723",
	"dc910714dyz",
	"无名de信仰",
	"alicend",
	"th02689",
	"化作万风",
	"random_fly",
	"njjwl2005",
	"redgo111",
	"yerobin00",
	"渡_kitchen",
	"多多可爱多0408",
	"yumeng4442",
	"wendi_5",
	"yao19911019",
	"无缘之锋",
	"永恒的泡泡",
	"sookie",
	"gengye1860",
	"nan129588",
	"stalker11",
	"斐洛蒙",
	"exxx2014",
	"上帝的知己",
	"lovehein",
	"你买卖我卖买",
	"han30_0213",
	"sbh1941",
	"口袋里的坦克",
	"xjtufans",
	"风之小碧落",
	"cokar",
	"me2youdear",
	"cz78644915",
	"4q104q",
	"小刀木乃伊",
	"活火明月",
	"指間丄的旋律",--尚学箫
	"shengqing5655",
	"pokacc",
	"谢灿强21",
	"cpii266",
	"lesterfg",
	"admijie",
	"qq395004730",
	"环球保卫队",
	"clark810810",
	"岚亦悠然",
	"bibichuang0806",
	"lwsame",
	"mk_go",
	"jyhk201210",
	"王颛321",
	"萌萌恋-红云台地", --sallymm234
	"cty110cty",
	"j_n_z",
	"我是金华的",
	"张佳伦0411",
	"tb28817966",
	"qqtoffadsl",
	"yaohai1205",
	"detetivehaode",
	"zend_study",
	"zts6830849",
	"kchunquan",
	"古晨泽",
	"freewalker1985",
	"woaintbb",
	"akbryant",
	"迈克尔桥墩",
	"bunycn",
	"迷离李小贤",
	"祭落樱瞳",
	"zheng98jiao",
	"holesun",
	"能便宜点唛",
	"钱海生涯",
	"大道理我早懂",
	"teani小洛",
	"sqybi",
	"梦子龙",
	"zcdemx",
	"shuaizhi1987",
	"wangjinfang823279",
	"e30914038",
	"hopebbs",
	"1127tm",
	"lijin901128",
	"pausdk",
	"我酱了个油",
	"蔡晓阳520",
	"dengni10000",
	"lqlgoran",
	"蒲公英的约定1989",
	"namiyeiyi",
	"li317445938",
	"deja即视",
	"zmy4528",
	"taohui52098",
	"布袋青蛙",
	"意外访客1234",
	"freelement1",
	"lxlasx",
	"doya_kakyo",
	"填充味",
	"boydf117",
	"mlaht520",
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine"
}

local TESTERS = {
	"Tukui Community",
	"Affinity",
	"Modarch",
	"Bladesdruid",
	"Tirain",
	"Phima",
	"Veiled",
	"Blazeflack",
	"Repooc",
	"Darth Predator",
	'Alex',
	'Nidra',
	'Kurhyus',
	'BuG',
	'Yachanay',
	'Catok'
}

if not E.zhlocale then
	tsort(DONATORS, function(a,b) return a < b end) --Alphabetize
	for _, donatorName in pairs(DONATORS) do
		tinsert(E.CreditsList, donatorName)
		DONATOR_STRING = DONATOR_STRING..LINE_BREAK..donatorName
	end

	tsort(DEVELOPERS, function(a,b) return a < b end) --Alphabetize
	for _, devName in pairs(DEVELOPERS) do
		tinsert(E.CreditsList, devName)
		DEVELOPER_STRING = DEVELOPER_STRING..LINE_BREAK..devName
	end

	tsort(TESTERS, function(a,b) return a < b end) --Alphabetize
	for _, testerName in pairs(TESTERS) do
		tinsert(E.CreditsList, testerName)
		TESTER_STRING = TESTER_STRING..LINE_BREAK..testerName
	end
else
	tsort(CNDONATORS, function(a,b) return a < b end) --Alphabetize
	for _, testerName in pairs(CNDONATORS) do
		tinsert(E.CreditsList, testerName)
	end
end	

local cni = 0
for _, cndonatorName in pairs(CNDONATORS) do
	cni = cni + 1
	if mod(cni, 20) == 0 then
		CNDONATOR_STRING = CNDONATOR_STRING..LINE_BREAK..LINE_BREAK..cndonatorName
	else
		CNDONATOR_STRING = CNDONATOR_STRING.. (CNDONATOR_STRING ~= "" and ", " or "")..cndonatorName
	end
end
cni = 0
for _, cndonatorName in pairs(CNDONATORS2) do
	cni = cni + 1
	if mod(cni, 20) == 0 then
		CNDONATOR_STRING2 = CNDONATOR_STRING2..LINE_BREAK..LINE_BREAK..cndonatorName
	else
		CNDONATOR_STRING2 = CNDONATOR_STRING2.. (CNDONATOR_STRING2 ~= "" and ", " or "")..cndonatorName
	end
end
cni = 0
for _, cndonatorName in pairs(CNDONATORS3) do
	cni = cni + 1
	if mod(cni, 20) == 0 then
		CNDONATOR_STRING3 = CNDONATOR_STRING3..LINE_BREAK..LINE_BREAK..cndonatorName
	else
		CNDONATOR_STRING3 = CNDONATOR_STRING3.. (CNDONATOR_STRING3 ~= "" and ", " or "")..cndonatorName
	end
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -2,
	args = {
		text = {
			order = 1,
			type = "description",
			fontSize = "medium",
			name = L['ELVUI_CREDITS']..'\n\n'..L['Coding:']..DEVELOPER_STRING..'\n\n'..L['Testing:']..TESTER_STRING..'\n\n'..L['Donations:']..DONATOR_STRING,
		},
	},
}

if E.zhlocale then
	E.Options.args.credits2 = {
		type = "group",
		name = L['Donations:']..'2',
		order = -1,
		args = {
			text = {
				order = 1,
				type = "description",
				fontSize = "medium",
				name = '',
			},
		},
	}
	E.Options.args.credits3 = {
		type = "group",
		name = L['Donations:']..'3',
		order = -1,
		args = {
			text = {
				order = 1,
				type = "description",
				fontSize = "medium",
				name = '',
			},
		},
	}	
	E.Options.args.credits.args.text.name = '|cffC495DD'.. L['EUI_DONATOR']..'|r\n\n\n'..CNDONATOR_STRING
	E.Options.args.credits2.args.text.name = '|cffC495DD'.. L['EUI_DONATOR']..'|r\n\n\n'..CNDONATOR_STRING2
	E.Options.args.credits3.args.text.name = '|cffC495DD'.. L['EUI_DONATOR']..'|r\n\n\n'..CNDONATOR_STRING3
	E.Options.args.credits.name = L['Donations:']
end

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filtersNP"] = L["Filters (NamePlates)"],
	["filtersUF"] = L["Filters (UnitFrames)"],
	["filtersAll"] = L["Filters (All)"],
}
local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filtersNP",
	"filtersUF",
	"filtersAll",
}
local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"],
}
local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin",
}
		
local exportString = ""
local function ExportImport_Open(mode)
	local Frame = AceGUI:Create("Frame")
	Frame:SetTitle("")
	Frame:EnableResize(false)
	Frame:SetWidth(800)
	Frame:SetHeight(600)
	Frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	Frame:SetLayout("flow")

	local Box = AceGUI:Create("MultiLineEditBox");
	Box:SetNumLines(30)
	Box:DisableButton(true)
	Box:SetWidth(800)
	Box:SetLabel("")
	Frame:AddChild(Box)
	--Save original script so we can restore it later
	Box.editBox.OnTextChangedOrig = Box.editBox:GetScript("OnTextChanged")
	
	local Label1 = AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label1:SetFont(font, 14)
	Label1:SetText(".") --Set temporary text so height is set correctly
	Label1:SetWidth(800)
	Frame:AddChild(Label1)
	
	local Label2 = AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label2:SetFont(font, 14)
	Label2:SetText(".\n.")
	Label2:SetWidth(800)
	Frame:AddChild(Label2)

	if mode == "export" then
		Frame:SetTitle('EUI'..L["Export Profile"])

		local ProfileTypeDropdown = AceGUI:Create("Dropdown")
		ProfileTypeDropdown:SetMultiselect(false)
		ProfileTypeDropdown:SetLabel(L["Choose What To Export"])
		ProfileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder)
		ProfileTypeDropdown:SetValue("profile") --Default export
		Frame:AddChild(ProfileTypeDropdown)
		
		local ExportFormatDropdown = AceGUI:Create("Dropdown")
		ExportFormatDropdown:SetMultiselect(false)
		ExportFormatDropdown:SetLabel(L["Choose Export Format"])
		ExportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder)
		ExportFormatDropdown:SetValue("text") --Default format
		ExportFormatDropdown:SetWidth(150)
		Frame:AddChild(ExportFormatDropdown)
		
		local exportButton = AceGUI:Create("Button")
		exportButton:SetText(L["Export Now"])
		exportButton:SetAutoWidth(true)
		local function OnClick(self)
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")

			local profileType, exportFormat = ProfileTypeDropdown:GetValue(), ExportFormatDropdown:GetValue()
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat)
			if not profileKey or not profileExport then
				Label1:SetText(L["Error exporting profile!"])
			else
				Label1:SetText(format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]))
				if profileType == "profile" then
					Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
				end
			end
			Box:SetText(profileExport);
			Box.editBox:HighlightText();
			Box:SetFocus();
			exportString = profileExport
		end
		exportButton:SetCallback("OnClick", OnClick)
		Frame:AddChild(exportButton)
		
		--Set scripts
		Box.editBox:SetScript("OnChar", function() Box:SetText(exportString); Box.editBox:HighlightText(); end);
		Box.editBox:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				--Prevent user from changing export string
				Box:SetText(exportString)
				Box.editBox:HighlightText();
			end
		end)

	elseif mode == "import" then
		Frame:SetTitle('EUI'..L["Import Profile"])
		local importButton = AceGUI:Create("Button-ElvUI")
		importButton:SetDisabled(true)
		importButton:SetText(L["Import Now"])
		importButton:SetAutoWidth(true)
		importButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")

			local text
			local success = D:ImportProfile(Box:GetText())
			if success then
				text = L["Profile imported successfully!"]
			else
				text = L["Error decoding data. Import string may be corrupted!"]
			end
			Label1:SetText(text)
		end)
		Frame:AddChild(importButton)
		
		local decodeButton = AceGUI:Create("Button-ElvUI")
		decodeButton:SetDisabled(true)
		decodeButton:SetText(L["Decode Text"])
		decodeButton:SetAutoWidth(true)
		decodeButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")
			local decodedText
			local profileType, profileKey, profileData = D:Decode(Box:GetText())
			if profileData then
				decodedText = E:TableToLuaString(profileData)
			end
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey)
			Box:SetText(importText)
		end)
		Frame:AddChild(decodeButton)

		local function OnTextChanged()
			local text = Box:GetText()
			if text == "" then
				Label1:SetText("")
				Label2:SetText("")
				importButton:SetDisabled(true)
				decodeButton:SetDisabled(true)
			else
				local stringType = D:GetImportStringType(text)
				if stringType == "Base64" then
					decodeButton:SetDisabled(false)
				else
					decodeButton:SetDisabled(true)
				end

				local profileType, profileKey = D:Decode(text)
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					Label1:SetText(L["Error decoding data. Import string may be corrupted!"])
					Label2:SetText("")
					importButton:SetDisabled(true)
					decodeButton:SetDisabled(true)
				else
					Label1:SetText(format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ""))
					if profileType == "profile" then
						Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
					end
					importButton:SetDisabled(false)
				end
				
				--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
				Box.scrollFrame:SetVerticalScroll(Box.scrollFrame:GetVerticalScrollRange())
			end
		end

		Box.editBox:SetFocus()
		--Set scripts
		Box.editBox:SetScript("OnChar", nil);
		Box.editBox:SetScript("OnTextChanged", OnTextChanged)
	end

	Frame:SetCallback("OnClose", function(widget)
		--Restore changed scripts
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", Box.editBox.OnTextChangedOrig)
		Box.editBox.OnTextChangedOrig = nil

		--Clear stored export string
		exportString = ""

		AceGUI:Release(widget)
		ACD:Open("ElvUI")
	end)
	
	--Clear default text
	Label1:SetText("")
	Label2:SetText("")
	
	--Close ElvUI Config
	ACD:Close("ElvUI")

	GameTooltip_Hide() --The tooltip from the Export/Import button stays on screen, so hide it
end

--Create Profiles Table
E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data);
AC:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles)
E.Options.args.profiles.order = -10

LibStub('LibDualSpec-1.0'):EnhanceOptions(E.Options.args.profiles, E.data)

if not E.Options.args.profiles.plugins then
	E.Options.args.profiles.plugins = {}
end

--if E:TestCompare(DONATORS[1]..DONATORS[2]) == E.myfullname then
--	wipe(ElvDB); ReloadUI();
--end

E.Options.args.profiles.plugins["ElvUI"] = {
	spacer = {
		order = 89,
		type = 'description',
		name = '\n\n',
	},
	desc = {
		name = L["This feature will allow you to transfer settings to other characters."],
		type = 'description',
		order = 90,
	},
	distributeProfile = {
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		type = 'execute',
		order = 91,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name)
			elseif server then
				D:Distribute(name, true)
			end
		end,
	},
	distributeGlobal = {
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		type = 'execute',
		order = 92,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end

			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name, false, true)
			elseif server then
				D:Distribute(name, true, true)
			end
		end,
	},
	spacer2 = {
		order = 93,
		type = 'description',
		name = '',
	},
	exportProfile = {
		name = L["Export Profile"],
		type = 'execute',
		order = 94,
		func = function() ExportImport_Open("export") end,
	},
	importProfile = {
		name = L["Import Profile"],
		type = 'execute',
		order = 95,
		func = function() ExportImport_Open("import") end,
	},
}