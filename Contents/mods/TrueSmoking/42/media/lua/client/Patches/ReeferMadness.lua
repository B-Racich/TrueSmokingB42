if getActivatedMods():contains('\\ReeferMadness') then
    Events.OnLoad.Add(function()
        local smokableObjects = {
            ['ReeferMadness.SmokingPipe_marijuana'] = {
                fullType = 'ReeferMadness.SmokingPipe_marijuana',
                visualItem = 'Mask_Pipe',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = 0.998,                        -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.CanPipe_marijuana'] = {
                fullType = 'ReeferMadness.CanPipe_marijuana',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = 0.998,                       -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.WeedCigarette'] = {
                fullType = 'ReeferMadness.WeedCigarette',
                visualItem = 'Mask_Cigarette',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.Joint'] = {
                fullType = 'ReeferMadness.Joint',
                visualItem = 'Mask_Cigarette',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.blunt'] = {
                fullType = 'ReeferMadness.blunt',
                visualItem = 'Mask_Cigarillo',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.WeedCigarette2'] = {
                fullType = 'ReeferMadness.WeedCigarette2',
                visualItem = 'Mask_Cigarette',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.SmokingPipe_hash'] = {
                fullType = 'ReeferMadness.SmokingPipe_hash',
                visualItem = 'Mask_Pipe',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = 0.998,                        -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.CanPipe_hash'] = {
                fullType = 'ReeferMadness.CanPipe_hash',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = 0.998,                       -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.WeedCigarette2Kief'] = {
                fullType = 'ReeferMadness.WeedCigarette2Kief',
                visualItem = 'Mask_Cigarette',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.bluntKief'] = {
                fullType = 'ReeferMadness.bluntKief',
                visualItem = 'Mask_Cigarillo',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarilloLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.jointKief'] = {
                fullType = 'ReeferMadness.jointKief',
                visualItem = 'Mask_Cigarette',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.SmokingPipe_marijuanaKief'] = {
                fullType = 'ReeferMadness.SmokingPipe_marijuanaKief',
                visualItem = 'Mask_Pipe',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = 0.998,                        -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.CanPipe_marijuanaKief'] = {
                fullType = 'ReeferMadness.CanPipe_marijuanaKief',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = 0.998,                       -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['ReeferMadness.WeedCigaretteKief'] = {
                fullType = 'ReeferMadness.WeedCigaretteKief',
                visualItem = 'Mask_Cigarette',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.25,                         -- Acceleration decay rate after burnMax
                decayRate = 0.998,                             -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
        }

        TrueSmoking:setSmokableObjects(smokableObjects)
    end)
end