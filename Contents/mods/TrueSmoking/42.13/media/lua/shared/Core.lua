--[[
    Core.lua - TrueSmoking Foundation Module
    
    Establishes the base namespace and provides core utilities used across
    all client, server, and shared code. This file must be loaded first.
    
    Architecture:
    - TrueSmoking (namespace)
      - .Data     (ModData access - see Data.lua)
      - .Visuals  (mask/visual items - see Visuals.lua)
      - .Recipes  (pack recipes - see Recipes.lua)
      - .Stats    (stat buffering - client only)
      - .Nicotine (nicotine calculations - server only)
]]

TrueSmoking = TrueSmoking or {}

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

TrueSmoking.DEBUG = false  -- Set true to enable debug logging

TrueSmoking.Options = TrueSmoking.Options or {}
TrueSmoking.SmokableObjects = TrueSmoking.SmokableObjects or {}
TrueSmoking.Callbacks = TrueSmoking.Callbacks or {}

--------------------------------------------------------------------------------
-- Sandbox Options Loading
--------------------------------------------------------------------------------

--- Load sandbox options from SandboxVars (works in SP, MP client, and MP server)
function TrueSmoking.loadSandboxOptions()
    if not SandboxVars or not SandboxVars.TrueSmoking then return end
    
    local sandbox = SandboxVars.TrueSmoking
    local opt = TrueSmoking.Options

    -- Core options
    opt.ManageHeadGear = sandbox.ManageHeadGear
    opt.SmokeRelighting = sandbox.SmokeRelighting
    opt.UseNewMoodle = sandbox.UseNewMoodle

    -- Dropping options
    opt.Dropping = sandbox.Dropping or true
    opt.DroppingChanceSmoker = (sandbox.DropChanceSmoker or 6) / 100
    opt.DroppingChanceNonSmoker = (sandbox.DropChanceNonSmoker or 35) / 100

    -- Coughing options
    opt.Coughing = sandbox.Coughing
    opt.CoughingChanceSmoker = (sandbox.CoughingChanceSmoker or 4) / 100
    opt.CoughingChanceNonSmoker = (sandbox.CoughingChanceNonSmoker or 15) / 100

    -- Nicotine system options
    opt.UseNicotineSystem = sandbox.UseNicotineSystem
    opt.DynamicSmokerTrait = sandbox.DynamicSmokerTrait
    opt.DaysToDetox = sandbox.DaysToDetox or 30
    opt.DaysToAddiction = sandbox.DaysToAddiction or 42
    opt.DaysToPeakWithdrawal = sandbox.DaysToPeakWithdrawal or 3
    opt.SmokerTraitDecayMultiplier = sandbox.SmokerTraitDecayMultiplier or 0.6
    
    -- Speed/strength modifiers
    local smokingSpeed = sandbox.SmokingSpeed or 1.0
    local puffStrength = sandbox.PuffStrength or 1.0
    local movementBurn = sandbox.MovementBurn or 1.0
    local idleBurnOut = sandbox.IdleBurnOut or 1.0
    local effectMult = sandbox.EffectMultiplier or 1.0

    -- Global burn parameters
    opt.Global = {
        burnMin = 0.000125 * smokingSpeed,
        burnMax = 0.000300 * smokingSpeed,
        burnSpeed = 0.0025,
        burnSpeedDecay = 0.10,
        puffFactor = 1.35 * puffStrength,
        walkingFactor = 1.0 + (movementBurn - 1) * 0.5,
        runningFactor = 1.15 + (movementBurn - 1) * 0.8,
        sprintingFactor = 1.35 + (movementBurn - 1) * 1.2,
        decayRate = 0.995 + (0.998 - 0.995) * (1 - idleBurnOut),
    }

    -- Category multipliers
    opt.Category = {
        Cigarette = smokingSpeed,
        RolledCigarette = smokingSpeed * 0.9,
        Cigarillo = smokingSpeed * 0.75,
        Cigar = smokingSpeed * 0.50,
        Pipe = smokingSpeed * 0.40,
        Can = smokingSpeed * 0.60,
    }

    -- Build category configs
    opt.Cigarette = { length = 100, burn = opt.Global, effect = effectMult }
    opt.RolledCigarette = { length = 80, burn = opt.Global, effect = effectMult }
    opt.Cigarillo = { length = 125, burn = opt.Global, effect = effectMult * 1.15 }
    opt.Cigar = { length = 200, burn = opt.Global, effect = effectMult * 1.4 }
    opt.Pipe = { length = 300, burn = opt.Global, effect = effectMult * 1.8 }
    opt.Can = { length = 15, burn = opt.Global, effect = effectMult * 0.4 }
