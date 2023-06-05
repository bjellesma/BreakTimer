local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable("BreakTimer", {
    type = "group",
    name = "BreakTimer Options",
    args = {
        option2 = {
            type = "range",
            name = "Reminder Interval (minutes)",
            desc = "Set the reminder interval",
            min = 1,
            max = 120,
            step = 1,
            get = function()
                return playerInterval / 60 -- divide by 60 to show minutes
            end,
            set = function(_, value)
                value = value * 60 -- multiply to get seconds
                SetReminderInterval(value)
            end,
        },
        option3 = {
            type = "input", -- Use "input" type for text box
            name = "Reminder Text",
            desc = "Enter a custom message",
            get = function()
                return dialogText
            end,
            set = function(_, value)
                dialogText = value
                BREAKTIMER_AllSavedVars["dialogText"] = dialogText
            end,
        },
        option4 = {
            type = "input", -- Use "input" type for text box
            name = "Accept Text",
            desc = "Enter a custom message",
            get = function()
                return acceptText
            end,
            set = function(_, value)
                acceptText = value
                BREAKTIMER_AllSavedVars["acceptText"] = acceptText
            end,
        },
        option5 = {
            type = "input", -- Use "input" type for text box
            name = "Cancel Text",
            desc = "Enter a custom message",
            get = function()
                return cancelText
            end,
            set = function(_, value)
                cancelText = value
                BREAKTIMER_AllSavedVars["cancelText"] = cancelText
            end,
        },
    },
})