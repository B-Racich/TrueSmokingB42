local config = {}

--- "UNIQUEID" should be replaced with your own unique ID. Possibly best to just use your mod's ID
local options = PZAPI.ModOptions:create("TrueSmoking", "True Smoking")

-- define your options here .....
options:addKeyBind("keySmoke", "Puff/Relight/Find Smoke", Keyboard.KEY_K, "Take a puff or relight a cigarette, find a cigarette if not smoking")
options:addTickBox("FindSmoke", "Unpack/Light Smoke", true, "Enables/Disables the find/light smoke feature")
options:addKeyBind("keyStopSmoke", "Stop Smoking", Keyboard.KEY_SEMICOLON, "Stop smoking")
options:addTickBox("PassiveSmoking", "Passive Puffing", true, "Enable automatic passive puffing")
options:addSlider("PassiveMinTime",  getText("Passive Puffing Min Time"), 0, 60, 1, 30, getText("UI_options_UNIQUEID_slider_tooltip"))
options:addSlider("PassiveMaxTime",  getText("Passive Puffing Max Time"), 0, 120, 1, 80, getText("UI_options_UNIQUEID_slider_tooltip"))
options:addTickBox("AutoPutOut", "Automatically Put Out Smoke", true, "Will automatically try to put out the smoke when its finished")
options:addTickBox("HidePuffActionBar", "Hide the puffing action bar", false, "Hide the puffing action bar")
options:addTickBox("HideAllActionBars", "Hides all actions bars for smoking", false, "Hides all actions bars for smoking")
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