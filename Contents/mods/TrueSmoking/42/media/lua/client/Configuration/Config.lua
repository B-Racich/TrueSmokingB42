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
            smokeLength = TrueSmoking.Options.Cigarette.length,
            burnMin = TrueSmoking.Options.Cigarette.burnMin,
            burnMax = TrueSmoking.Options.Cigarette.burnMax,
            burnSpeed = TrueSmoking.Options.Cigarette.burnSpeed,
            burnSpeedDecay = TrueSmoking.Options.Cigarette.burnSpeedDecay,
            decayRate = TrueSmoking.Options.Cigarette.decayRate,
            effectMultiplier = TrueSmoking.Options.Cigarette.effectMultiplier,
            walkingFactor = TrueSmoking.Options.Cigarette.walkingFactor,
            runningFactor = TrueSmoking.Options.Cigarette.runningFactor,
            sprintingFactor = TrueSmoking.Options.Cigarette.sprintingFactor,
            puffFactor = TrueSmoking.Options.Cigarette.puffFactor,
            nicotineContent = 25,
        },
        ['Base.CigaretteRolled'] = {
            visualItem = 'Mask_Cigarette',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.RolledCigarette.length,
            burnMin = TrueSmoking.Options.RolledCigarette.burnMin,
            burnMax = TrueSmoking.Options.RolledCigarette.burnMax,
            burnSpeed = TrueSmoking.Options.RolledCigarette.burnSpeed,
            burnSpeedDecay = TrueSmoking.Options.RolledCigarette.burnSpeedDecay,
            decayRate = TrueSmoking.Options.RolledCigarette.decayRate,
            effectMultiplier = TrueSmoking.Options.RolledCigarette.effectMultiplier,
            walkingFactor = TrueSmoking.Options.RolledCigarette.walkingFactor,
            runningFactor = TrueSmoking.Options.RolledCigarette.runningFactor,
            sprintingFactor = TrueSmoking.Options.RolledCigarette.sprintingFactor,
            puffFactor = TrueSmoking.Options.RolledCigarette.puffFactor,
            nicotineContent = 30,
        },
        ['Base.Cigarillo'] = {
            visualItem = 'Mask_Cigarillo',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.Cigarillo.length,
            burnMin = TrueSmoking.Options.Cigarillo.burnMin,
            burnMax = TrueSmoking.Options.Cigarillo.burnMax,
            burnSpeed = TrueSmoking.Options.Cigarillo.burnSpeed,
            burnSpeedDecay = TrueSmoking.Options.Cigarillo.burnSpeedDecay,
            decayRate = TrueSmoking.Options.Cigarillo.decayRate,
            effectMultiplier = TrueSmoking.Options.Cigarillo.effectMultiplier,
            walkingFactor = TrueSmoking.Options.Cigarillo.walkingFactor,
            runningFactor = TrueSmoking.Options.Cigarillo.runningFactor,
            sprintingFactor = TrueSmoking.Options.Cigarillo.sprintingFactor,
            puffFactor = TrueSmoking.Options.Cigarillo.puffFactor,
            nicotineContent = 45,
        },
        ['Base.Cigar'] = {
            visualItem = 'Mask_Cigar',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.Cigar.length,
            burnMin = TrueSmoking.Options.Cigar.burnMin,
            burnMax = TrueSmoking.Options.Cigar.burnMax,
            burnSpeed = TrueSmoking.Options.Cigar.burnSpeed,
            burnSpeedDecay = TrueSmoking.Options.Cigar.burnSpeedDecay,
            decayRate = TrueSmoking.Options.Cigar.decayRate,
            effectMultiplier = TrueSmoking.Options.Cigar.effectMultiplier,
            walkingFactor = TrueSmoking.Options.Cigar.walkingFactor,
            runningFactor = TrueSmoking.Options.Cigar.runningFactor,
            sprintingFactor = TrueSmoking.Options.Cigar.sprintingFactor,
            puffFactor = TrueSmoking.Options.Cigar.puffFactor,
            nicotineContent = 75,
        },
        ['Base.SmokingPipe_Tobacco'] = {
            visualItem = 'Mask_Pipe',
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.Pipe.length,
            burnMin = TrueSmoking.Options.Pipe.burnMin,
            burnMax = TrueSmoking.Options.Pipe.burnMax,
            burnSpeed = TrueSmoking.Options.Pipe.burnSpeed,
            burnSpeedDecay = TrueSmoking.Options.Pipe.burnSpeedDecay,
            decayRate = TrueSmoking.Options.Pipe.decayRate,
            effectMultiplier = TrueSmoking.Options.Pipe.effectMultiplier,
            walkingFactor = TrueSmoking.Options.Pipe.walkingFactor,
            runningFactor = TrueSmoking.Options.Pipe.runningFactor,
            sprintingFactor = TrueSmoking.Options.Pipe.sprintingFactor,
            puffFactor = TrueSmoking.Options.Pipe.puffFactor,
            nicotineContent = 65,
        },
        ['Base.CanPipe_Tobacco'] = {
            visualItem = false,
            callback = OnEat_Tobacco,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            smokeLength = TrueSmoking.Options.Can.length,
            burnMin = TrueSmoking.Options.Can.burnMin,
            burnMax = TrueSmoking.Options.Can.burnMax,
            burnSpeed = TrueSmoking.Options.Can.burnSpeed,
            burnSpeedDecay = TrueSmoking.Options.Can.burnSpeedDecay,
            decayRate = TrueSmoking.Options.Can.decayRate,
            effectMultiplier = TrueSmoking.Options.Can.effectMultiplier,
            walkingFactor = TrueSmoking.Options.Can.walkingFactor,
            runningFactor = TrueSmoking.Options.Can.runningFactor,
            sprintingFactor = TrueSmoking.Options.Can.sprintingFactor,
            puffFactor = TrueSmoking.Options.Can.puffFactor,
            nicotineContent = 40,
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
