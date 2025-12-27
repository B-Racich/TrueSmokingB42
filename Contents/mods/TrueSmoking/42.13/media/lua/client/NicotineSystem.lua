require 'TrueSmoking'
require 'Smokable'

NicotineSystem = NicotineSystem or {}
NicotineSystem.__index = NicotineSystem

NicotineSystem.DefaultOptions = {
    DaysToDetox = 30,
    SmokerTraitDecayMultiplier = 0.65,
    DaysToAddiction = 42,
    DaysToPeakWithdrawal = 3,
}

NicotineSystem.Options = NicotineSystem.DefaultOptions

NicotineSystem.Config = {
    ACTIVE_SMOKING_BONUS            = 2.2,
    EXERCISE_DECAY_BONUS_MULTIPLIER = 1.3,

    ADDICTION_GAIN_PER_MINUTE       = 0.00045,
    ADDICTION_GAIN_PER_PUFF         = 0.88,

    WITHDRAWAL_GAIN_PER_MINUTE      = 0.020,
    WITHDRAWAL_RELIEF_PER_PUFF      = 0.55,
    WITHDRAWAL_NICOTINE_RELIEF_RATE = 0.14,
    WITHDRAWAL_PEAK_GAIN_PER_MINUTE = 0.02315,

    NICOTINE_THRESHOLD              = 8.0,
    NICOTINE_DECAY_PER_MINUTE       = 0.005,

    SMOKER_TRAIT_GAIN_THRESHOLD     = 70,
    SMOKER_TRAIT_LOSE_THRESHOLD     = 15,

    UNHAPPYNESS_FROM_WITHDRAWAL     = 0.35,
    BOREDOM_FROM_WITHDRAWAL         = 0.45,
    FATIGUE_FROM_NICOTINE           = 0.00195,
    HUNGER_FROM_NICOTINE            = 0.00115,
    STRESS_FROM_NICOTINE            = 0.00012,

    OVERFLOW_LEAK_RATE              = 0.05,
}

local tsDebug = TrueSmoking.tsDebug

function NicotineSystem:UpdateDynamicConfig(player)
    local daysToZero    = math.max(1, self.Options.DaysToDetox or 30)
    local daysToAddict  = math.max(1, self.Options.DaysToAddiction or 42)
    local daysToPeak    = math.max(1, self.Options.DaysToPeakWithdrawal or 3)
    local avgCigsPerDay = 3
    local maxAddiction  = 100

    local data          = player:getModData().nicotineSystem
    if not data then
        self:initialize(player)
        data = player:getModData().nicotineSystem
    end

    local minutesInDetox                          = daysToZero * 24 * 60
    local baseDecay                               = data.addictionLevel / minutesInDetox
    self.Config.ADDICTION_DECAY_PER_MINUTE        = baseDecay
    self.Config.ADDICTION_DECAY_PER_MINUTE_SMOKER = baseDecay * self.Options.SmokerTraitDecayMultiplier

    local totalCigsToCap                          = avgCigsPerDay * daysToAddict
    local addictionPerCig                         = maxAddiction / totalCigsToCap * 1.15 -- +15% buffer for feel

    self.Config.ADDICTION_PER_CIGARETTE           = addictionPerCig

    local passiveDaily                            = 3.0 / daysToAddict
    self.Config.ADDICTION_GAIN_PER_MINUTE         = math.max(0.00001, passiveDaily / 1440)

    local minutesToPeak                           = daysToPeak * 24 * 60
    local basePeakGain                            = 100 / minutesToPeak

    self.Config.WITHDRAWAL_PEAK_GAIN_PER_MINUTE   = basePeakGain / 1.5
end

