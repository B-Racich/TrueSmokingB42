local config = {}

local options = PZAPI.ModOptions:create("TrueSmoking", "True Smoking")

-- define your options here .....
options:addKeyBind("keySmoke", getText("IGUI_TRUESMOKING_KEY_SMOKE"), Keyboard.KEY_K, getText("IGUI_TRUESMOKING_KEY_SMOKE_DESC"))
options:addTickBox("FindSmoke", getText("IGUI_TRUESMOKING_FIND_SMOKE"), true, getText("IGUI_TRUESMOKING_FIND_SMOKE_DESC"))
options:addKeyBind("keyStopSmoke", getText("IGUI_TRUESMOKING_KEY_STOP_SMOKE"), Keyboard.KEY_SEMICOLON, getText("IGUI_TRUESMOKING_KEY_STOP_SMOKE_DESC"))
options:addTickBox("PassiveSmoking", getText("IGUI_TRUESMOKING_PASSIVE_SMOKING"), true, getText("IGUI_TRUESMOKING_PASSIVE_SMOKING_DESC"))
options:addSlider("PassiveMinTime", getText("IGUI_TRUESMOKING_PASSIVE_MIN_TIME"), 0, 60, 1, 30, getText("IGUI_TRUESMOKING_PASSIVE_MIN_TIME_DESC"))
options:addSlider("PassiveMaxTime", getText("IGUI_TRUESMOKING_PASSIVE_MAX_TIME"), 0, 120, 1, 80, getText("IGUI_TRUESMOKING_PASSIVE_MAX_TIME_DESC"))
options:addTickBox("AutoPutOut", getText("IGUI_TRUESMOKING_AUTO_PUT_OUT"), true, getText("IGUI_TRUESMOKING_AUTO_PUT_OUT_DESC"))
options:addTickBox("HidePuffActionBar", getText("IGUI_TRUESMOKING_HIDE_PUFF_ACTION_BAR"), false, getText("IGUI_TRUESMOKING_HIDE_PUFF_ACTION_BAR_DESC"))
options:addTickBox("HideAllActionBars", getText("IGUI_TRUESMOKING_HIDE_ALL_ACTION_BARS"), false, getText("IGUI_TRUESMOKING_HIDE_ALL_ACTION_BARS_DESC"))
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