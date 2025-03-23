Events.OnCreatePlayer.Add(function()
    --[[
        The smokable object defines settings and properties for each smokable item that should be
            hooked into the TrueSmoking system.
        ===The following settings can be used to tweak how each item behaves when smoked:===

        [visualItem]: The item to display on the mouth while smoking. Custom wearable items can be made and should
            work if the fullType of the item is passed here. They need to be made in the same format as the ones
            from this mod so reference that.
            ['Mask_Cigarette', 'Mask_Cigarillo', 'Mask_Cigar', 'Mask_Pipe', false]

        [burnMin]: the minimum burn rate the smokable tries to reach when walking/running/sprinting
        [burnMax]: the maximum burn rate the smokable tries to reach when puffin
        [burnSpeed]: the acceleration towards burnMax when puffing
        [burnSpeedDecay]: the acceleration decay rate after reaching burnMax
        [effectMultiplier]: multiplier for smoking effects (stress, unhappyness, etc)
        [callback]: the callback function that happens onTick while smoking
            For modded onEat methods, this will pass in a reference of the Smokable object to use
            Functions that are designed for the vanilla system can be made to user the Smokable.puffPercent value to
            calculate how much of a change should happen

        [conditions]: Flags to set certain logic/settings per item
            idle = should go out when idle
            walking/running/sprinting/strafing = should increase burn while doing
            canDrop = if the smoke should be dropped when falling (trees,zombies,walls)
            
        [idleFactor]: the multiplier to decrease the burn rate when idle
        [walkingFactor]: the multiplier to increase the burn rate to min when walking
        [runningFactor]: the multiplier to increase the burn rate to min when running
        [sprintingFactor]: the multiplier to increase the burn rate to min when sprinting
        [puffFactor]: the multiplier to increase the burn rate to max when puffing
    ]]
    local smokableObjects = {
        ['Base.CigaretteSingle'] = {
            visualItem = 'Mask_Cigarette',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.CigaretteLength,
            burnMin = TrueSmoking.Options.CigaretteBurnMin,
            burnMax = TrueSmoking.Options.CigaretteBurnMax,
            burnSpeed = TrueSmoking.Options.CigaretteBurnSpeed,
            burnSpeedDecay = TrueSmoking.Options.CigaretteBurnSpeedDecay,
            decayRate = TrueSmoking.Options.CigaretteDecayRate,
            effectMultiplier = TrueSmoking.Options.CigaretteEffectMultiplier,
            walkingFactor = TrueSmoking.Options.CigaretteWalkingFactor,
            runningFactor = TrueSmoking.Options.CigaretteRunningFactor,
            sprintingFactor = TrueSmoking.Options.CigaretteSprintingFactor,
            puffFactor = TrueSmoking.Options.CigarettePuffFactor
        },
        ['Base.CigaretteRolled'] = {
            visualItem = 'Mask_Cigarette',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.RolledCigaretteLength,
            burnMin = TrueSmoking.Options.RolledCigaretteBurnMin,
            burnMax = TrueSmoking.Options.RolledCigaretteBurnMax,
            burnSpeed = TrueSmoking.Options.RolledCigaretteBurnSpeed,
            burnSpeedDecay = TrueSmoking.Options.RolledCigaretteBurnSpeedDecay,
            decayRate = TrueSmoking.Options.RolledCigaretteDecayRate,
            effectMultiplier = TrueSmoking.Options.RolledCigaretteEffectMultiplier,
            walkingFactor = TrueSmoking.Options.RolledCigaretteWalkingFactor,
            runningFactor = TrueSmoking.Options.RolledCigaretteRunningFactor,
            sprintingFactor = TrueSmoking.Options.RolledCigaretteSprintingFactor,
            puffFactor = TrueSmoking.Options.RolledCigarettePuffFactor
        },
        ['Base.Cigarillo'] = {
            visualItem = 'Mask_Cigarillo',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.CigarilloLength,
            burnMin = TrueSmoking.Options.CigarilloBurnMin,
            burnMax = TrueSmoking.Options.CigarilloBurnMax,
            burnSpeed = TrueSmoking.Options.CigarilloBurnSpeed,
            burnSpeedDecay = TrueSmoking.Options.CigarilloBurnSpeedDecay,
            decayRate = TrueSmoking.Options.CigarilloDecayRate,
            effectMultiplier = TrueSmoking.Options.CigarilloEffectMultiplier,
            walkingFactor = TrueSmoking.Options.CigarilloWalkingFactor,
            runningFactor = TrueSmoking.Options.CigarilloRunningFactor,
            sprintingFactor = TrueSmoking.Options.CigarilloSprintingFactor,
            puffFactor = TrueSmoking.Options.CigarilloPuffFactor
        },
        ['Base.Cigar'] = {
            visualItem = 'Mask_Cigar',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.CigarLength,
            burnMin = TrueSmoking.Options.CigarBurnMin,
            burnMax = TrueSmoking.Options.CigarBurnMax,
            burnSpeed = TrueSmoking.Options.CigarBurnSpeed,
            burnSpeedDecay = TrueSmoking.Options.CigarBurnSpeedDecay,
            decayRate = TrueSmoking.Options.CigarDecayRate,
            effectMultiplier = TrueSmoking.Options.CigarEffectMultiplier,
            walkingFactor = TrueSmoking.Options.CigarWalkingFactor,
            runningFactor = TrueSmoking.Options.CigarRunningFactor,
            sprintingFactor = TrueSmoking.Options.CigarSprintingFactor,
            puffFactor = TrueSmoking.Options.CigarPuffFactor
        },
        ['Base.SmokingPipe_Tobacco'] = {
            visualItem = 'Mask_Pipe',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.PipeLength,
            burnMin = TrueSmoking.Options.PipeBurnMin,
            burnMax = TrueSmoking.Options.PipeBurnMax,
            burnSpeed = TrueSmoking.Options.PipeBurnSpeed,
            burnSpeedDecay = TrueSmoking.Options.PipeBurnSpeedDecay,
            decayRate = TrueSmoking.Options.PipeDecayRate,
            effectMultiplier = TrueSmoking.Options.PipeEffectMultiplier,
            walkingFactor = TrueSmoking.Options.PipeWalkingFactor,
            runningFactor = TrueSmoking.Options.PipeRunningFactor,
            sprintingFactor = TrueSmoking.Options.PipeSprintingFactor,
            puffFactor = TrueSmoking.Options.PipePuffFactor
        },
        ['Base.CanPipe_Tobacco'] = {
            visualItem = false,
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.CanLength,
            burnMin = TrueSmoking.Options.CanBurnMin,
            burnMax = TrueSmoking.Options.CanBurnMax,
            burnSpeed = TrueSmoking.Options.CanBurnSpeed,
            burnSpeedDecay = TrueSmoking.Options.CanBurnSpeedDecay,
            decayRate = TrueSmoking.Options.CanDecayRate,
            effectMultiplier = TrueSmoking.Options.CanEffectMultiplier,
            walkingFactor = TrueSmoking.Options.CanWalkingFactor,
            runningFactor = TrueSmoking.Options.CanRunningFactor,
            sprintingFactor = TrueSmoking.Options.CanSprintingFactor,
            puffFactor = TrueSmoking.Options.CanPuffFactor
        }
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