function NicotineSystem:initialize(player)
    local data = player:getModData()
    if not data.nicotineSystem then
        tsDebug('Initializing Nicotine System for player ' .. tostring(player:getDisplayName()))
        data.nicotineSystem = {
            nicotineLevel    = 0,
            addictionLevel   = player:hasTrait(CharacterTrait.SMOKER) and self.Config.SMOKER_TRAIT_GAIN_THRESHOLD * 1.2 or
                0,
            withdrawalLevel  = player:hasTrait(CharacterTrait.SMOKER) and 35 or 0,
            AddictionTime    = 0,
            nicotineTime     = 0,
            unhappinessCap   = 0,
            boredomCap       = 0,
            nicotineOverflow = 0,
        }
    else
        local defaults = {
            nicotineLevel    = 0,
            addictionLevel   = 0,
            withdrawalLevel  = 0,
            AddictionTime    = 0,
            nicotineTime     = 0,
            unhappinessCap   = 0,
            boredomCap       = 0,
            nicotineOverflow = 0,
        }
        for field, defaultValue in pairs(defaults) do
            if data.nicotineSystem[field] == nil then
                tsDebug('Setting missing field "' ..
                    field .. '" to default value for player ' .. tostring(player:getDisplayName()))
                data.nicotineSystem[field] = defaultValue
            end
        end
    end
    -- player:transmitModData()
    sendClientCommand(player, 'TrueSmoking', 'updatePlayerNicData', { data.nicotineSystem })
end

Events.OnCreatePlayer.Add(function(_, player)
    NicotineSystem:initialize(player)
    NicotineSystem:UpdateDynamicConfig(player)
end)

