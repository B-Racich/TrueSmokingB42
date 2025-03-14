if getActivatedMods():contains('\\N&CsNarcotics') then
    Events.OnLoad.Add(function()
        -- Faster decay rate for bongs and pipes
        local bongDecay = 0.99
        local pipeDecay = 0.99

        local smokableObjects = {
            -- Nnc (N&C) items - AK strain
            ['Nnc.BluntAK'] = {
                fullType = 'Nnc.BluntAK',
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
            ['Nnc.JointAK'] = {
                fullType = 'Nnc.JointAK',
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
            ['Nnc.Bong1GreenAK'] = {
                fullType = 'Nnc.Bong1GreenAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1PurpleAK'] = {
                fullType = 'Nnc.Bong1PurpleAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1RedAK'] = {
                fullType = 'Nnc.Bong1RedAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2PinkAK'] = {
                fullType = 'Nnc.Bong2PinkAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RainbowAK'] = {
                fullType = 'Nnc.Bong2RainbowAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RedAK'] = {
                fullType = 'Nnc.Bong2RedAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.BongPokeAK'] = {
                fullType = 'Nnc.BongPokeAK',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1GreenAK'] = {
                fullType = 'Nnc.Pipe1GreenAK',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1OrangeAK'] = {
                fullType = 'Nnc.Pipe1OrangeAK',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1YellowAK'] = {
                fullType = 'Nnc.Pipe1YellowAK',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.CanPipeAK'] = {
                fullType = 'Nnc.CanPipeAK',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                   -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.SmokingPipeAK'] = {
                fullType = 'Nnc.SmokingPipeAK',
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

            -- Nnc (N&C) items - Northern Lights strain
            ['Nnc.BluntNorthernLights'] = {
                fullType = 'Nnc.BluntNorthernLights',
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
            ['Nnc.JointNorthernLights'] = {
                fullType = 'Nnc.JointNorthernLights',
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
            ['Nnc.Bong1GreenNL'] = {
                fullType = 'Nnc.Bong1GreenNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1PurpleNL'] = {
                fullType = 'Nnc.Bong1PurpleNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1RedNL'] = {
                fullType = 'Nnc.Bong1RedNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2PinkNL'] = {
                fullType = 'Nnc.Bong2PinkNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RainbowNL'] = {
                fullType = 'Nnc.Bong2RainbowNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RedNL'] = {
                fullType = 'Nnc.Bong2RedNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.BongPokeNL'] = {
                fullType = 'Nnc.BongPokeNL',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1GreenNL'] = {
                fullType = 'Nnc.Pipe1GreenNL',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1OrangeNL'] = {
                fullType = 'Nnc.Pipe1OrangeNL',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1YellowNL'] = {
                fullType = 'Nnc.Pipe1YellowNL',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.CanPipeNorthernLights'] = {
                fullType = 'Nnc.CanPipeNorthernLights',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                   -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.SmokingPipeNorthernLights'] = {
                fullType = 'Nnc.SmokingPipeNorthernLights',
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

            -- Nnc (N&C) items - Sour Diesel strain
            ['Nnc.BluntSourDiesel'] = {
                fullType = 'Nnc.BluntSourDiesel',
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
            ['Nnc.JointSourDiesel'] = {
                fullType = 'Nnc.JointSourDiesel',
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
            ['Nnc.Bong1GreenSD'] = {
                fullType = 'Nnc.Bong1GreenSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1PurpleSD'] = {
                fullType = 'Nnc.Bong1PurpleSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1RedSD'] = {
                fullType = 'Nnc.Bong1RedSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2PinkSD'] = {
                fullType = 'Nnc.Bong2PinkSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RainbowSD'] = {
                fullType = 'Nnc.Bong2RainbowSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RedSD'] = {
                fullType = 'Nnc.Bong2RedSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.BongPokeSD'] = {
                fullType = 'Nnc.BongPokeSD',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1GreenSD'] = {
                fullType = 'Nnc.Pipe1GreenSD',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1OrangeSD'] = {
                fullType = 'Nnc.Pipe1OrangeSD',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1YellowSD'] = {
                fullType = 'Nnc.Pipe1YellowSD',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.CanPipeSourDiesel'] = {
                fullType = 'Nnc.CanPipeSourDiesel',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                   -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.SmokingPipeSourDiesel'] = {
                fullType = 'Nnc.SmokingPipeSourDiesel',
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

            -- Nnc (N&C) items - Kief variant
            ['Nnc.BluntKief'] = {
                fullType = 'Nnc.BluntKief',
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
            ['Nnc.JointKief'] = {
                fullType = 'Nnc.JointKief',
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
            ['Nnc.Bong1GreenKief'] = {
                fullType = 'Nnc.Bong1GreenKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1PurpleKief'] = {
                fullType = 'Nnc.Bong1PurpleKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong1RedKief'] = {
                fullType = 'Nnc.Bong1RedKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2PinkKief'] = {
                fullType = 'Nnc.Bong2PinkKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RainbowKief'] = {
                fullType = 'Nnc.Bong2RainbowKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Bong2RedKief'] = {
                fullType = 'Nnc.Bong2RedKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.BongPokeKief'] = {
                fullType = 'Nnc.BongPokeKief',
                visualItem = 'Mask_Bong',                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CigaretteLength, -- Length of smoke
                burnMin = 0.000125,                            -- Minimum burn rate target
                burnMax = 0.000300,                            -- Maximum burn rate target
                burnSpeed = 0.0025,                            -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                         -- Acceleration decay rate after burnMax
                decayRate = bongDecay,                         -- Decay rate when idle
                callback = false,                              -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1GreenKief'] = {
                fullType = 'Nnc.Pipe1GreenKief',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1OrangeKief'] = {
                fullType = 'Nnc.Pipe1OrangeKief',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.Pipe1YellowKief'] = {
                fullType = 'Nnc.Pipe1YellowKief',
                visualItem = false,                       -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.PipeLength, -- Length of smoke
                burnMin = 0.000125,                       -- Minimum burn rate target
                burnMax = 0.000300,                       -- Maximum burn rate target
                burnSpeed = 0.0025,                       -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                    -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                    -- Decay rate when idle
                callback = false,                         -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.CanPipeKief'] = {
                fullType = 'Nnc.CanPipeKief',
                visualItem = false,                      -- Visual item to be displayed on mouth
                smokeLength = TrueSmoking.Options.CanLength, -- Length of smoke
                burnMin = 0.000125,                      -- Minimum burn rate target
                burnMax = 0.000300,                      -- Maximum burn rate target
                burnSpeed = 0.0025,                      -- Acceleration towards burnMax
                burnSpeedDecay = 0.20,                   -- Acceleration decay rate after burnMax
                decayRate = pipeDecay,                   -- Decay rate when idle
                callback = false,                        -- Callback function when smoked (mod support)
                conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true }
            },
            ['Nnc.SmokingPipeKief'] = {
                fullType = 'Nnc.SmokingPipeKief',
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