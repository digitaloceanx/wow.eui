function GottaGoFast.GetUnlocked(info)
  return GottaGoFast.unlocked;
end

function GottaGoFast.SetUnlocked(info, value)
  GottaGoFast.unlocked = value;
  GottaGoFastFrame:SetMovable(GottaGoFast.unlocked);
  GottaGoFastFrame:EnableMouse(GottaGoFast.unlocked);
end

function GottaGoFast.GetGoldTimer(info)
  return GottaGoFast.db.profile.GoldTimer;
end

function GottaGoFast.SetGoldTimer(info, value)
  GottaGoFast.db.profile.GoldTimer = value;
  GottaGoFast.UpdateCMTimer();
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetTimerType(info)
  return GottaGoFast.db.profile.TimerType;
end

function GottaGoFast.SetTimerType(info, value)
  GottaGoFast.db.profile.TimerType = value;
  GottaGoFast.UpdateCMTimer();
end

function GottaGoFast.GetTrueTimer()
  local timerType = GottaGoFast.GetTimerType(nil);
  if (timerType == "TrueTimerMS" or timerType == "TrueTimerNoMS") then
    return true;
  else
    return false;
  end
end

function GottaGoFast.GetTimerX(info)
  return GottaGoFast.db.profile.TimerX;
end

function GottaGoFast.SetTimerX(info, value)
  GottaGoFast.db.profile.TimerX = value;
  GottaGoFastTimerFrame:ClearAllPoints();
  GottaGoFastTimerFrame:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
end

function GottaGoFast.GetTimerY(info)
  return GottaGoFast.db.profile.TimerY;
end

function GottaGoFast.SetTimerY(info, value)
  GottaGoFast.db.profile.TimerY = value;
  GottaGoFastTimerFrame:ClearAllPoints();
  GottaGoFastTimerFrame:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
end

function GottaGoFast.GetTimerFont(info)
  return GottaGoFast.db.profile.TimerFont;
end

function GottaGoFast.SetTimerFont(info, value)
  GottaGoFast.db.profile.TimerFont = value;
  GottaGoFastTimerFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.TimerFont), GottaGoFast.db.profile.TimerFontSize, GottaGoFast.db.profile.TimerFontFlag);
end

function GottaGoFast.GetObjectiveFont(info)
  return GottaGoFast.db.profile.ObjectiveFont;
end

function GottaGoFast.SetObjectiveFont(info, value)
  GottaGoFast.db.profile.ObjectiveFont = value;
  GottaGoFastObjectiveFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.ObjectiveFont), GottaGoFast.db.profile.ObjectiveFontSize, GottaGoFast.db.profile.ObjectiveFontFlag);
end

function GottaGoFast.GetTimerFontSize(info)
  return GottaGoFast.db.profile.TimerFontSize;
end

function GottaGoFast.SetTimerFontSize(info, value)
  GottaGoFast.db.profile.TimerFontSize = value;
  GottaGoFastTimerFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.TimerFont), GottaGoFast.db.profile.TimerFontSize, GottaGoFast.db.profile.TimerFontFlag);
end

function GottaGoFast.GetTimerAlign(info)
  return GottaGoFast.db.profile.TimerAlign;
end

function GottaGoFast.SetTimerAlign(info, value)
  GottaGoFast.db.profile.TimerAlign = value;
  GottaGoFastTimerFrame.font:SetJustifyH(GottaGoFast.db.profile.TimerAlign);
  GottaGoFast.UpdateCMTimer();
end

function GottaGoFast.GetObjectiveX(info)
  return GottaGoFast.db.profile.ObjectiveX;
end

function GottaGoFast.SetObjectiveX(info, value)
  GottaGoFast.db.profile.ObjectiveX = value;
  GottaGoFastObjectiveFrame:ClearAllPoints();
  GottaGoFastObjectiveFrame:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);
end

function GottaGoFast.GetObjectiveY(info)
  return GottaGoFast.db.profile.ObjectiveY;
end

function GottaGoFast.SetObjectiveY(info, value)
  GottaGoFast.db.profile.ObjectiveY = value;
  GottaGoFastObjectiveFrame:ClearAllPoints();
  GottaGoFastObjectiveFrame:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);
end

function GottaGoFast.GetObjectiveFontSize(info)
  return GottaGoFast.db.profile.ObjectiveFontSize;
end

function GottaGoFast.SetObjectiveFontSize(info, value)
  GottaGoFast.db.profile.ObjectiveFontSize = value;
  GottaGoFastObjectiveFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.ObjectiveFont), GottaGoFast.db.profile.ObjectiveFontSize, GottaGoFast.db.profile.ObjectiveFontFlag);
