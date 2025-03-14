if getActivatedMods():contains("\\B42Hemp&Tobacco") then
    Events.OnLoad.Add(function()
        local smokableObjects = {
            -- Hemp & Tobacco items
            ['Base.HempCigarette'] = {
                fullType = 'Base.HempCigarette',
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
            ['Base.HempCigar'] = {
                fullType = 'Base.HempCigar',
                visualItem = 'Mask_Cigar',                 -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigarLength, -- Length of smoke
                burnMin = 0.000125,                        -- Minimum burn rate target
                burnMax = 0.000300,                        -- Maximum burn rate target
                burnSpeed = 0.0025,                        -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                     -- Acceleration decay rate after burnMax
                decayRate = 0.998,                         -- Decay rate when idle
                callback = false,                          -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Base.HempCigarillo'] = {
                fullType = 'Base.HempCigarillo',
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
            ['Base.SmokingPipe_Hemp'] = {
                fullType = 'Base.SmokingPipe_Hemp',
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
            ['Base.CanPipe_Hemp'] = {
                fullType = 'Base.CanPipe_Hemp',
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
            ['Base.GlassSmokingPipe_Hemp'] = {
                fullType = 'Base.GlassSmokingPipe_Hemp',
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
            ['Base.GlassSmokingPipe_Tobacco'] = {
                fullType = 'Base.GlassSmokingPipe_Tobacco',
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
        }

        TrueSmoking:setSmokableObjects(smokableObjects)
    end)
end