function GottaGoFast.UpdateCM()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    GottaGoFast.UpdateCMTimer();
  end
end

function GottaGoFast.EmpoweredString()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local empowered = GottaGoFast.CurrentCM["Empowered"];
    if (empowered) then
      return "Empowered";
    else
      return "Depleted";
    end
  end
  return "?";
end

function GottaGoFast.BuildCMTooltip()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local newTooltip;
    local cmLevel = GottaGoFast.CurrentCM["Level"];
    local empowered = GottaGoFast.EmpoweredString();
    local bonus = GottaGoFast.CurrentCM["Bonus"];
    if (cmLevel) then
      newTooltip = empowered .. ": Level " .. cmLevel .. " - " .. tostring(bonus) .. "%\n\n";
      if (next(GottaGoFast.CurrentCM["Affixes"])) then
        for i, affixID in pairs(GottaGoFast.CurrentCM["Affixes"]) do
          local affixName = affixID["name"];
          local affixDesc = affixID["desc"];
          newTooltip = newTooltip .. affixName .. "\n" .. affixDesc .. "\n\n";
        end
      end
      newTooltip = GottaGoFast.Utility.ShortenStr(newTooltip, 2);
      GottaGoFast.tooltip = newTooltip;
    else
      GottaGoFast.tooltip = GottaGoFast.defaultTooltip;
    end
  end
end

function GottaGoFast.InitCM(currentZoneID)
  GottaGoFast.Utility.DebugPrint("Player Entered Challenge Mode");
  GottaGoFast.WipeCM();
  GottaGoFast.Utility.DebugPrint("Wiping CM");
  GottaGoFast.SetupCM(currentZoneID);
  GottaGoFast.Utility.DebugPrint("Setting Up CM");
  GottaGoFast.UpdateCMTimer();
  GottaGoFast.Utility.DebugPrint("Setting Up Timer");
  GottaGoFast.UpdateCMObjectives();
  GottaGoFast.Utility.DebugPrint("Setting Up Objectives");
  GottaGoFast.inCM = true;
  GottaGoFast.inTW = false;
  GottaGoFastFrame:SetScript("OnUpdate", GottaGoFast.UpdateCM);
  GottaGoFast.Utility.DebugPrint("Setting Up Update Script");
  GottaGoFast.ShowFrames();
  GottaGoFast.Utility.DebugPrint("Showing Frames");
end

function GottaGoFast.SetupCM(currentZoneID)
  local _, _, steps = C_Scenario.GetStepInfo();
  local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
  GottaGoFast.CurrentCM = {};
  GottaGoFast.CurrentCM["StartTime"] = nil;
  GottaGoFast.CurrentCM["Time"] = nil;
  GottaGoFast.CurrentCM["CurrentTime"] = nil;
  GottaGoFast.CurrentCM["String"] = nil;
  GottaGoFast.CurrentCM["Name"], GottaGoFast.CurrentCM["ZoneID"], GottaGoFast.CurrentCM["GoldTimer"] = C_ChallengeMode.GetMapInfo(currentZoneID);
  GottaGoFast.CurrentCM["Deaths"] = 0;
  GottaGoFast.CurrentCM["Steps"] = steps;
  GottaGoFast.CurrentCM["Level"] = cmLevel;
  GottaGoFast.CurrentCM["Empowered"] = empowered;
  GottaGoFast.CurrentCM["Bonus"] = "?";
  GottaGoFast.CurrentCM["Completed"] = false;
  GottaGoFast.CurrentCM["AskedTime"] = nil;
  GottaGoFast.CurrentCM["AskedForTimer"] = false;
  GottaGoFast.CurrentCM["Affixes"] = {};
  GottaGoFast.CurrentCM["CurrentValues"] = {};
  GottaGoFast.CurrentCM["FinalValues"] = {};
  GottaGoFast.CurrentCM["ObjectiveTimes"] = {};
  GottaGoFast.CurrentCM["Bosses"] = {};
  GottaGoFast.CurrentCM["IncreaseTimers"] = {};

  if (cmLevel) then
    GottaGoFast.CurrentCM["Bonus"] = C_ChallengeMode.GetPowerLevelDamageHealthMod(cmLevel);
  end

  for i, affixID in ipairs(affixes) do
    local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID);
    GottaGoFast.CurrentCM["Affixes"][affixID] = {};
    GottaGoFast.CurrentCM["Affixes"][affixID]["name"] = affixName;
    GottaGoFast.CurrentCM["Affixes"][affixID]["desc"] = affixDesc;
  end

  for i = 1, steps do
    local name, _, status, curValue, finalValue = C_Scenario.GetCriteriaInfo(i);
    GottaGoFast.CurrentCM["CurrentValues"][i] = curValue;
    GottaGoFast.CurrentCM["FinalValues"][i] = finalValue;
    GottaGoFast.CurrentCM["Bosses"][i] = name;
    if (i == steps) then
      GottaGoFast.CurrentCM["FinalValues"][i] = 100;
    end
  end

  if (GottaGoFast.CurrentCM["GoldTimer"]) then
    GottaGoFast.CurrentCM["IncreaseTimers"][1] = GottaGoFast.CurrentCM["GoldTimer"];
    GottaGoFast.CurrentCM["IncreaseTimers"][2] = GottaGoFast.CurrentCM["GoldTimer"] * 0.8;
    GottaGoFast.CurrentCM["IncreaseTimers"][3] = GottaGoFast.CurrentCM["GoldTimer"] * 0.6;
  end

  GottaGoFast.BuildCMTooltip();
  GottaGoFast.HideObjectiveTracker();
  GottaGoFast.InitDungeon(GottaGoFast.CurrentCM["Name"], GottaGoFast.CurrentCM["ZoneID"], GottaGoFast.CurrentCM["Bosses"]);
