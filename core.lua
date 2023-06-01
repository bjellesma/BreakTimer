
local ACCEPTTEXT = "OK"
local DIALOGTEXT = "Time to get up"
local CANCELTEXT = "Not Now"
local DEFAULT_INTERVAL = 3600
local interval = DEFAULT_INTERVAL -- Set the reminder interval in seconds (1 hour = 3600 seconds)
-- local clockFrame = CreateFrame("Frame", "ReminderClockFrame", UIParent)
local addonName = "BreakTimer"
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")

local function SetReminderInterval(value)
    value = tonumber(value) or interval -- Default to 3600 seconds (1 hour) if the input is invalid
    DEFAULT_INTERVAL = value -- interval will be used instead of the default
    interval = value
    SetCVar("reminderInterval", value)
    print("Reminder interval set to " .. value .. " seconds.")
end

AceConfig:RegisterOptionsTable("BreakTimer", {
    type = "group",
    name = "BreakTimer",
    args = {
        option2 = {
            type = "range",
            name = "Reminder Interval (minutes)",
            desc = "Set the reminder interval",
            min = 1,
            max = 60,
            step = 1,
            get = function()
                return DEFAULT_INTERVAL -- Replace "MyAddon.db.interval" with the appropriate variable or function to get the current value
            end,
            set = function(_, value)
                value = value * 60
                SetReminderInterval(value) -- Replace "MyAddon.db.interval" with the appropriate variable or function to set the new value
            end,
        },
        option3 = {
            type = "input", -- Use "input" type for text box
            name = "Reminder Text",
            desc = "Enter a custom message",
            get = function()
                return DIALOGTEXT
            end,
            set = function(_, value)
                DIALOGTEXT = value
            end,
        },
        option4 = {
            type = "input", -- Use "input" type for text box
            name = "Accept Text",
            desc = "Enter a custom message",
            get = function()
                return ACCEPTTEXT
            end,
            set = function(_, value)
                ACCEPTTEXT = value
            end,
        },
        option5 = {
            type = "input", -- Use "input" type for text box
            name = "Cancel Text",
            desc = "Enter a custom message",
            get = function()
                return CANCELTEXT
            end,
            set = function(_, value)
                CANCELTEXT = value
            end,
        },
    },
})

local function OnEvent(self, event)
    if event == "PLAYER_LOGIN" then
        self:SetScript("OnUpdate", function(self, elapsed)
            if not reminderShown then
                interval = interval - elapsed
                if interval <= 0 then
                    -- Display a popup message
                    StaticPopupDialogs["REMINDER_POPUP"] = {
                        text = DIALOGTEXT,
                        button1 = ACCEPTTEXT,
                        button2 = CANCELTEXT,
                        OnAccept = function()
                            interval = tonumber(GetCVar("reminderInterval")) or DEFAULT_INTERVAL -- Reset the interval based on the player's setting or default value
                            reminderShown = false -- Reset the reminder status
                            print("Reminder dismissed.")
                        end,
                        OnCancel = function()
                            local snoozeInterval = math.floor(DEFAULT_INTERVAL * 0.5) -- Set snooze interval to 10% of the current interval
                            interval = snoozeInterval-- Reset the interval to the default value + snooze interval
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
                    -- clockFrame:Show() -- Show the clock widget
                    print("Reminder shown.")
                end
            end
        end)
    end
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

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)

-- Register a slash command to set the reminder interval in-game
SLASH_REMINDERINTERVAL1 = "/breaktime"
SlashCmdList["REMINDERINTERVAL"] = SlashCommandHandler