end

function GottaGoFast.GetObjectiveAlign(info)
  return GottaGoFast.db.profile.ObjectiveAlign;
end

function GottaGoFast.SetObjectiveAlign(info, value)
  GottaGoFast.db.profile.ObjectiveAlign = value;
  GottaGoFastObjectiveFrame.font:SetJustifyH(GottaGoFast.db.profile.ObjectiveAlign);
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetObjectiveCollapsed(info)
  return GottaGoFast.db.profile.ObjectiveCollapsed;
end

function GottaGoFast.SetObjectiveCollapsed(info, value)
  GottaGoFast.db.profile.ObjectiveCollapsed = value;
end

function GottaGoFast.GetTimerColor(info)
  local a, r, g, b = GottaGoFast.HexToRGB(GottaGoFast.db.profile.TimerColor);
  return r, g, b, a;
end

function GottaGoFast.SetTimerColor(info, r, g, b, a)
  GottaGoFast.db.profile.TimerColor = GottaGoFast.RGBToHex(r, g, b, a);
  GottaGoFast.UpdateCMTimer();
end

function GottaGoFast.GetObjectiveColor(info)
  local a, r, g, b = GottaGoFast.HexToRGB(GottaGoFast.db.profile.ObjectiveColor);
  return r, g, b, a;
end

function GottaGoFast.SetObjectiveColor(info, r, g, b, a)
  GottaGoFast.db.profile.ObjectiveColor = GottaGoFast.RGBToHex(r, g, b, a);
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetObjectiveCompleteColor(info)
  local a, r, g, b = GottaGoFast.HexToRGB(GottaGoFast.db.profile.ObjectiveCompleteColor);
  return r, g, b, a;
end

function GottaGoFast.SetObjectiveCompleteColor(info, r, g, b, a)
  GottaGoFast.db.profile.ObjectiveCompleteColor = GottaGoFast.RGBToHex(r, g, b, a);
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetIncreaseColor(info)
  local a, r, g, b = GottaGoFast.HexToRGB(GottaGoFast.db.profile.IncreaseColor);
  return r, g, b, a;
end

function GottaGoFast.SetIncreaseColor(info, r, g, b, a)
  GottaGoFast.db.profile.IncreaseColor = GottaGoFast.RGBToHex(r, g, b, a);
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetLevelInTimer(info)
  return GottaGoFast.db.profile.LevelInTimer;
end

function GottaGoFast.SetLevelInTimer(info, value)
  GottaGoFast.db.profile.LevelInTimer = value;
  GottaGoFast.UpdateCMTimer();
end

function GottaGoFast.GetLevelInObjectives(info)
  return GottaGoFast.db.profile.LevelInObjectives;
end

function GottaGoFast.SetLevelInObjectives(info, value)
  GottaGoFast.db.profile.LevelInObjectives = value;
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetAffixesInObjectives(info)
  return GottaGoFast.db.profile.AffixesInObjectives;
end

function GottaGoFast.SetAffixesInObjectives(info, value)
  GottaGoFast.db.profile.AffixesInObjectives = value;
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetIncreaseInObjectives(info)
  return GottaGoFast.db.profile.IncreaseInObjectives;
end

function GottaGoFast.SetIncreaseInObjectives(info, value)
  GottaGoFast.db.profile.IncreaseInObjectives = value;
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetObjectiveCompleteInObjectives(info)
  return GottaGoFast.db.profile.ObjectiveCompleteInObjectives;
end

function GottaGoFast.SetObjectiveCompleteInObjectives(info, value)
  GottaGoFast.db.profile.ObjectiveCompleteInObjectives = value;
  GottaGoFast.UpdateCMObjectives();
end

function GottaGoFast.GetTimerFontFlag(info)
  return GottaGoFast.db.profile.TimerFontFlag;
end

function GottaGoFast.SetTimerFontFlag(info, value)
  GottaGoFast.db.profile.TimerFontFlag = value;
  GottaGoFastTimerFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.TimerFont), GottaGoFast.db.profile.TimerFontSize, GottaGoFast.db.profile.TimerFontFlag);
end

function GottaGoFast.GetObjectiveFontFlag(info)
  return GottaGoFast.db.profile.ObjectiveFontFlag;
end

function GottaGoFast.SetObjectiveFontFlag(info, value)
  GottaGoFast.db.profile.ObjectiveFontFlag = value;
  GottaGoFastObjectiveFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.ObjectiveFont), GottaGoFast.db.profile.ObjectiveFontSize, GottaGoFast.db.profile.ObjectiveFontFlag);
