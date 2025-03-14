Events.OnCreatePlayer.Add(function()
    --[[
        The smokable object defines settings and properties for each smokable item that should be
            hooked into the TrueSmoking system.

        ===The following settings can be used to tweak how each item behaves when smoked:===

        visualItem: The item to display on the mouth while smoking. Custom wearable items can be made and should
            work if the fullType of the item is passed here. They need to be made in the same format as the ones
            from this mod so reference that.

            ['Mask_Cigarette', 'Mask_Cigarillo', 'Mask_Cigar', 'Mask_Pipe', false]

        burnMin: the minimum burn rate the smokable tries to reach when walking/running/sprinting

        burnMax: the maximum burn rate the smokable tries to reach when puffing

        burnSpeed: the acceleration towards burnMax when puffing

        burnSpeedDecay: the acceleration decay rate after reaching burnMax

        effectMultiplier: multiplier for smoking effects (stress, unhappyness, etc)

        callback: the callback function that happens onTick while smoking
            For modded onEat methods, this will pass in a reference of the Smokable object to use

            Functions that are designed for the vanilla system can be made to user the Smokable.puffPercent value to
            calculate how much of a change should happen

        conditions: Flags to set certain logic/settings per item
            idle = should go out when idle
            walking/running/sprinting/strafing = should increase burn while doing
            canDrop = if the smoke should be dropped when falling (trees,zombies,walls)

        idleFactor: the multiplier to decrease the burn rate when idle // 0.85

        walkingFactor: the multiplier to increase the burn rate to min when walking // 1.0

        runningFactor: the multiplier to increase the burn rate to min when running // 1.15

        sprintingFactor: the multiplier to increase the burn rate to min when sprinting // 1.35

        puffFactor: the multiplier to increase the burn rate to max when puffing // 1.35
    ]]
    local smokableObjects = {
        ['Base.CigaretteSingle'] = {
            visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
            burnMin = 0.000125,                                -- Minimum burn rate target
            burnMax = 0.000300,                                -- Maximum burn rate target
            burnSpeed = 0.0025,                                -- Acceleration towards burnMax
            burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
            decayRate = 0.998,                                 -- Decay rate when idle
            effectMultiplier = 1.0,                            -- smoker effect multiplier
            callback = OnEat_OverTime,                                  -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
        },
        ['Base.CigaretteRolled'] = {
            visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
            burnMin = 0.000125,                                -- Minimum burn rate target
            burnMax = 0.000300,                                -- Maximum burn rate target
            burnSpeed = 0.0025,                                -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
            decayRate = 0.998,                                 -- Decay rate when idle
            effectMultiplier = 1.0,                            -- smoker effect multiplier
            callback = OnEat_OverTime,                                  -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
        },
        ['Base.Cigarillo'] = {
            visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
            burnMin = 0.000125,                                -- Minimum burn rate target
            burnMax = 0.000300,                                -- Maximum burn rate target
            burnSpeed = 0.0025,                                -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
            decayRate = 0.998,                                 -- Decay rate when idle
            effectMultiplier = 2.0,                            -- smoker effect multiplier
            callback = OnEat_OverTime,                                  -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
        },
        ['Base.Cigar'] = {
            visualItem = 'Mask_Cigar',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CigarLength, -- Length of smoke
            burnMin = 0.000125,                            -- Minimum burn rate target
            burnMax = 0.000300,                            -- Maximum burn rate target
            burnSpeed = 0.0025,                            -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
            decayRate = 0.998,                             -- Decay rate when idle
            effectMultiplier = 3.0,                        -- smoker effect multiplier
            callback = OnEat_OverTime,                              -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
        },
        ['Base.SmokingPipe_Tobacco'] = {
            visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
            burnMin = 0.000125,                           -- Minimum burn rate target
            burnMax = 0.000300,                           -- Maximum burn rate target
            burnSpeed = 0.0025,                           -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
            decayRate = 0.998,                            -- Decay rate when idle
            callback = OnEat_OverTime,                             -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
        },
        ['Base.CanPipe_Tobacco'] = {
            visualItem = false,                          -- Visual item to be displayed on mouth
            smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
            burnMin = 0.000125,                          -- Minimum burn rate target
            burnMax = 0.000300,                          -- Maximum burn rate target
            burnSpeed = 0.0025,                          -- Acceleration towards burnMax
            burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
            decayRate = 0.998,                           -- Decay rate when idle
            callback = OnEat_OverTime,                            -- Callback function when smoked (mod support)
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
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