function NicotineSystem:GameTimeUpdate(playerRaw)
    local player = playerRaw
    if isClient() then
        player = getPlayerByOnlineID(playerRaw:getOnlineID())
    end
    if not player or player:isDead() then return end

    local data = player:getModData().nicotineSystem
    if not data then
        self:initialize(player)
        data = player:getModData().nicotineSystem
    end

    local stats       = player:getStats()
    local bd          = player:getBodyDamage()
    local tableRef    = TrueSmoking and player:getModData().TrueSmoking
    local isSmoking   = tableRef and tableRef.Smokable and tableRef.Smokable.smokeLit
    local lastSmoke   = player:getTimeSinceLastSmoke()
    local updateStats = {}

    -- Nicotine Decay and overflow
    if not isSmoking then
        data.nicotineLevel = data.nicotineLevel * (1 - self.Config.NICOTINE_DECAY_PER_MINUTE)
        data.nicotineLevel = math.max(0, data.nicotineLevel)
        if data.nicotineOverflow > 0 then
            local leakAmount = data.nicotineOverflow * self.Config.OVERFLOW_LEAK_RATE
            local availableSpace = 100 - data.nicotineLevel

            if availableSpace > 0 then
                leakAmount = math.min(leakAmount, availableSpace) -- Don't exceed capacity
                data.nicotineLevel = math.min(100, data.nicotineLevel + leakAmount)
                data.nicotineOverflow = math.max(0, data.nicotineOverflow - leakAmount)
            end
        end
    end

    -- Timer
    if data.nicotineLevel > 0.01 then
        local minutesToZero = data.nicotineLevel / self.Config.NICOTINE_DECAY_PER_MINUTE
        local hoursToZero   = minutesToZero / 10 / 60

        data.nicotineTime   = math.floor(hoursToZero * 10 + 0.5) / 10 / .6
    else
        data.nicotineTime = 0.0
    end

    local lowNicotine = data.nicotineLevel < self.Config.NICOTINE_THRESHOLD

    -- Withdrawal effects
    if lowNicotine and data.addictionLevel > 8 then
        local w = data.withdrawalLevel / 100
        local unhappinessCap = 20 * w
        local boredomCap = 25 * w

        data.unhappinessCap = unhappinessCap
        data.boredomCap = boredomCap


        if stats:get(CharacterStat.UNHAPPINESS) < unhappinessCap then
            -- stats:set(CharacterStat.UNHAPPINESS,
            --     math.min(unhappinessCap, stats:get(CharacterStat.UNHAPPINESS) + self.Config.UNHAPPYNESS_FROM_WITHDRAWAL))
            updateStats['UNHAPPINESS'] = math.min(unhappinessCap,
                stats:get(CharacterStat.UNHAPPINESS) + self.Config.UNHAPPYNESS_FROM_WITHDRAWAL)
        end
        if stats:get(CharacterStat.BOREDOM) < boredomCap then
            -- stats:set(CharacterStat.BOREDOM,
            --     math.min(boredomCap, stats:get(CharacterStat.BOREDOM) + self.Config.BOREDOM_FROM_WITHDRAWAL))
            updateStats['BOREDOM'] = math.min(boredomCap,
                stats:get(CharacterStat.BOREDOM) + self.Config.BOREDOM_FROM_WITHDRAWAL)
        end

        -- sendClientCommand(player, 'TrueSmoking', 'updateStats', { updateStats })

        local intensityMultiplier = 1.0 + (data.addictionLevel / 100) * 0.5

        local hoursSinceLastSmoke = lastSmoke
        local earlyBoost = math.min(hoursSinceLastSmoke / 24, 2.0)
        intensityMultiplier = intensityMultiplier + earlyBoost * 0.15

        local gain = self.Config.WITHDRAWAL_PEAK_GAIN_PER_MINUTE * intensityMultiplier

        data.withdrawalLevel = math.min(100, data.withdrawalLevel + gain)
    else
        local relief = 0
        if isSmoking then
            relief = self.Config.WITHDRAWAL_RELIEF_PER_PUFF
        elseif data.nicotineLevel > 20 then
            relief = self.Config.WITHDRAWAL_NICOTINE_RELIEF_RATE * (data.nicotineLevel / 100)
        end
        data.withdrawalLevel = math.max(0, data.withdrawalLevel - relief)
    end

    if data.nicotineLevel > 5 then
        local strength = math.min(data.nicotineLevel / 100, 1.0)              -- 0–1 scale

        local fatigueReduction = self.Config.FATIGUE_FROM_NICOTINE * strength -- ~0.025 per minute at full nicotine
        -- stats:set(CharacterStat.FATIGUE, math.max(0, stats:get(CharacterStat.FATIGUE) - fatigueReduction))
        updateStats['FATIGUE'] = math.max(0, stats:get(CharacterStat.FATIGUE) - fatigueReduction)

        local hungerReduction = self.Config.HUNGER_FROM_NICOTINE * strength -- ~0.00054 per minute → ~0.78 per day at max
        -- stats:set(CharacterStat.HUNGER, math.max(0, stats:get(CharacterStat.HUNGER) - hungerReduction))
        updateStats['HUNGER'] = math.max(0, stats:get(CharacterStat.HUNGER) - hungerReduction)

        if stats:get(CharacterStat.STRESS) > 0 then
            stats:set(CharacterStat.STRESS,
                math.max(0,
                    (stats:get(CharacterStat.STRESS) - stats:get(CharacterStat.NICOTINE_WITHDRAWAL)) -
                    (self.Config.STRESS_FROM_NICOTINE * strength)))
        end
    end

    if data.nicotineLevel > 8 then
        local gain = self.Config.ADDICTION_GAIN_PER_MINUTE
        if isSmoking then gain = gain * self.Config.ACTIVE_SMOKING_BONUS end
        local factor = math.min(data.nicotineLevel / 60, 1.6)
        data.addictionLevel = data.addictionLevel + (gain * factor)
    else
        if lowNicotine and data.withdrawalLevel >= 0 and not isSmoking then
            if not self.Config.ADDICTION_DECAY_PER_MINUTE then self:UpdateDynamicConfig(player) end
            local baseDecay = player:hasTrait(CharacterTrait.SMOKER)
                and self.Config.ADDICTION_DECAY_PER_MINUTE_SMOKER
                or self.Config.ADDICTION_DECAY_PER_MINUTE

            local fatigue = player:getStats():get(CharacterStat.FATIGUE)
            local exerciseBonus = 1.0
            if fatigue > 0.7 then
                local bonusStrength = (fatigue - 0.7) / 0.3
                exerciseBonus = 1.0 + bonusStrength * (self.Config.EXERCISE_DECAY_BONUS_MULTIPLIER - 1.0)
            end

            local finalDecay = baseDecay * exerciseBonus
            data.addictionLevel = math.max(0, data.addictionLevel - finalDecay)

            if data.addictionLevel > 0 then
                local minutesLeft = data.addictionLevel / finalDecay
                data.AddictionTime = math.ceil(minutesLeft / 1440 * 10) / 10
            end
        end
    end

    if TrueSmoking and TrueSmoking.Options and TrueSmoking.Options.DynamicSmokerTrait then
        if data.addictionLevel >= self.Config.SMOKER_TRAIT_GAIN_THRESHOLD and not player:hasTrait(CharacterTrait.SMOKER) then
            -- player:getTraits():add('Smoker')
            sendClientCommand(player, 'TrueSmoking', 'addTrait', {'SMOKER'})
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, getText('UI_TRUESMOKING_BECAME_SMOKER'), true,
                    HaloTextHelper.getColorRed())
            end
        elseif data.addictionLevel < self.Config.SMOKER_TRAIT_LOSE_THRESHOLD and player:hasTrait(CharacterTrait.SMOKER) then
            -- player:getTraits():remove('Smoker')
            sendClientCommand(player, 'TrueSmoking', 'removeTrait', {'SMOKER'})
            -- stats:setStressFromCigarettes(0)
            updateStats['NICOTINE_WITHDRAWAL'] = 0
            -- stats:reset(CharacterStat.NICOTINE_WITHDRAWAL)
            data.boredomCap = 0
            data.unhappinessCap = 0
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, getText('UI_TRUESMOKING_QUIT_SMOKING'), true,
                    HaloTextHelper.getColorGreen())
            end
        end
    end
    -- player:transmitModData()
    sendClientCommand(player, 'TrueSmoking', 'updatePlayerNicData', { data })
    sendClientCommand(player, 'TrueSmoking', 'updateStats', { updateStats })