end

function GottaGoFast.SetupFakeCM()
  local affixes = {2, 7, 10};
  GottaGoFast.CurrentCM = {};
  GottaGoFast.CurrentCM["StartTime"] = GetTime() - (60*5);
  GottaGoFast.CurrentCM["Time"] = nil;
  GottaGoFast.CurrentCM["CurrentTime"] = nil;
  GottaGoFast.CurrentCM["String"] = nil;
  GottaGoFast.CurrentCM["Name"], GottaGoFast.CurrentCM["ZoneID"], GottaGoFast.CurrentCM["GoldTimer"] = C_ChallengeMode.GetMapInfo(1458);
  GottaGoFast.CurrentCM["Deaths"] = 0;
  GottaGoFast.CurrentCM["Steps"] = 5;
  GottaGoFast.CurrentCM["Level"] = 10;
  GottaGoFast.CurrentCM["Empowered"] = true;
  GottaGoFast.CurrentCM["Bonus"] = 100;
  GottaGoFast.CurrentCM["Completed"] = false;
  GottaGoFast.CurrentCM["AskedTime"] = nil;
  GottaGoFast.CurrentCM["AskedForTimer"] = false;
  GottaGoFast.CurrentCM["Affixes"] = {};
  GottaGoFast.CurrentCM["CurrentValues"] = {1, 1, 0, 0, 40};
  GottaGoFast.CurrentCM["FinalValues"] = {1, 1, 1, 1, 100};
  GottaGoFast.CurrentCM["ObjectiveTimes"] = {"1:15.460", "3:45.012"};
  GottaGoFast.CurrentCM["Bosses"] = {"Rokmora", "Ularogg Cragshaper", "Naraxas", "Dargrul", "Enemy Forces"};
  GottaGoFast.CurrentCM["IncreaseTimers"] = {};

  for i, affixID in ipairs(affixes) do
    local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID);
    GottaGoFast.CurrentCM["Affixes"][affixID] = {};
    GottaGoFast.CurrentCM["Affixes"][affixID]["name"] = affixName;
    GottaGoFast.CurrentCM["Affixes"][affixID]["desc"] = affixDesc;
  end

  if (GottaGoFast.CurrentCM["GoldTimer"]) then
    GottaGoFast.CurrentCM["IncreaseTimers"][1] = GottaGoFast.CurrentCM["GoldTimer"];
    GottaGoFast.CurrentCM["IncreaseTimers"][2] = GottaGoFast.CurrentCM["GoldTimer"] * 0.8;
    GottaGoFast.CurrentCM["IncreaseTimers"][3] = GottaGoFast.CurrentCM["GoldTimer"] * 0.6;
  end

  GottaGoFast.BuildCMTooltip();
  GottaGoFast.HideObjectiveTracker();
end

