local config = {}

local options = PZAPI.ModOptions:create("TrueSmoking", "True Smoking")

-- define your options here .....
options:addKeyBind("keySmoke", getText("IGUI_TRUESMOKING_KEY_SMOKE"), Keyboard.KEY_K, getText("IGUI_TRUESMOKING_KEY_SMOKE_DESC"))
options:addTickBox("FindSmoke", getText("IGUI_TRUESMOKING_FIND_SMOKE"), true, getText("IGUI_TRUESMOKING_FIND_SMOKE_DESC"))
options:addKeyBind("keyStopSmoke", getText("IGUI_TRUESMOKING_KEY_STOP_SMOKE"), Keyboard.KEY_SEMICOLON, getText("IGUI_TRUESMOKING_KEY_STOP_SMOKE_DESC"))
options:addTickBox("PassiveSmoking", getText("IGUI_TRUESMOKING_PASSIVE_SMOKING"), true, getText("IGUI_TRUESMOKING_PASSIVE_SMOKING_DESC"))
options:addSlider("PassiveMinTime", getText("IGUI_TRUESMOKING_PASSIVE_MIN_TIME"), 0, 60, 1, 30, getText("IGUI_TRUESMOKING_PASSIVE_MIN_TIME_DESC"))
options:addSlider("PassiveMaxTime", getText("IGUI_TRUESMOKING_PASSIVE_MAX_TIME"), 0, 120, 1, 80, getText("IGUI_TRUESMOKING_PASSIVE_MAX_TIME_DESC"))
options:addTickBox("KeepLit", getText("IGUI_TRUESMOKING_KEEP_LIT"), false, getText("IGUI_TRUESMOKING_KEEP_LIT_DESC"))
options:addTickBox("AutoPutOut", getText("IGUI_TRUESMOKING_AUTO_PUT_OUT"), true, getText("IGUI_TRUESMOKING_AUTO_PUT_OUT_DESC"))
options:addTickBox('WithdrawalText', getText('IGUI_TRUESMOKING_WITHDRAWAL_TEXT'), true, getText('IGUI_TRUESMOKING_WITHDRAWAL_TEXT_DESC'))
options:addTickBox("HidePuffActionBar", getText("IGUI_TRUESMOKING_HIDE_PUFF_ACTION_BAR"), false, getText("IGUI_TRUESMOKING_HIDE_PUFF_ACTION_BAR_DESC"))
options:addTickBox("HideAllActionBars", getText("IGUI_TRUESMOKING_HIDE_ALL_ACTION_BARS"), false, getText("IGUI_TRUESMOKING_HIDE_ALL_ACTION_BARS_DESC"))
options:addTickBox('HideMoodles', getText("IGUI_TRUESMOKING_HIDE_MOODLES"), false, getText("IGUI_TRUESMOKING_HIDE_MOODLES_DESC"))
options:addTickBox('ShowSmokePercent', getText("IGUI_TRUESMOKING_SHOW_SMOKE_PERCENT"), false, getText("IGUI_TRUESMOKING_SHOW_SMOKE_PERCENT_DESC"))
options:addTickBox('ShowDaysRemaining', getText("IGUI_TRUESMOKING_SHOW_DAYS_REMAINING"), false, getText("IGUI_TRUESMOKING_SHOW_DAYS_REMAINING_DESC"))
local hotkeySmokes = options:addMultipleTickBox('HotKeySmokes',getText('IGUI_TRUESMOKING_SMOKE_KEYS'))
    hotkeySmokes:addTickBox(getText('IGUI_TRUESMOKING_ROLLED_HK'),true)
    hotkeySmokes:addTickBox(getText('IGUI_TRUESMOKING_CIG_HK'),true)
    hotkeySmokes:addTickBox(getText('IGUI_TRUESMOKING_CIGARILLO_HK'),false)
    hotkeySmokes:addTickBox(getText('IGUI_TRUESMOKING_CIGAR_HK'),false)
    hotkeySmokes:addTickBox(getText('IGUI_TRUESMOKING_CAN_HK'),false)
    hotkeySmokes:addTickBox(getText('IGUI_TRUESMOKING_PIPE_HK'),false)
options:addTickBox("DebugMoodles", getText("IGUI_TRUESMOKING_DEBUG_MOODLES"), false, getText("IGUI_TRUESMOKING_DEBUG_MOODLES_DESC"))
-- options:addButton('TestButton', '100 nicotine', '100 nicotine', function()
--     local data = getPlayer():getModData().nicotineSystem
--     data.nicotineLevel = 100
-- end)
-- options:addButton('TestButton2', '100 addiction', '100 addiction', function()
--     local data = getPlayer():getModData().nicotineSystem
--     data.addictionLevel = 100
-- end)
-- options:addButton('TestButton3', '0 levels', '0 levels', function()
--     local data = getPlayer():getModData().nicotineSystem
--     data.nicotineLevel = 0
--     data.addictionLevel = 0
-- end)
options:addSeparator()

-- This is a helper function that will automatically populate the "config" table.
--- Retrieve each option as: config."ID"
options.apply = function(self)
    for k,v in pairs(self.dict) do
        if v.type == "multipletickbox" then
            for i=1, #v.values do
                config[(k.."_"..tostring(i))] = v:getValue(i)
            end
        elseif v.type == "button" then
            -- do nothing
        else
            config[k] = v:getValue()
        end
    end
end

Events.OnMainMenuEnter.Add(function()
    options:apply()
end)

-- We now return the `config` object, so it can be used as a module!
return config