end

function NicotineSystem:smoke(playerRaw, rawAmountPerPuff, nicotineContent)
    local player = playerRaw
    if isClient() then
        player = getPlayerByOnlineID(playerRaw:getOnlineID())
    end
    local data = player:getModData().nicotineSystem
    if not data then return end

    local maxAddiction = 100
    local puffFraction = rawAmountPerPuff / nicotineContent

    local tolerance = math.min(data.addictionLevel / 100, 0.25)
    local effectiveIntake = rawAmountPerPuff * (1.0 - tolerance)

    if data.nicotineLevel > 70 then
        local reduction = (data.nicotineLevel - 70) / 50
        effectiveIntake = effectiveIntake * (1 - math.min(reduction, 0.65))
    end

    if data.nicotineLevel + effectiveIntake > 100 then
        local overflow = (data.nicotineLevel + effectiveIntake) - 100
        data.nicotineOverflow = data.nicotineOverflow + overflow
        data.nicotineLevel = 100
    else
        data.nicotineLevel = data.nicotineLevel + effectiveIntake
    end

    data.withdrawalLevel = math.max(0, data.withdrawalLevel - self.Config.WITHDRAWAL_RELIEF_PER_PUFF * puffFraction)

    local addictionTolerance = data.addictionLevel / maxAddiction
    local effectiveGain = self.Config.ADDICTION_GAIN_PER_PUFF * puffFraction *
        (1.0 - math.min(addictionTolerance * 0.85, 0.85))

    data.addictionLevel = math.min(maxAddiction, data.addictionLevel + effectiveGain)
    -- player:transmitModData()
    sendClientCommand(player, 'TrueSmoking', 'updatePlayerNicData', { data })
end