end

function GottaGoFast.GetDebugMode(info)
  return GottaGoFast.db.profile.DebugMode;
end

function GottaGoFast.SetDebugMode(info, value)
  GottaGoFast.db.profile.DebugMode = value;
  GottaGoFast:Print("Debug Mode = " .. tostring(value));
end

function GottaGoFast.InitOptions()
  GottaGoFast.LSM = LibStub:GetLibrary("LibSharedMedia-3.0");
--  GottaGoFast.LSM:Register("font", "Myriad Condensed Web", "Interface\\Addons\\GottaGoFast\\MyriadCondensedWeb.ttf")
  local defaults = {
    profile = {
      GoldTimer = true,
      TimerType = "TrueTimerMS",
      FrameAnchor = "RIGHT",
      FrameX = 0,
      FrameY = 0,
      TimerAlign = "CENTER",
      TimerX = -35, --eui.cc
      TimerY = 0,
      TimerFont = "EUI",
      TimerFontSize = 29,
      TimerColor = "ffffffff",
      TimerFontFlag = "OUTLINE",
      ObjectiveAlign = "LEFT",
      ObjectiveX = -35, --by eui.cc
      ObjectiveY = -40,
      ObjectiveFont = "EUI",
      ObjectiveFontSize = 21,
      ObjectiveCollapsed = false,
      ObjectiveColor = "ffffffff",
      ObjectiveCompleteColor = "ff0ff000",
      ObjectiveFontFlag = "OUTLINE",
      IncreaseColor = "ffffffff",
      LevelInTimer = true,
      LevelInObjectives = false,
      AffixesInObjectives = true,
      IncreaseInObjectives = true,
      ObjectiveCompleteInObjectives = true,
      History = {},
      DebugMode = false,
    },
  }
  local options
  local GetLocale = GetLocale
  if GetLocale() == 'zhCN' then
	  options = {
		name = "GottaGoFast",
		handler = GottaGoFast,
		type = "group",
		args = {
		  cms = {
			name = "挑战模式",
			type = "group",
			args = {
			  TimerType = {
				order = 1,
				type = "select",
				name = "时间样式",
				desc = "TrueTimer is timed off the start of the dungeon using system time.\nI recommend you use this option.\nBlizzard's timer is known to bug up to 20 seconds.\nI will report details soon.",
				values = {["TrueTimerMS"] = "真实时间 (毫秒)", ["TrueTimerNoMS"] = "真实时间 (无毫秒)", ["Blizzard"] = "暴雪的计时"},
				get = GottaGoFast.GetTimerType,
				set = GottaGoFast.SetTimerType,
			  },
			  GoldTimer = {
				order = 2,
				type = "toggle",
				name = "金牌计时",
				desc = "开关是否显示金牌计时",
				get = GottaGoFast.GetGoldTimer,
				set = GottaGoFast.SetGoldTimer,
			  },
			  LevelInObjectives = {
				order = 3,
				type = "toggle",
				name = "挑战等级显示 (任务框)",
				desc = "显示当前挑战等级在任务列表",
				get = GottaGoFast.GetLevelInObjectives,
				set = GottaGoFast.SetLevelInObjectives,
			  },
			  AffixesInObjectives = {
				order = 4,
				type = "toggle",
				name = "词缀显示(任务框)",
				desc = "显示当前词缀在任务列表",
				get = GottaGoFast.GetAffixesInObjectives,
				set = GottaGoFast.SetAffixesInObjectives,
			  },
			  LevelInTimer = {
				order = 5,
				type = "toggle",
				name = "挑战等级显示 (时间)",
				desc = "在计时器开头显示当前挑战等级",
				get = GottaGoFast.GetLevelInTimer,
				set = GottaGoFast.SetLevelInTimer,
			  },
			  IncreaseInObjectives = {
				order = 6,
				type = "toggle",
				name = "钥石升级显示 (任务)",
				desc = "额外钥石计时分离",
				get = GottaGoFast.GetIncreaseInObjectives,
				set = GottaGoFast.SetIncreaseInObjectives,
			  },
			  ObjectiveCompleteInObjectives = {
				order = 7,
				type = "toggle",
				name = "挑战目标完成显示 (目标)",
				desc = "显示我们已经完成的任务目标",
				get = GottaGoFast.GetObjectiveCompleteInObjectives,
				set = GottaGoFast.SetObjectiveCompleteInObjectives,
			  }
			}
		  },
		  displayFrame = {
			name = "显示: 框体",
			type = "group",
			args = {
			  unlocked = {
				order = 1,
				type = "toggle",
				name = "解锁",
				desc = "开关时间框体的解锁状态",
				get = GottaGoFast.GetUnlocked,
				set = GottaGoFast.SetUnlocked,
			  },
			  ObjectiveCollapsed = {
				order = 2,
				type = "toggle",
				name = "任务追踪框折叠",
				desc = "当离开挑战或时光漫游戏本时折叠任务追踪框",
				get = GottaGoFast.GetObjectiveCollapsed,
				set = GottaGoFast.SetObjectiveCollapsed,
			  },
			  TimerX = {
				order = 3,
				type = "range",
				name = "计时器水平偏移",
				desc = "默认: -35",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetTimerX,
				set = GottaGoFast.SetTimerX,
			  },
			  TimerY = {
				order = 4,
				type = "range",
				name = "计时器垂直偏移",
				desc = "默认: 0",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetTimerY,
				set = GottaGoFast.SetTimerY,
			  },
			  ObjectiveX = {
				order = 5,
				type = "range",
				name = "任务追踪框水平偏移",
				desc = "默认: -35",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetObjectiveX,
				set = GottaGoFast.SetObjectiveX,
			  },
			  ObjectiveY = {
				order = 6,
				type = "range",
				name = "任务追踪框垂直偏移",
				desc = "Default: -40",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetObjectiveY,
				set = GottaGoFast.SetObjectiveY,
			  },
			  DemoMode = {
				order = 19,
				type = "execute",
				name = "演示模式",
				desc = "显示秘境计时器演示模式或验证设置",
				func = GottaGoFast.ToggleDemoMode,
			  },
			},
		  },
		  displayFont = {
			name = "显示: 字体",
			type = "group",
			args = {
			  TimerFontSize = {
				order = 7,
				type = "range",
				name = "时间字体尺寸",
				desc = "默认: 29",
				min = 8,
				max = 32,
				step = 1,
				get = GottaGoFast.GetTimerFontSize,
				set = GottaGoFast.SetTimerFontSize,
			  },
			  ObjectiveFontSize = {
				order = 8,
				type = "range",
				name = "任务追踪框字体",
				desc = "默认: 21",
				min = 8,
				max = 32,
				step = 1,
				get = GottaGoFast.GetObjectiveFontSize,
				set = GottaGoFast.SetObjectiveFontSize,
			  },
			  TimerFontFlag = {
				order = 9,
				type = "select",
				name = "时间字体描边",
				desc = "默认: OUTLINE",
				values = {["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME", ["NONE"] = "NONE"},
				get = GottaGoFast.GetTimerFontFlag,
				set = GottaGoFast.SetTimerFontFlag,
			  },
			  ObjectiveFontFlag = {
				order = 10,
				type = "select",
				name = "任务追踪框字体描边",
				desc = "默认: OUTLINE",
				values = {["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME", ["NONE"] = "NONE"},
				get = GottaGoFast.GetObjectiveFontFlag,
				set = GottaGoFast.SetObjectiveFontFlag,
			  },
			  TimerAlign = {
				order = 11,
				type = "select",
				name = "时间对齐",
				desc = "默认: CENTER",
				values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
				get = GottaGoFast.GetTimerAlign,
				set = GottaGoFast.SetTimerAlign,
			  },
			  ObjectiveAlign = {
				order = 12,
				type = "select",
				name = "任务追踪对齐",
				desc = "默认: LEFT",
				values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
				get = GottaGoFast.GetObjectiveAlign,
				set = GottaGoFast.SetObjectiveAlign,
			  },
			  TimerFont = {
				order = 13,
				type = "select",
				dialogControl = "LSM30_Font",
				name = "时间字体",
				desc = "Default: Arial, Monospaced Fonts like MyriadCondensedWeb are recommended",
				values = GottaGoFast.LSM:HashTable("font"),
				get = GottaGoFast.GetTimerFont,
				set = GottaGoFast.SetTimerFont,
			  },
			  ObjectiveFont = {
				order = 14,
				type = "select",
				dialogControl = "LSM30_Font",
				name = "任务追踪框字体",
				desc = "Default: Arial, Monospaced Fonts like MyriadCondensedWeb are recommended",
				values = GottaGoFast.LSM:HashTable("font"),
				get = GottaGoFast.GetObjectiveFont,
				set = GottaGoFast.SetObjectiveFont,
			  },
			  ObjectiveColor = {
				order = 15,
				type = "color",
				name = "任务追踪颜色",
				desc = "默认: White",
				get = GottaGoFast.GetObjectiveColor,
				set = GottaGoFast.SetObjectiveColor,
				hasAlpha = false,
			  },
			  ObjectiveCompleteColor = {
				order = 16,
				type = "color",
				name = "任务完成颜色",
				desc = "默认: Green",
				get = GottaGoFast.GetObjectiveCompleteColor,
				set = GottaGoFast.SetObjectiveCompleteColor,
				hasAlpha = false,
			  },
			  TimerColor = {
				order = 17,
				type = "color",
				name = "时间颜色",
				desc = "默认: White",
				get = GottaGoFast.GetTimerColor,
				set = GottaGoFast.SetTimerColor,
				hasAlpha = false,
			  },
			  IncreaseColor = {
				order = 18,
				type = "color",
				name = "钥石增加颜色",
				desc = "默认: White",
				get = GottaGoFast.GetIncreaseColor,
				set = GottaGoFast.SetIncreaseColor,
				hasAlpha = false,
			  },
			},
		  },
		},
	  };
  elseif GetLocale() == 'zhTW' then
	  options = {
		name = "GottaGoFast",
		handler = GottaGoFast,
		type = "group",
		args = {
		  cms = {
			name = "挑戰模式",
			type = "group",
			args = {
			  TimerType = {
				order = 1,
				type = "select",
				name = "時間樣式",
				desc = "TrueTimer is timed off the start of the dungeon using system time.\nI recommend you use this option.\nBlizzard's timer is known to bug up to 20 seconds.\nI will report details soon.",
				values = {["TrueTimerMS"] = "真實時間 (毫秒)", ["TrueTimerNoMS"] = "真實時間 (無毫秒)", ["Blizzard"] = "暴雪的計時"},
				get = GottaGoFast.GetTimerType,
				set = GottaGoFast.SetTimerType,
			  },
			  GoldTimer = {
				order = 2,
				type = "toggle",
				name = "金牌計時",
				desc = "開關是否顯示金牌計時",
				get = GottaGoFast.GetGoldTimer,
				set = GottaGoFast.SetGoldTimer,
			  },
			  LevelInObjectives = {
				order = 3,
				type = "toggle",
				name = "挑戰等級顯示 (任務框)",
				desc = "顯示當前挑戰等級在任務清單",
				get = GottaGoFast.GetLevelInObjectives,
				set = GottaGoFast.SetLevelInObjectives,
			  },
			  AffixesInObjectives = {
				order = 4,
				type = "toggle",
				name = "詞綴顯示(任務框)",
				desc = "顯示當前詞綴在任務清單",
				get = GottaGoFast.GetAffixesInObjectives,
				set = GottaGoFast.SetAffixesInObjectives,
			  },
			  LevelInTimer = {
				order = 5,
				type = "toggle",
				name = "挑戰等級顯示 (時間)",
				desc = "在計時器開頭顯示當前挑戰等級",
				get = GottaGoFast.GetLevelInTimer,
				set = GottaGoFast.SetLevelInTimer,
			  },
			  IncreaseInObjectives = {
				order = 6,
				type = "toggle",
				name = "鑰石升級顯示 (任務)",
				desc = "額外鑰石計時分離",
				get = GottaGoFast.GetIncreaseInObjectives,
				set = GottaGoFast.SetIncreaseInObjectives,
			  },
			  ObjectiveCompleteInObjectives = {
				order = 7,
				type = "toggle",
				name = "挑戰目標完成顯示 (目標)",
				desc = "顯示我們已經完成的任務目標",
				get = GottaGoFast.GetObjectiveCompleteInObjectives,
				set = GottaGoFast.SetObjectiveCompleteInObjectives,
			  }
			}
		  },
		  displayFrame = {
			name = "顯示: 框體",
			type = "group",
			args = {
			  unlocked = {
				order = 1,
				type = "toggle",
				name = "解鎖",
				desc = "開關時間框體的解鎖狀態",
				get = GottaGoFast.GetUnlocked,
				set = GottaGoFast.SetUnlocked,
			  },
			  ObjectiveCollapsed = {
				order = 2,
				type = "toggle",
				name = "任務追蹤框折疊",
				desc = "當離開挑戰或時光漫遊戲本時折疊任務追蹤框",
				get = GottaGoFast.GetObjectiveCollapsed,
				set = GottaGoFast.SetObjectiveCollapsed,
			  },
			  TimerX = {
				order = 3,
				type = "range",
				name = "計時器水準偏移",
				desc = "默認: -35",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetTimerX,
				set = GottaGoFast.SetTimerX,
			  },
			  TimerY = {
				order = 4,
				type = "range",
				name = "計時器垂直偏移",
				desc = "默認: 0",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetTimerY,
				set = GottaGoFast.SetTimerY,
			  },
			  ObjectiveX = {
				order = 5,
				type = "range",
				name = "任務追蹤框水準偏移",
				desc = "默認: -35",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetObjectiveX,
				set = GottaGoFast.SetObjectiveX,
			  },
			  ObjectiveY = {
				order = 6,
				type = "range",
				name = "任務追蹤框垂直偏移",
				desc = "Default: -40",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetObjectiveY,
				set = GottaGoFast.SetObjectiveY,
			  },
			  DemoMode = {
				order = 19,
				type = "execute",
				name = "演示模式",
				desc = "顯示秘境計時器演示模式或驗證設置",
				func = GottaGoFast.ToggleDemoMode,
			  },
			},
		  },
		  displayFont = {
			name = "顯示: 字體",
			type = "group",
			args = {
			  TimerFontSize = {
				order = 7,
				type = "range",
				name = "時間字體尺寸",
				desc = "默認: 29",
				min = 8,
				max = 32,
				step = 1,
				get = GottaGoFast.GetTimerFontSize,
				set = GottaGoFast.SetTimerFontSize,
			  },
			  ObjectiveFontSize = {
				order = 8,
				type = "range",
				name = "任務追蹤框字體",
				desc = "默認: 21",
				min = 8,
				max = 32,
				step = 1,
				get = GottaGoFast.GetObjectiveFontSize,
				set = GottaGoFast.SetObjectiveFontSize,
			  },
			  TimerFontFlag = {
				order = 9,
				type = "select",
				name = "時間字體描邊",
				desc = "默認: OUTLINE",
				values = {["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME", ["NONE"] = "NONE"},
				get = GottaGoFast.GetTimerFontFlag,
				set = GottaGoFast.SetTimerFontFlag,
			  },
			  ObjectiveFontFlag = {
				order = 10,
				type = "select",
				name = "任務追蹤框字體描邊",
				desc = "默認: OUTLINE",
				values = {["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME", ["NONE"] = "NONE"},
				get = GottaGoFast.GetObjectiveFontFlag,
				set = GottaGoFast.SetObjectiveFontFlag,
			  },
			  TimerAlign = {
				order = 11,
				type = "select",
				name = "時間對齊",
				desc = "默認: CENTER",
				values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
				get = GottaGoFast.GetTimerAlign,
				set = GottaGoFast.SetTimerAlign,
			  },
			  ObjectiveAlign = {
				order = 12,
				type = "select",
				name = "任務追蹤對齊",
				desc = "默認: LEFT",
				values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
				get = GottaGoFast.GetObjectiveAlign,
				set = GottaGoFast.SetObjectiveAlign,
			  },
			  TimerFont = {
				order = 13,
				type = "select",
				dialogControl = "LSM30_Font",
				name = "時間字體",
				desc = "Default: Arial, Monospaced Fonts like MyriadCondensedWeb are recommended",
				values = GottaGoFast.LSM:HashTable("font"),
				get = GottaGoFast.GetTimerFont,
				set = GottaGoFast.SetTimerFont,
			  },
			  ObjectiveFont = {
				order = 14,
				type = "select",
				dialogControl = "LSM30_Font",
				name = "任務追蹤框字體",
				desc = "Default: Arial, Monospaced Fonts like MyriadCondensedWeb are recommended",
				values = GottaGoFast.LSM:HashTable("font"),
				get = GottaGoFast.GetObjectiveFont,
				set = GottaGoFast.SetObjectiveFont,
			  },
			  ObjectiveColor = {
				order = 15,
				type = "color",
				name = "任務追蹤顏色",
				desc = "默認: White",
				get = GottaGoFast.GetObjectiveColor,
				set = GottaGoFast.SetObjectiveColor,
				hasAlpha = false,
			  },
			  ObjectiveCompleteColor = {
				order = 16,
				type = "color",
				name = "任務完成顏色",
				desc = "默認: Green",
				get = GottaGoFast.GetObjectiveCompleteColor,
				set = GottaGoFast.SetObjectiveCompleteColor,
				hasAlpha = false,
			  },
			  TimerColor = {
				order = 17,
				type = "color",
				name = "時間顏色",
				desc = "默認: White",
				get = GottaGoFast.GetTimerColor,
				set = GottaGoFast.SetTimerColor,
				hasAlpha = false,
			  },
			  IncreaseColor = {
				order = 18,
				type = "color",
				name = "鑰石增加顏色",
				desc = "默認: White",
				get = GottaGoFast.GetIncreaseColor,
				set = GottaGoFast.SetIncreaseColor,
				hasAlpha = false,
			  },
			},
		  },
		},
	  };
  else
	  options = {
		name = "GottaGoFast",
		handler = GottaGoFast,
		type = "group",
		args = {
		  cms = {
			name = "Challenge Modes",
			type = "group",
			args = {
			  TimerType = {
				order = 1,
				type = "select",
				name = "Timer Type",
				desc = "TrueTimer is timed off the start of the dungeon using system time.\nI recommend you use this option.\nBlizzard's timer is known to bug up to 20 seconds.\nI will report details soon.",
				values = {["TrueTimerMS"] = "TrueTimer (Miliseconds)", ["TrueTimerNoMS"] = "TrueTimer (No Miliseconds)", ["Blizzard"] = "Blizzard's Timer"},
				get = GottaGoFast.GetTimerType,
				set = GottaGoFast.SetTimerType,
			  },
			  GoldTimer = {
				order = 2,
				type = "toggle",
				name = "Gold Timer",
				desc = "Toggles Gold Timer",
				get = GottaGoFast.GetGoldTimer,
				set = GottaGoFast.SetGoldTimer,
			  },
			  LevelInObjectives = {
				order = 3,
				type = "toggle",
				name = "CM Level Display (Objectives)",
				desc = "Show the current CM Level in the objectives list",
				get = GottaGoFast.GetLevelInObjectives,
				set = GottaGoFast.SetLevelInObjectives,
			  },
			  AffixesInObjectives = {
				order = 4,
				type = "toggle",
				name = "Affix Display (Objectives)",
				desc = "Show the current Affixes in the objectives list",
				get = GottaGoFast.GetAffixesInObjectives,
				set = GottaGoFast.SetAffixesInObjectives,
			  },
			  LevelInTimer = {
				order = 5,
				type = "toggle",
				name = "CM Level Display (Timer)",
				desc = "Show the current CM Level at the start of the timer",
				get = GottaGoFast.GetLevelInTimer,
				set = GottaGoFast.SetLevelInTimer,
			  },
			  IncreaseInObjectives = {
				order = 6,
				type = "toggle",
				name = "Keystone Increase Display (Objectives)",
				desc = "Bonus Keystone Time Splits",
				get = GottaGoFast.GetIncreaseInObjectives,
				set = GottaGoFast.SetIncreaseInObjectives,
			  },
			  ObjectiveCompleteInObjectives = {
				order = 7,
				type = "toggle",
				name = "CM Objective Complete Display (Objectives)",
				desc = "Show the time objectives we're completed at",
				get = GottaGoFast.GetObjectiveCompleteInObjectives,
				set = GottaGoFast.SetObjectiveCompleteInObjectives,
			  }
			}
		  },
		  displayFrame = {
			name = "Display: Frame",
			type = "group",
			args = {
			  unlocked = {
				order = 1,
				type = "toggle",
				name = "Unlocked",
				desc = "Toggles Unlock State Of Timer Frame",
				get = GottaGoFast.GetUnlocked,
				set = GottaGoFast.SetUnlocked,
			  },
			  ObjectiveCollapsed = {
				order = 2,
				type = "toggle",
				name = "Objective Tracker Collapse",
				desc = "Collapse Objective Tracker When Leaving CM / Timewalker",
				get = GottaGoFast.GetObjectiveCollapsed,
				set = GottaGoFast.SetObjectiveCollapsed,
			  },
			  TimerX = {
				order = 3,
				type = "range",
				name = "Timer X Offset",
				desc = "Default: 0",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetTimerX,
				set = GottaGoFast.SetTimerX,
			  },
			  TimerY = {
				order = 4,
				type = "range",
				name = "Timer Y Offset",
				desc = "Default: 0",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetTimerY,
				set = GottaGoFast.SetTimerY,
			  },
			  ObjectiveX = {
				order = 5,
				type = "range",
				name = "Objective X Offset",
				desc = "Default: 0",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetObjectiveX,
				set = GottaGoFast.SetObjectiveX,
			  },
			  ObjectiveY = {
				order = 6,
				type = "range",
				name = "Objective Y Offset",
				desc = "Default: -40",
				min = -100,
				max = 100,
				step = 1,
				get = GottaGoFast.GetObjectiveY,
				set = GottaGoFast.SetObjectiveY,
			  },
			  DemoMode = {
				order = 19,
				type = "execute",
				name = "Demo Mode",
				desc = "Shows GottaGoFast Outside CM For Demo / Setup Purposes",
				func = GottaGoFast.ToggleDemoMode,
			  },
			},
		  },
		  displayFont = {
			name = "Display: Font",
			type = "group",
			args = {
			  TimerFontSize = {
				order = 7,
				type = "range",
				name = "Timer Font Size",
				desc = "Default: 29",
				min = 8,
				max = 32,
				step = 1,
				get = GottaGoFast.GetTimerFontSize,
				set = GottaGoFast.SetTimerFontSize,
			  },
			  ObjectiveFontSize = {
				order = 8,
				type = "range",
				name = "Objective Font Size",
				desc = "Default: 21",
				min = 8,
				max = 32,
				step = 1,
				get = GottaGoFast.GetObjectiveFontSize,
				set = GottaGoFast.SetObjectiveFontSize,
			  },
			  TimerFontFlag = {
				order = 9,
				type = "select",
				name = "Timer Font Flag",
				desc = "Default: OUTLINE",
				values = {["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME", ["NONE"] = "NONE"},
				get = GottaGoFast.GetTimerFontFlag,
				set = GottaGoFast.SetTimerFontFlag,
			  },
			  ObjectiveFontFlag = {
				order = 10,
				type = "select",
				name = "Objective Font Flag",
				desc = "Default: OUTLINE",
				values = {["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME", ["NONE"] = "NONE"},
				get = GottaGoFast.GetObjectiveFontFlag,
				set = GottaGoFast.SetObjectiveFontFlag,
			  },
			  TimerAlign = {
				order = 11,
				type = "select",
				name = "Timer Align",
				desc = "Default: CENTER",
				values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
				get = GottaGoFast.GetTimerAlign,
				set = GottaGoFast.SetTimerAlign,
			  },
			  ObjectiveAlign = {
				order = 12,
				type = "select",
				name = "Objective Align",
				desc = "Default: LEFT",
				values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
				get = GottaGoFast.GetObjectiveAlign,
				set = GottaGoFast.SetObjectiveAlign,
			  },
			  TimerFont = {
				order = 13,
				type = "select",
				dialogControl = "LSM30_Font",
				name = "Timer Font",
				desc = "Default: Arial, Monospaced Fonts like MyriadCondensedWeb are recommended",
				values = GottaGoFast.LSM:HashTable("font"),
				get = GottaGoFast.GetTimerFont,
				set = GottaGoFast.SetTimerFont,
			  },
			  ObjectiveFont = {
				order = 14,
				type = "select",
				dialogControl = "LSM30_Font",
				name = "Objective Font",
				desc = "Default: Arial, Monospaced Fonts like MyriadCondensedWeb are recommended",
				values = GottaGoFast.LSM:HashTable("font"),
				get = GottaGoFast.GetObjectiveFont,
				set = GottaGoFast.SetObjectiveFont,
			  },
			  ObjectiveColor = {
				order = 15,
				type = "color",
				name = "Objective Color",
				desc = "Default: White",
				get = GottaGoFast.GetObjectiveColor,
				set = GottaGoFast.SetObjectiveColor,
				hasAlpha = false,
			  },
			  ObjectiveCompleteColor = {
				order = 16,
				type = "color",
				name = "Objective Complete Color",
				desc = "Default: Green",
				get = GottaGoFast.GetObjectiveCompleteColor,
				set = GottaGoFast.SetObjectiveCompleteColor,
				hasAlpha = false,
			  },
			  TimerColor = {
				order = 17,
				type = "color",
				name = "Timer Color",
				desc = "Default: White",
				get = GottaGoFast.GetTimerColor,
				set = GottaGoFast.SetTimerColor,
				hasAlpha = false,
			  },
			  IncreaseColor = {
				order = 18,
				type = "color",
				name = "Keystone Increase Color",
				desc = "Default: White",
				get = GottaGoFast.GetIncreaseColor,
				set = GottaGoFast.SetIncreaseColor,
				hasAlpha = false,
			  },
			},
		  },
		},
	  };
  end
  GottaGoFast.db = LibStub("AceDB-3.0"):New("GottaGoFastDB", defaults, true);
  LibStub("AceConfig-3.0"):RegisterOptionsTable("GottaGoFast", options);
  GottaGoFast.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GottaGoFast", "GottaGoFast");
end
