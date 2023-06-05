local interval
local checkAlarmElapsed = 0
local frame = CreateFrame("Frame")
-- local clockFrame = CreateFrame("Frame", "ReminderClockFrame", UIParent)
local addonName = "BreakTimer"
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED");
local newVarsBool = false -- set to instantiate new globals table. THIS DOES NOT SAVE LOCAL VARS
function loadVariables()
    -- todo if the breaktime table isn't in the format we expect, we need to have a way to initialize
    if BREAKTIMER_AllSavedVars == nil or newVarsBool == true then
        print("setting new vars")
        BREAKTIMER_AllSavedVars = {
            ["acceptText"] = "OK",
            ["cancelText"] = "Not Now",
            ["dialogText"] = "Time to get up",
            ["playerInterval"] = 10,
            ["alarmHour"] = 1,
            ["alarmMinute"] = 11,
        }
        BREAKTIMER_AllSavedVars = BREAKTIMER_AllSavedVars -- store variables back in table
    end
    acceptText = BREAKTIMER_AllSavedVars["acceptText"]
    cancelText = BREAKTIMER_AllSavedVars["cancelText"]
    dialogText = BREAKTIMER_AllSavedVars["dialogText"]
    playerInterval = BREAKTIMER_AllSavedVars["playerInterval"]
    alarmHour = BREAKTIMER_AllSavedVars["alarmHour"]
    alarmMinute = BREAKTIMER_AllSavedVars["alarmMinute"]
    interval = playerInterval
end
function checkAlarm()
    local serverHour, serverMinute = GetGameTime()
    -- Check if the current time matches the target time
    if alarmHour == serverHour and alarmMinute == serverMinute then
        -- Display a popup message
        StaticPopupDialogs["ALARM_POPUP"] = {
            text = "It's " .. alarmHour .. ":" .. alarmMinute .." Server Time! Time to get off and head to bed!",
            button1 = "Dismiss",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("ALARM_POPUP")
    end
end
function setReminder(elapsed)
    if not reminderShown then
        interval = interval - elapsed
        if interval <= 0 then
            -- Display a popup message
            StaticPopupDialogs["REMINDER_POPUP"] = {
                text = dialogText,
                button1 = acceptText,
                button2 = cancelText,
                OnAccept = function()
                    interval = playerInterval -- Reset the interval based on the player's setting or default value
                    reminderShown = false -- Reset the reminder status
                    print("Reminder dismissed for " .. playerInterval .. " seconds")
                end,
                OnCancel = function()
                    local snoozeInterval = math.floor(playerInterval * 0.5) -- Set snooze interval to 50% of the current interval
                    interval = snoozeInterval-- Reset the interval to the snoozeInterval
                    reminderShown = false -- Reset the reminder status
                    print("Reminder snoozed for " .. snoozeInterval .. " seconds.")
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3, -- Set the popup's layer to be above other UI elements
            }
            StaticPopup_Show("REMINDER_POPUP")
            reminderShown = true -- Set the reminder status to true to prevent repeated reminders
            checkAlarm() -- we'll check the alram at this time to see if we've passed the time
        end
    end
end
function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "BreakTimer" then
        loadVariables()
    end
    if event == "PLAYER_LOGIN" then
        self:SetScript("OnUpdate", function(self, elapsed)
            -- check alarm every minute
            checkAlarmElapsed = checkAlarmElapsed + elapsed
            if checkAlarmElapsed >= 10 then 
                checkAlarm()
                checkAlarmElapsed = 0
            end
            setReminder(elapsed)
        end)
    end
end
frame:SetScript("OnEvent", OnEvent);


function SetReminderInterval(value)
    value = tonumber(value) or interval -- Default to 3600 seconds (1 hour) if the input is invalid
    playerInterval = value 
    interval = value
    print("Reminder interval set to " .. value .. " seconds.")
end
local function OpenMenu()
    print("Opening menu")
    AceConfigDialog:SetDefaultSize(addonName, 400, 300) -- Set the default size of the dialog
    AceConfigDialog:Open(addonName) -- Open the dialog to the addon's category
end

local function SlashCommandHandler(cmd)
    if cmd == "menu" then
        OpenMenu()
    elseif cmd == "timeleft" then
        print(interval .. " seconds")
    else
        print("Invalid command. Use '/bt menu' to open the options menu.")
    end
end

-- Register a slash command to set the reminder interval in-game
SLASH_REMINDERINTERVAL1 = "/breaktime"
SlashCmdList["REMINDERINTERVAL"] = SlashCommandHandler