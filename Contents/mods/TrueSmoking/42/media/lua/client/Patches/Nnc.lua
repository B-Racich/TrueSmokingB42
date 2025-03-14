if getActivatedMods():contains('\\N&CsNarcotics') then
    function OnEat_WeedSmoke_OverTime(smokable)
        --Use the smokable player ref to ensure we are affecting the right local player (splitscreen)
        local player = smokable.player
        local WeedEffect = 19 --Max weed effect we can accumulate
        local PotHead = player:HasTrait("PotHead") and 216 or 100
        --This is how much of the smoke (%) is consumed per tick, scale our changes by this
        local percent = smokable.puffPercent
        if player:getModData().NnCTenMinutesPotHead == nil then
            player:getModData().NnCTenMinutesPotHead = 0
        end
        if player:getModData().NnCWeeeeedEffect == nil then
            player:getModData().NnCWeeeeedEffect = 0
        end
        if player:getModData().NnCWeeeeedEffect < WeedEffect and player:getModData().NnCWeeeeedEffect >= 0 then
            print('weedEfffect: ' .. player:getModData().NnCWeeeeedEffect)
            player:getModData().NnCWeeeeedEffect = player:getModData().NnCWeeeeedEffect + WeedEffect * percent;
        end
        player:getModData().NnCTenMinutesPotHead = player:getModData().NnCTenMinutesPotHead - (PotHead * percent)
    end

    function WeedSmoke_Callback(smokable)
        if smokable.item:getModData().modOnEat == 'OnEat_WeedSmoke' then
            OnEat_WeedSmoke_OverTime(smokable)
        end
    end

    Events.OnLoad.Add(function()
        -- Faster decay rate for bongs and pipes
        local bongDecay = 0.99
        local pipeDecay = 0.99

        local smokableObjects = {
            -- Nnc (N&C) items - AK strain
            ['Nnc.BluntAK'] = {
                fullType = 'Nnc.BluntAK',
                visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.JointAK'] = {
                fullType = 'Nnc.JointAK',
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1GreenAK'] = {
                fullType = 'Nnc.Bong1GreenAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1PurpleAK'] = {
                fullType = 'Nnc.Bong1PurpleAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1RedAK'] = {
                fullType = 'Nnc.Bong1RedAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2PinkAK'] = {
                fullType = 'Nnc.Bong2PinkAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RainbowAK'] = {
                fullType = 'Nnc.Bong2RainbowAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RedAK'] = {
                fullType = 'Nnc.Bong2RedAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.BongPokeAK'] = {
                fullType = 'Nnc.BongPokeAK',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1GreenAK'] = {
                fullType = 'Nnc.Pipe1GreenAK',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1OrangeAK'] = {
                fullType = 'Nnc.Pipe1OrangeAK',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1YellowAK'] = {
                fullType = 'Nnc.Pipe1YellowAK',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.CanPipeAK'] = {
                fullType = 'Nnc.CanPipeAK',
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                       -- Decay rate when idle
                callback = WeedSmoke_Callback,               -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.SmokingPipeAK'] = {
                fullType = 'Nnc.SmokingPipeAK',
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },

            -- Nnc (N&C) items - Northern Lights strain
            ['Nnc.BluntNorthernLights'] = {
                fullType = 'Nnc.BluntNorthernLights',
                visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.JointNorthernLights'] = {
                fullType = 'Nnc.JointNorthernLights',
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1GreenNL'] = {
                fullType = 'Nnc.Bong1GreenNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1PurpleNL'] = {
                fullType = 'Nnc.Bong1PurpleNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1RedNL'] = {
                fullType = 'Nnc.Bong1RedNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2PinkNL'] = {
                fullType = 'Nnc.Bong2PinkNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RainbowNL'] = {
                fullType = 'Nnc.Bong2RainbowNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RedNL'] = {
                fullType = 'Nnc.Bong2RedNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.BongPokeNL'] = {
                fullType = 'Nnc.BongPokeNL',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1GreenNL'] = {
                fullType = 'Nnc.Pipe1GreenNL',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1OrangeNL'] = {
                fullType = 'Nnc.Pipe1OrangeNL',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1YellowNL'] = {
                fullType = 'Nnc.Pipe1YellowNL',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.CanPipeNorthernLights'] = {
                fullType = 'Nnc.CanPipeNorthernLights',
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                       -- Decay rate when idle
                callback = WeedSmoke_Callback,               -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.SmokingPipeNorthernLights'] = {
                fullType = 'Nnc.SmokingPipeNorthernLights',
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },

            -- Nnc (N&C) items - Sour Diesel strain
            ['Nnc.BluntSourDiesel'] = {
                fullType = 'Nnc.BluntSourDiesel',
                visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.JointSourDiesel'] = {
                fullType = 'Nnc.JointSourDiesel',
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1GreenSD'] = {
                fullType = 'Nnc.Bong1GreenSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1PurpleSD'] = {
                fullType = 'Nnc.Bong1PurpleSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1RedSD'] = {
                fullType = 'Nnc.Bong1RedSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2PinkSD'] = {
                fullType = 'Nnc.Bong2PinkSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RainbowSD'] = {
                fullType = 'Nnc.Bong2RainbowSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RedSD'] = {
                fullType = 'Nnc.Bong2RedSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.BongPokeSD'] = {
                fullType = 'Nnc.BongPokeSD',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1GreenSD'] = {
                fullType = 'Nnc.Pipe1GreenSD',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1OrangeSD'] = {
                fullType = 'Nnc.Pipe1OrangeSD',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1YellowSD'] = {
                fullType = 'Nnc.Pipe1YellowSD',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.CanPipeSourDiesel'] = {
                fullType = 'Nnc.CanPipeSourDiesel',
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                       -- Decay rate when idle
                callback = WeedSmoke_Callback,               -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.SmokingPipeSourDiesel'] = {
                fullType = 'Nnc.SmokingPipeSourDiesel',
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },

            -- Nnc (N&C) items - Kief variant
            ['Nnc.BluntKief'] = {
                fullType = 'Nnc.BluntKief',
                visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.JointKief'] = {
                fullType = 'Nnc.JointKief',
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1GreenKief'] = {
                fullType = 'Nnc.Bong1GreenKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1PurpleKief'] = {
                fullType = 'Nnc.Bong1PurpleKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong1RedKief'] = {
                fullType = 'Nnc.Bong1RedKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2PinkKief'] = {
                fullType = 'Nnc.Bong2PinkKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RainbowKief'] = {
                fullType = 'Nnc.Bong2RainbowKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Bong2RedKief'] = {
                fullType = 'Nnc.Bong2RedKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.BongPokeKief'] = {
                fullType = 'Nnc.BongPokeKief',
                visualItem = 'Mask_Bong',                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                             -- Decay rate when idle
                callback = WeedSmoke_Callback,                     -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1GreenKief'] = {
                fullType = 'Nnc.Pipe1GreenKief',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1OrangeKief'] = {
                fullType = 'Nnc.Pipe1OrangeKief',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.Pipe1YellowKief'] = {
                fullType = 'Nnc.Pipe1YellowKief',
                visualItem = false,                           -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                        -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.CanPipeKief'] = {
                fullType = 'Nnc.CanPipeKief',
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                       -- Decay rate when idle
                callback = WeedSmoke_Callback,               -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['Nnc.SmokingPipeKief'] = {
                fullType = 'Nnc.SmokingPipeKief',
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = WeedSmoke_Callback,                -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
        }

        TrueSmoking:setSmokableObjects(smokableObjects)
    end)
end
