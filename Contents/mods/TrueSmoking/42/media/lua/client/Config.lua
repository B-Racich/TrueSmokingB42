Events.OnLoad.Add(function()
    local smokableObjects = {
        ['Base.CigaretteSingle'] = {
            fullType = 'Base.CigaretteSingle',
            visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
            burnMin = 0.000125,                                -- Minimum burn rate target
            burnMax = 0.000300,                                -- Maximum burn rate target
            burnSpeed = 0.0025,                                -- Acceleration towards burnMax
            burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
            decayRate = 0.998,                                 -- Decay rate when idle
            callback = false,                                  -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
        },
        ['Base.CigaretteRolled'] = {
            fullType = 'Base.CigaretteRolled',
            visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
            burnMin = 0.000125,                                -- Minimum burn rate target
            burnMax = 0.000300,                                -- Maximum burn rate target
            burnSpeed = 0.0025,                                -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
            decayRate = 0.998,                                 -- Decay rate when idle
            callback = false,                                  -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
        },
        ['Base.Cigarillo'] = {
            fullType = 'Base.Cigarillo',
            visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
            burnMin = 0.000125,                                -- Minimum burn rate target
            burnMax = 0.000300,                                -- Maximum burn rate target
            burnSpeed = 0.0025,                                -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
            decayRate = 0.998,                                 -- Decay rate when idle
            callback = false,                                  -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
        },
        ['Base.Cigar'] = {
            fullType = 'Base.Cigar',
            visualItem = 'Mask_Cigar',               -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.Cigar, -- Length of smoke
            burnMin = 0.000125,                      -- Minimum burn rate target
            burnMax = 0.000300,                      -- Maximum burn rate target
            burnSpeed = 0.0025,                      -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
            decayRate = 0.998,                       -- Decay rate when idle
            callback = false,                        -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
        },
        ['Base.SmokingPipe_Tobacco'] = {
            fullType = 'Base.SmokingPipe_Tobacco',
            visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
            burnMin = 0.000125,                           -- Minimum burn rate target
            burnMax = 0.000300,                           -- Maximum burn rate target
            burnSpeed = 0.0025,                           -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
            decayRate = 0.998,                            -- Decay rate when idle
            callback = false,                             -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
        },
        ['Base.CanPipe_Tobacco'] = {
            fullType = 'Base.CanPipe_Tobacco',
            visualItem = false,                          -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
            burnMin = 0.000125,                          -- Minimum burn rate target
            burnMax = 0.000300,                          -- Maximum burn rate target
            burnSpeed = 0.0025,                          -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
            decayRate = 0.998,                           -- Decay rate when idle
            callback = false,                            -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
        },
    }

    TrueSmoking:setSmokableObjects(smokableObjects)

    local TRUE_SMOKING_DEFAULT_HOTKEY_SMOKES = {
        'Base.CigaretteSingle',
    }

    local TRUE_SMOKING_DEFAULT_HOTKEY_PACKS = {
        ['Base.CigarettePack'] = 'TakeACigarette',
    }

    TrueSmoking:setHotkeySmokes(TRUE_SMOKING_DEFAULT_HOTKEY_SMOKES)
    TrueSmoking:setHotkeyPacks(TRUE_SMOKING_DEFAULT_HOTKEY_PACKS)

    -- TrueSmoking:setCallback(
    -- function(smokable)
    --     if smokable.item:getModData().modOnEat == 'OnEat_WeedSmoke' then
    --         print('call this')
    --         OnEat_WeedSmoke(smokable)
    --     end
    -- end
    --     )
end)


--[[
    Placeholder for when we need to do some item edits at some point
]]
--Kalilynx
local function appendSample()
    if not ScriptManager.instance then return end -- Ensure ScriptManager exists

    local item = ScriptManager.instance:getItem("Base.Item")
    if not item then return end

    local currentTags = item:getTags()
    local newTagsList = { "Tag1", "Tag2" }
    local tagsSet = {} -- use  set to avoid dup tags

    -- here we add existing tags to the set
    if currentTags and not currentTags:isEmpty() then
        for i = 0, currentTags:size() - 1 do
            tagsSet[currentTags:get(i)] = true
        end
    end
    -- add new tags
    for _, tag in ipairs(newTagsList) do
        tagsSet[tag] = true
    end
    -- convert the set back to a list and update it
    local mergedTags = {}
    for tag in pairs(tagsSet) do
        table.insert(mergedTags, tag)
    end
    item:DoParam("Tags = " .. table.concat(mergedTags, ";"))
end

-- Events.OnGameBoot.Add(appendSample)
