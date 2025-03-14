if getActivatedMods():contains('\\ReeferMadness') then
    Events.OnLoad.Add(function()
        local smokableObjects = {
            ['ReeferMadness.SmokingPipe_marijuana'] = {
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = false,                             -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.CanPipe_marijuana'] = {
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = 0.998,                           -- Decay rate when idle
                callback = false,                            -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.WeedCigarette'] = {
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.Joint'] = {
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.blunt'] = {
                visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.WeedCigarette2'] = {
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.SmokingPipe_hash'] = {
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = false,                             -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.CanPipe_hash'] = {
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = 0.998,                           -- Decay rate when idle
                callback = false,                            -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.WeedCigarette2Kief'] = {
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.bluntKief'] = {
                visualItem = 'Mask_Cigarillo',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.jointKief'] = {
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.SmokingPipe_marijuanaKief'] = {
                visualItem = 'Mask_Pipe',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                           -- Minimum burn rate target
                burnMax = 0.000300,                           -- Maximum burn rate target
                burnSpeed = 0.0025,                           -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                        -- Acceleration decay rate after burnMax
                decayRate = 0.998,                            -- Decay rate when idle
                callback = false,                             -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.CanPipe_marijuanaKief'] = {
                visualItem = false,                          -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                          -- Minimum burn rate target
                burnMax = 0.000300,                          -- Maximum burn rate target
                burnSpeed = 0.0025,                          -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                       -- Acceleration decay rate after burnMax
                decayRate = 0.998,                           -- Decay rate when idle
                callback = false,                            -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
                idleFactor = TrueSmoking.Options.IdleFactor,
                walkingFactor = TrueSmoking.Options.WalkingFactor,
                runningFactor = TrueSmoking.Options.RunningFactor,
                sprintingFactor = TrueSmoking.Options.SprintingFactor,
            },
            ['ReeferMadness.WeedCigaretteKief'] = {
                visualItem = 'Mask_Cigarette',                     -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                                -- Minimum burn rate target
                burnMax = 0.000300,                                -- Maximum burn rate target
                burnSpeed = 0.0025,                                -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                             -- Acceleration decay rate after burnMax
                decayRate = 0.998,                                 -- Decay rate when idle
                callback = false,                                  -- Callback function when smoked (mod support)
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