function GottaGoFast.UpdateCMInformation()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    if (GottaGoFast.CurrentCM["Completed"] == false) then
      for i = 1, GottaGoFast.CurrentCM["Steps"] do
        local name, _, status, curValue, finalValue = C_Scenario.GetCriteriaInfo(i);
        if (finalValue == 0 or not finalValue) then
          -- Final Value = 0 Means CM Complete
          GottaGoFast.CompleteCM();
          return false;
        end
        if (GottaGoFast.CurrentCM["CurrentValues"][i] ~= curValue) then
          -- Update Value
          GottaGoFast.CurrentCM["CurrentValues"][i] = curValue;
          if (curValue == finalValue or ((i == GottaGoFast.CurrentCM["Steps"]) and (curValue == GottaGoFast.CurrentCM["FinalValues"][i]))) then
            -- Add Objective Time
            GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.ObjectiveCompleteString(GottaGoFast.Utility.ShortenStr(GottaGoFast.CurrentCM["Time"], 1));
          end
        elseif (GottaGoFast.CurrentCM["CurrentValues"][i] == GottaGoFast.CurrentCM["FinalValues"][i] and not GottaGoFast.CurrentCM["ObjectiveTimes"][i]) then
          -- Objective Already Complete But No Time Filled Out (Re-Log / Re-Zone)
          GottaGoFast.CurrentCM["ObjectiveTimes"][i] = "?";
        end
      end
    end
  end
end

function GottaGoFast.CMFinalParse()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    for i = 1, GottaGoFast.CurrentCM["Steps"] do
      GottaGoFast.CurrentCM["CurrentValues"][i] = GottaGoFast.CurrentCM["FinalValues"][i];
      if (not GottaGoFast.CurrentCM["ObjectiveTimes"][i]) then
        GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.ObjectiveCompleteString(GottaGoFast.Utility.ShortenStr(GottaGoFast.CurrentCM["Time"], 1));
      end
    end
  end
end

function GottaGoFast.WipeCM()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    GottaGoFast.CurrentCM = table.wipe(GottaGoFast.CurrentCM);
  end
end

function GottaGoFast.StartCM(offset)
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    GottaGoFast.CurrentCM["StartTime"] = GetTime() + offset;
    GottaGoFast.BuildCMTooltip();
  end
end

function GottaGoFast.CompleteCM()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    GottaGoFast.CurrentCM["Completed"] = true;
    GottaGoFast.CMFinalParse();
  end
end

function GottaGoFast.UpdateCMTimer()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    if (GottaGoFast.CurrentCM["Completed"] == false) then
      local time = "";
      local startMin, startSec, goldMin, goldSec;
      if (GottaGoFast.CurrentCM["StartTime"] and GottaGoFast.GetTrueTimer()) then
        local currentTime = GetTime();
        local deaths = GottaGoFast.CurrentCM["Deaths"] * 5;
        local secs = currentTime - GottaGoFast.CurrentCM["StartTime"];
        GottaGoFast.CurrentCM["CurrentTime"] = secs;
        secs = secs + deaths;
        if (secs < 0) then
          startMin = "-00";
          if (GottaGoFast.GetTimerType(nil) == "TrueTimerMS") then
            startSec = GottaGoFast.FormatTimeMS(math.abs(secs));
          else
            startSec = GottaGoFast.FormatTimeNoMS(math.abs(secs));
          end
        else
          startMin, startSec = GottaGoFast.SecondsToTime(secs);
          startMin = GottaGoFast.FormatTimeNoMS(startMin);
          if (GottaGoFast.GetTimerType(nil) == "TrueTimerMS") then
            startSec = GottaGoFast.FormatTimeMS(startSec);
          else
            startSec = GottaGoFast.FormatTimeNoMS(startSec);
          end
        end
      else
        _, timeCM = GetWorldElapsedTime(1);
        GottaGoFast.AskForTimer(timeCM);
        startMin, startSec = GottaGoFast.SecondsToTime(timeCM);
        startMin = GottaGoFast.FormatTimeNoMS(startMin);
        startSec = GottaGoFast.FormatTimeNoMS(startSec);
      end
      time = startMin .. ":" .. startSec .. " ";
      GottaGoFast.CurrentCM["Time"] = time;
      goldMin, goldSec = GottaGoFast.SecondsToTime(GottaGoFast.CurrentCM["GoldTimer"]);
      goldMin = GottaGoFast.FormatTimeNoMS(goldMin);
      goldSec = GottaGoFast.FormatTimeNoMS(goldSec);

      if (GottaGoFast.db.profile.GoldTimer) then
        time = time .. "/ " .. goldMin .. ":" .. goldSec;
      end

      if (GottaGoFast.db.profile.LevelInTimer and GottaGoFast.CurrentCM["Level"]) then
        local depleted = "";
        if (GottaGoFast.CurrentCM["Empowered"] == false) then
          depleted = "d";
        end
        time = "[" .. GottaGoFast.CurrentCM["Level"] .. depleted .. "] " .. time;
      end

      -- Update Frame
      GottaGoFastTimerFrame.font:SetText(GottaGoFast.ColorTimer(time));
      GottaGoFast.ResizeFrame();
    end
  end