end

-- Splitscreen player state (up to 4 local players)
TrueSmoking.Players = {
    [0] = {},  -- Player 1 (keyboard)
    [1] = {},  -- Player 2
    [2] = {},  -- Player 3
    [3] = {},  -- Player 4
}

--------------------------------------------------------------------------------
-- Debug Utilities
--------------------------------------------------------------------------------

--- Print debug message with TRUESMOKING prefix
-- @param str string Message to print
function TrueSmoking.debug(str)
    if TrueSmoking.DEBUG then
        print('TRUESMOKING::' .. tostring(str))
    end
end

--------------------------------------------------------------------------------
-- Common Utilities
--------------------------------------------------------------------------------

--- Deep copy a table (recursive)
-- @param original table Table to copy
-- @return table New table with copied values
function TrueSmoking.deepCopy(original)
    if type(original) ~= 'table' then return original end
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = TrueSmoking.deepCopy(value)
    end
    return copy
end

--- Get game speed multiplier for tick-based calculations
-- Maps game speed 1-4 to actual tick multipliers
-- @return number Multiplier (1, 5, 20, or 40)
function TrueSmoking.getGameSpeedMultiplier()
    local speed = getGameSpeed()
    local multipliers = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }
    return multipliers[speed] or 1
end

--- Get player's current animation state name
-- @param player IsoPlayer
-- @return string|false State name or false if unavailable
function TrueSmoking.getPlayerState(player)
    if not player then return false end
    local stateStr = tostring(player:getCurrentState())
    return string.match(stateStr, '([^%.]+)@') or false
end

--- Get player reference table for splitscreen support
-- Each local player gets their own state table for smokable tracking
-- @param player IsoPlayer
-- @return table Player state table
function TrueSmoking.getPlayerRef(player)
    local num = 0
    if instanceof(player, 'IsoPlayer') then
        if isClient() then
            num = 0  -- MP clients always use slot 0
        else
            num = player:getPlayerNum()
        end
    end
    return TrueSmoking.Players[num] or TrueSmoking.Players[0]
end

--------------------------------------------------------------------------------
-- Smokable Object Registration (for mod compatibility)
--------------------------------------------------------------------------------

--- Register smokable objects for the system to recognize
-- Called by Config.lua on player creation
-- @param objects table Map of fullType -> smokable config
function TrueSmoking.registerSmokables(objects)
    for fullType, config in pairs(objects) do
        TrueSmoking.SmokableObjects[fullType] = config
    end
end

--- Register a callback to run each smoke tick
-- @param func function Callback receiving Smokable instance
function TrueSmoking.addCallback(func)
    table.insert(TrueSmoking.Callbacks, func)
end

--------------------------------------------------------------------------------
-- Shemagh/Mask Helpers
--------------------------------------------------------------------------------

--- Check if value exists in list
-- @param value any Value to search for
-- @param list table List to search
-- @return boolean
function TrueSmoking.isInList(value, list)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

--------------------------------------------------------------------------------
-- Body Location Registry
--------------------------------------------------------------------------------

-- Register custom mask body location for smoking visuals
local group = BodyLocations.getGroup("Human")
if group and TrueSmoking.registries and TrueSmoking.registries.mask then
    group:getOrCreateLocation(TrueSmoking.registries.mask)
end