end

function GottaGoFast.UpdateCMObjectives()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local empowered = GottaGoFast.EmpoweredString();
    local objectiveString = "";
    local affixString = "";
    local increaseString = "";
    local goldMin, goldSec;
    if (GottaGoFast.db.profile.IncreaseInObjectives and next(GottaGoFast.CurrentCM["IncreaseTimers"])) then
      for k, v in pairs(GottaGoFast.CurrentCM["IncreaseTimers"]) do
        if (k ~= 1 or GottaGoFast.db.profile.GoldTimer == false) then
          goldMin, goldSec = GottaGoFast.SecondsToTime(v);
          goldMin = GottaGoFast.FormatTimeNoMS(goldMin);
          goldSec = GottaGoFast.FormatTimeNoMS(goldSec);
          increaseString = increaseString .. "+" .. k .. " = " .. goldMin .. ":" .. goldSec .. " / ";
        end
      end
      objectiveString = objectiveString .. GottaGoFast.IncreaseColorString(GottaGoFast.Utility.ShortenStr(increaseString, 3) .. "\n");
    end
    if (GottaGoFast.db.profile.LevelInObjectives and GottaGoFast.CurrentCM["Level"]) then
      objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString("Level " .. GottaGoFast.CurrentCM["Level"] .. " - (+" .. GottaGoFast.CurrentCM["Bonus"] .. "%) - " .. empowered .. "\n");
    end
    if (GottaGoFast.db.profile.AffixesInObjectives and next(GottaGoFast.CurrentCM["Affixes"])) then
      for k, v in pairs(GottaGoFast.CurrentCM["Affixes"]) do
        affixString = affixString .. v["name"] .. " - ";
      end
      objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString(GottaGoFast.Utility.ShortenStr(affixString, 3) .. "\n");
    end
    for i = 1, GottaGoFast.CurrentCM["Steps"] do
      if (i == GottaGoFast.CurrentCM["Steps"]) then
        -- Last Step Should Be Enemies
        objectiveString = objectiveString .. GottaGoFast.ObjectiveEnemyString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i]);
      else
        objectiveString = objectiveString .. GottaGoFast.ObjectiveString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i], GottaGoFast.CurrentCM["FinalValues"][i]);
      end
      if (GottaGoFast.db.profile.ObjectiveCompleteInObjectives and GottaGoFast.CurrentCM["ObjectiveTimes"][i]) then
        -- Completed Objective
        objectiveString = objectiveString .. GottaGoFast.ObjectiveCompletedString(GottaGoFast.CurrentCM["ObjectiveTimes"][i]);
      end
      objectiveString = objectiveString .. "\n";
    end
    GottaGoFastObjectiveFrame.font:SetText(objectiveString);
    GottaGoFast.ResizeFrame();
  end
end

function GottaGoFast.AskForTimer(timeCM)
  if (GottaGoFast.CurrentCM["StartTime"] == nil and timeCM > 1 and GottaGoFast.CurrentCM["AskedForTimer"] == false) then
    GottaGoFast.Utility.DebugPrint("Asking For Timer");
    GottaGoFast.CurrentCM["AskedTime"] = GetTime();
    GottaGoFast.CurrentCM["AskedForTimer"] = true;
    GottaGoFast:SendCommMessage("GottaGoFastCM", "FixCM", "PARTY", nil, "ALERT");
  end
end

function GottaGoFast.CheckCMTimer()
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil and GottaGoFast.CurrentCM["StartTime"]) then
    local CurrentCMString = GottaGoFast:Serialize(GottaGoFast.CurrentCM);
    GottaGoFast.Utility.DebugPrint("CM Timer Sent");
    GottaGoFast:SendCommMessage("GottaGoFastCM", CurrentCMString, "PARTY", nil, "ALERT");
  end
end

function GottaGoFast.FixCMTimer(input)
  if (GottaGoFast.inCM == true and GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
    if (GottaGoFast.CurrentCM["StartTime"] == nil and GottaGoFast.CurrentCM["AskedTime"] ~= nil) then
      GottaGoFast.Utility.DebugPrint("Replacing CM Timer");
      local status, newCM = GottaGoFast:Deserialize(input);
      if (status) then
        newCM["StartTime"] = GottaGoFast.CurrentCM["AskedTime"] - newCM["CurrentTime"];
        GottaGoFast.CurrentCM = newCM;
        -- Update Timer
        GottaGoFast.UpdateCMTimer();
        GottaGoFast.UpdateCMObjectives();
      end
    end
  end
end
