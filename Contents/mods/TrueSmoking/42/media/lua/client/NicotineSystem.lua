NicotineSystem = NicotineSystem or {}
NicotineSystem.__index = NicotineSystem

-- Sandbox Options
NicotineSystem.Options = {
    -- nicotine
    BASE_DECAY_RATE = 0.92,

    --Addiction
    GAIN_RATE = 0.8,
    DECAY_RATE = 0.992,

    GROWTH_THRESHOLD = 10.0,
    TRAIT_THRESHOLD = 60,
    CURE_THRESHOLD = 15,

    CURVE = {
        EXPONENT = 2,
        MULTIPLIER = 50,
    },

    INTAKE_CONVERSION = 0.2,
    ACTIVE_SMOKING_BONUS = 1.25
}

NicotineSystem.Constants = {
    INCREASE_FACTOR = 25,
    DECREASE_FACTOR = 60,
    BASE_RELIEF = 8,

    STRESS_BASE = 0.0005,
    UNHAPPINESS_BASE = 0.0000015,
    BOREDOME_BASE = 0.0000055,
    FATIGUE_BASE = 0.0001,
    HUNGER_BASE = 0.0001,

    HIGH_ADDICTION_THRESHOLD = 80,
    HIGH_ADDICTION_BOOST = 0.5,

    MESSAGE_COOLDOWN_MIN = 1.0,
    MESSAGE_COOLDOWN_MAX = 5.0,

    METABOLIC_FACTOR_BASE = 0.8,

    INTAKE_MULTIPLIER = 1.0,

    SMOOTHING_FACTOR = 0.2,
    SMOKING_SMOOTHING = 0.7,

    MIN_DECAY = 0.001,
}

-- Trait Modifiers
NicotineSystem.Effects = {
    WEIGHT = {
        EMACIATED = 50,
        VERY_LOW = 65,
        LOW = 75,
        NORMAL = 85,
        HIGH = 100,
    },

    FITNESS = {
        VERY_UNFIT = 2,
        UNFIT = 4,
        AVERAGE = 6,
        FIT = 8,
    },

    WEIGHT_MODIFIERS = {
        EMACIATED = 1.3,
        VERY_LOW = 1.2,
        LOW = 1.1,
        NORMAL = 1.0,
        HIGH = 0.9,
        VERY_HIGH = 0.7,
    },

    FITNESS_MODIFIERS = {
        VERY_UNFIT = 0.7,
        UNFIT = 0.8,
        AVERAGE = 1.0,
        FIT = 1.2,
        VERY_FIT = 1.3,
    },

    TRAIT_MODIFIERS = {
        FastMetabolism = 1.3,
        SlowMetabolism = 0.7,
        Athletic = 1.2,
        Unfit = 0.8,
        IronGut = 1.1,
        WeakStomach = 0.9,
        Resilient = 1.05,
        ProneToIllness = 0.95,
    },
    -- Add exhaustion to boost addiction recovery (worked out)
}

function NicotineSystem:initialize(player)
    local defaultNicotineSystem = {
        nicotineLevel = 0,
        addictionLevel = player:HasTrait("Smoker") and 80 or 0,
        lastUpdate = getGameTime():getWorldAgeHours(),
        lastWithdrawalMessage = 0,
        withdrawalLevel = 0,

        previousNicotineLevel = 0,
        previousAddictionLevel = 0,

        longTermNicotineChangeRate = 0,
        longTermAddictionChangeRate = 0,
        longTermStressChangeRate = 0,
        longTermUnhappinessChangeRate = 0,
        longTermBoredomChangeRate = 0,
        longTermFatigueChangeRate = 0,
        longTermHungerChangeRate = 0,

        lastIntakeTimestamp = 0,

        addictionDuration = 0,
        addictionDurationDays = 0,
        timeToNextWithdrawal = 0,
        timeSinceLastMessage = 0,
        messageCooldown = 0,
        metabolicFactor = 1.0,
        toleranceFactor = 1.0,

        isActivelySmoking = false,

        stressChange = 0,
        unhappinessChange = 0,
        fatigueChange = 0,
        hungerChange = 0,
        boredomChange = 0,
    }

    local modData = player:getModData()

    if not modData.nicotineSystem then
        modData.nicotineSystem = defaultNicotineSystem
    else
        for key, defaultValue in pairs(defaultNicotineSystem) do
            if modData.nicotineSystem[key] == nil then
                modData.nicotineSystem[key] = defaultValue
                print("TRUESMOKING::Added missing nicotineSystem property: " .. key .. " = " .. tostring(defaultValue))
            end
        end
    end

    modData.nicotineSystem.player = player
end

function NicotineSystem:trackValueChange(data, valueType, delta, timeElapsed)
    local effectiveTime = math.max(0.01, timeElapsed)
    local instantRate = delta / effectiveTime
    local rateKey = "realtime" .. valueType:gsub("^%l", string.upper) .. "ChangeRate"
    local longTermKey = "longTerm" .. valueType:gsub("^%l", string.upper) .. "ChangeRate"

    if not data[rateKey] then
        data[rateKey] = instantRate
    else
        local oldValueWeight = self.Constants.SMOOTHING_FACTOR
        if data.isActivelySmoking then
            oldValueWeight = self.Constants.SMOKING_SMOOTHING
        end
        data[rateKey] = (data[rateKey] * oldValueWeight) + (instantRate * (1 - oldValueWeight))
    end

    if not data[longTermKey] then
        data[longTermKey] = data[rateKey]
    else
        local longTermSmoothing = 0.95
        data[longTermKey] = (data[longTermKey] * longTermSmoothing) + (data[rateKey] * (1 - longTermSmoothing))
    end

    return data[rateKey]
end

function NicotineSystem:updateChangeRates(data, nicotineDelta, addictionDelta, timeElapsed)
    local isActivelySmoking = TrueSmoking:getPlayerReference(data.player).isSmoking

    data.isActivelySmoking = isActivelySmoking

    if nicotineDelta ~= 0 then
        self:trackValueChange(data, "nicotine", nicotineDelta, timeElapsed)
    end

    if addictionDelta ~= 0 then
        self:trackValueChange(data, "addiction", addictionDelta, timeElapsed)
    end
end

function NicotineSystem:calculateAddictionDuration(player)
    local data = player:getModData().nicotineSystem
    if not data or data.addictionLevel <= 0 then return 0 end

    local simulatedAddiction = data.addictionLevel
    local hoursPassed = 0
    local maxSimulationHours = 200

    while simulatedAddiction > self.Options.GROWTH_THRESHOLD and hoursPassed < maxSimulationHours do
        hoursPassed = hoursPassed + 1

        local exponentialDecay = simulatedAddiction * (self.Options.DECAY_RATE ^ 1)
        local linearComponent = 0

        if simulatedAddiction < self.Options.CURE_THRESHOLD * 1.5 then
            local factor = 1 - (simulatedAddiction / (self.Options.CURE_THRESHOLD * 1.5))
            linearComponent = self.Options.GAIN_RATE * 1 * factor * 2
        end

        if simulatedAddiction < 10 then
            linearComponent = linearComponent + self.Constants.MIN_DECAY
        end

        simulatedAddiction = math.max(0, exponentialDecay - linearComponent)
    end

    data.addictionDuration = hoursPassed
    data.addictionDurationDays = math.ceil(hoursPassed / 24)

    return hoursPassed
end

function NicotineSystem:calculateDynamicMetabolicFactor(player)
    local weight = player:getNutrition():getWeight()
    local fitness = player:getPerkLevel(Perks.Fitness)

    local baseFactor = self.Constants.METABOLIC_FACTOR_BASE

    local weightModifier = self.Effects.WEIGHT_MODIFIERS.NORMAL

    if weight < self.Effects.WEIGHT.EMACIATED then
        weightModifier = self.Effects.WEIGHT_MODIFIERS.EMACIATED
    elseif weight < self.Effects.WEIGHT.VERY_LOW then
        weightModifier = self.Effects.WEIGHT_MODIFIERS.VERY_LOW
    elseif weight < self.Effects.WEIGHT.LOW then
        weightModifier = self.Effects.WEIGHT_MODIFIERS.LOW
    elseif weight < self.Effects.WEIGHT.NORMAL then
        weightModifier = self.Effects.WEIGHT_MODIFIERS.NORMAL
    elseif weight < self.Effects.WEIGHT.HIGH then
        weightModifier = self.Effects.WEIGHT_MODIFIERS.HIGH
    else
        weightModifier = self.Effects.WEIGHT_MODIFIERS.VERY_HIGH
    end

    local fitnessModifier = self.Effects.FITNESS_MODIFIERS.AVERAGE

    if fitness <= self.Effects.FITNESS.VERY_UNFIT then
        fitnessModifier = self.Effects.FITNESS_MODIFIERS.VERY_UNFIT
    elseif fitness <= self.Effects.FITNESS.UNFIT then
        fitnessModifier = self.Effects.FITNESS_MODIFIERS.UNFIT
    elseif fitness <= self.Effects.FITNESS.AVERAGE then
        fitnessModifier = self.Effects.FITNESS_MODIFIERS.AVERAGE
    elseif fitness <= self.Effects.FITNESS.FIT then
        fitnessModifier = self.Effects.FITNESS_MODIFIERS.FIT
    else
        fitnessModifier = self.Effects.FITNESS_MODIFIERS.VERY_FIT
    end

    local traitModifier = 1.0

    for traitName, modifier in pairs(self.Effects.TRAIT_MODIFIERS) do
        if player:HasTrait(traitName) then
            traitModifier = traitModifier * modifier
        end
    end

    local finalFactor = baseFactor * weightModifier * fitnessModifier * traitModifier

    finalFactor = math.max(0.5, math.min(1.5, finalFactor))

    return finalFactor
end

function NicotineSystem:calculateMessageCooldown(withdrawalLevel)
    local maxCooldown = self.Constants.MESSAGE_COOLDOWN_MAX
    local minCooldown = self.Constants.MESSAGE_COOLDOWN_MIN
    local range = maxCooldown - minCooldown

    return maxCooldown - (range * (withdrawalLevel / 100))
end

function NicotineSystem:calculateWithdrawalIntensity(addictionLevel, hoursPassed)
    local normalizedAddiction = addictionLevel / 100

    local intensity = (normalizedAddiction * normalizedAddiction * normalizedAddiction) * hoursPassed

    if addictionLevel > self.Constants.HIGH_ADDICTION_THRESHOLD then
        local extraFactor = (addictionLevel - self.Constants.HIGH_ADDICTION_THRESHOLD) /
            (100 - self.Constants.HIGH_ADDICTION_THRESHOLD)
        intensity = intensity * (1 + (extraFactor * self.Constants.HIGH_ADDICTION_BOOST))
    end

    return intensity
end

function NicotineSystem:update(player)
    local data = player:getModData().nicotineSystem
    if not data then return end

    local currentTime = getGameTime():getWorldAgeHours()
    local hoursPassed = currentTime - data.lastUpdate
    if hoursPassed <= 0 then return end

    local previousNicotineLevel = data.nicotineLevel
    local previousAddictionLevel = data.addictionLevel

    self:updateNicotineLevel(data, hoursPassed, player)
    self:updateAddictionLevel(player, data, hoursPassed)

    local nicotineDelta = data.nicotineLevel - previousNicotineLevel
    local addictionDelta = data.addictionLevel - previousAddictionLevel

    local timeSinceIntake = currentTime - (data.lastIntakeTimestamp or 0)
    if timeSinceIntake >= 0.08 then
        self:updateChangeRates(data, nicotineDelta, addictionDelta, hoursPassed)
    end

    self:manageSmokerTrait(player)

    if math.floor(currentTime) > math.floor(data.lastUpdate) then
        self:calculateAddictionDuration(player)
    end

    data.lastUpdate = currentTime
end

function NicotineSystem:updateNicotineLevel(data, hoursPassed, player)
    local previousNicotineLevel = data.nicotineLevel
    local dynamicDecayRate = self:calculateDynamicDecayRate(data.addictionLevel, player)
    data.currentDecayRate = dynamicDecayRate

    local isSmoking = TrueSmoking:getPlayerReference(player).Smokable.smokeLit

    if not isSmoking then
        data.nicotineLevel = data.nicotineLevel * (dynamicDecayRate ^ hoursPassed)
    end

    if player:HasTrait('Smoker') then
        if data.nicotineLevel < self.Options.GROWTH_THRESHOLD then
            local timeFactor = player:getTimeSinceLastSmoke() / 10
            local increaseRate = (data.addictionLevel / 100) * self.Constants.INCREASE_FACTOR * timeFactor
            data.withdrawalLevel = math.min(100, data.withdrawalLevel + increaseRate * hoursPassed)
            self:applyWithdrawalEffects(player, hoursPassed)
        else
            local decreaseRate = self.Constants.DECREASE_FACTOR
            if isSmoking then decreaseRate = decreaseRate * 5 end
            data.withdrawalLevel = math.max(0, data.withdrawalLevel - decreaseRate * hoursPassed)
            if data.nicotineLevel > 1 and data.withdrawalLevel >= 0 then
                self:relieveWithdrawalEffects(player, hoursPassed)
            end
        end
    end

    if data.nicotineLevel > 5 then
        local nicotineContent = data.nicotineLevel / 100
        local max_factor = 1.5
        local k = math.log(max_factor + 1)
        local factor = math.exp(k * nicotineContent) - 1

        local stats = player:getStats()
        local fatigueReduction = stats:getFatigue() * self.Constants.FATIGUE_BASE * factor
        local hungerReduction = stats:getHunger() * self.Constants.HUNGER_BASE * factor

        data.fatigueChange = fatigueReduction
        data.hungerChange = hungerReduction

        self:trackValueChange(data, "fatigue", fatigueReduction, hoursPassed)
        self:trackValueChange(data, "hunger", hungerReduction, hoursPassed)

        stats:setFatigue(math.max(0, stats:getFatigue() - fatigueReduction))
        stats:setHunger(math.max(0, stats:getHunger() - hungerReduction))
    end

    if data.nicotineLevel < 0.0005 then
        data.nicotineLevel = 0
    end

    if hoursPassed > 0 then
        local nicotineDelta = data.nicotineLevel - previousNicotineLevel
        self:trackValueChange(data, "nicotine", nicotineDelta, hoursPassed)
    end
end

function NicotineSystem:updateAddictionLevel(player, data, hoursPassed)
    local previousAddictionLevel = data.addictionLevel

    if data.nicotineLevel >= self.Options.GROWTH_THRESHOLD then
        local normalizedLevel = data.nicotineLevel / 100

        local thresholdFactor = math.max(0, (normalizedLevel - self.Options.GROWTH_THRESHOLD / 100) /
            (1 - self.Options.GROWTH_THRESHOLD / 100))

        local exponentialComponent = (thresholdFactor ^ self.Options.CURVE.EXPONENT) *
            self.Options.CURVE.MULTIPLIER *
            self.Options.GAIN_RATE

        local activeSmokingBonus = 0

        if data.isActivelySmoking then
            activeSmokingBonus = self.Options.GAIN_RATE * self.Options.ACTIVE_SMOKING_BONUS * normalizedLevel
        end

        if activeSmokingBonus == 0 and TrueSmoking:getPlayerReference(player).isSmoking then
            activeSmokingBonus = self.Options.GAIN_RATE * self.Options.ACTIVE_SMOKING_BONUS * normalizedLevel
        end

        local addictionChange = (exponentialComponent + activeSmokingBonus) * hoursPassed
        data.addictionLevel = math.min(100, data.addictionLevel + addictionChange)
    elseif not TrueSmoking:getPlayerReference(player).Smokable.smokeLit then
        local exponentialDecay = data.addictionLevel * (self.Options.DECAY_RATE ^ hoursPassed)
        local linearComponent = 0

        if data.addictionLevel < self.Options.CURE_THRESHOLD * 1.5 then
            local factor = 1 - (data.addictionLevel / (self.Options.CURE_THRESHOLD * 1.5))
            linearComponent = self.Options.GAIN_RATE * hoursPassed * factor * 2
        end

        if data.addictionLevel < 10 then
            linearComponent = linearComponent + (self.Constants.MIN_DECAY * hoursPassed)
        end

        data.addictionLevel = math.max(0, exponentialDecay - linearComponent)
    end

    if hoursPassed > 0 then
        local addictionDelta = data.addictionLevel - previousAddictionLevel
        self:trackValueChange(data, "addiction", addictionDelta, hoursPassed)
    end
end

function NicotineSystem:calculateDynamicDecayRate(addiction, player)
    local baseRate = self.Options.BASE_DECAY_RATE
    local addictionFactor = addiction / 100

    local metabolicFactor = self:calculateDynamicMetabolicFactor(player)
    player:getModData().nicotineSystem.metabolicFactor = metabolicFactor

    local adjustedBaseRate = baseRate * metabolicFactor

    local maxDecayRate = 0.125

    local decayRate = adjustedBaseRate + (maxDecayRate - adjustedBaseRate) * addictionFactor

    return math.max(0.001, math.min(0.99, decayRate))
end

function NicotineSystem:addNicotine(player, amount)
    local data = player:getModData().nicotineSystem
    if not data then self:initialize(player) end
    data = player:getModData().nicotineSystem

    local previousNicotineLevel = data.nicotineLevel
    local previousAddictionLevel = data.addictionLevel

    local adjustedAmount = amount * self.Constants.INTAKE_MULTIPLIER

    local addictionFactor = data.addictionLevel / 100

    local metabolicFactor = self:calculateDynamicMetabolicFactor(player)
    data.metabolicFactor = metabolicFactor

    local toleranceFactor = (1.5 - addictionFactor) * (1.0 / metabolicFactor)
    data.toleranceFactor = toleranceFactor

    local finalAmount = adjustedAmount * toleranceFactor

    data.nicotineLevel = math.min(100, data.nicotineLevel + finalAmount)

    local baseAddiction = finalAmount * 0.01

    if data.nicotineLevel >= self.Options.GROWTH_THRESHOLD then
        local nicotineAdded = data.nicotineLevel - previousNicotineLevel
        local normalizedLevel = data.nicotineLevel / 100

        local thresholdFactor = math.max(0, (normalizedLevel - self.Options.GROWTH_THRESHOLD / 100) /
            (1 - self.Options.GROWTH_THRESHOLD / 100))

        local baseImpact = nicotineAdded * self.Options.INTAKE_CONVERSION
        local curveImpact = nicotineAdded * 0.12 * thresholdFactor ^ self.Options.CURVE.EXPONENT

        local earlyBoostMultiplier = 1.0
        if data.addictionLevel < 40 then
            earlyBoostMultiplier = 1.5
        end

        local totalAddiction = (baseAddiction + baseImpact + curveImpact) * earlyBoostMultiplier
        data.addictionLevel = math.min(100, data.addictionLevel + totalAddiction)
    else
        data.addictionLevel = math.min(100, data.addictionLevel + (baseAddiction * 0.1))
    end

    local nicotineDelta = data.nicotineLevel - previousNicotineLevel
    local addictionDelta = data.addictionLevel - previousAddictionLevel

    local currentTime = getGameTime():getWorldAgeHours()
    data.lastIntakeTimestamp = currentTime

    local effectiveTime = 0.01

    self:trackValueChange(data, "nicotine", nicotineDelta, effectiveTime)
    self:trackValueChange(data, "addiction", addictionDelta, effectiveTime)

    local currentTime = getGameTime():getWorldAgeHours()
    data.lastIntakeTimestamp = currentTime
    data.lastUpdate = currentTime
end

function NicotineSystem:applyWithdrawalEffects(player, hoursPassed)
    local data = player:getModData().nicotineSystem
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    local intensity = ((data.withdrawalLevel / 100) + (player:getTimeSinceLastSmoke() / 10))/2

    local stressChange = intensity * self.Constants.STRESS_BASE * hoursPassed
    local unhappinessChange = intensity * self.Constants.UNHAPPINESS_BASE * hoursPassed
    local boredomChange = intensity * self.Constants.BOREDOME_BASE * hoursPassed
    data.stressChange = stressChange
    data.unhappinessChange = unhappinessChange
    data.boredomChange = boredomChange

    self:trackValueChange(data, "stress", stressChange, hoursPassed)
    self:trackValueChange(data, "unhappiness", unhappinessChange, hoursPassed)
    self:trackValueChange(data, "boredom", boredomChange, hoursPassed)

    stats:setStressFromCigarettes(math.min(0.51, stats:getStressFromCigarettes() + stressChange))
    bodyDamage:setUnhappynessLevel(math.min(100, bodyDamage:getUnhappynessLevel() + unhappinessChange))
    bodyDamage:setBoredomLevel(math.min(100, bodyDamage:getBoredomLevel() + boredomChange))

    local currentTime = getGameTime():getWorldAgeHours()
    if not data.lastWithdrawalMessage then data.lastWithdrawalMessage = 0 end

    local messageCooldown = self:calculateMessageCooldown(data.withdrawalLevel)
    data.messageCooldown = messageCooldown
    local timeSinceLastMessage = currentTime - data.lastWithdrawalMessage
    data.timeSinceLastMessage = timeSinceLastMessage

    if timeSinceLastMessage >= messageCooldown then
        local messageChance = 50 -- Fixed chance, adjustable
        if ZombRand(100) < messageChance then
            local symptomIndex = ZombRand(1, 10)
            player:Say(getText("UI_TRUESMOKING_WITHDRAWAL_SYMPTOM_" .. symptomIndex))
            data.lastWithdrawalMessage = currentTime
        end
    end
end

function NicotineSystem:relieveWithdrawalEffects(player, hoursPassed)
    local data = player:getModData().nicotineSystem
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    local addictionFactor = data.addictionLevel / 100
    local reliefFactor = 1.0 - (addictionFactor * 0.7)

    local stressChange = reliefFactor * self.Constants.STRESS_BASE
    local unhappinessChange = reliefFactor * self.Constants.UNHAPPINESS_BASE
    local boredomChange = reliefFactor * self.Constants.BOREDOME_BASE
    data.stressChange = stressChange
    data.unhappinessChange = unhappinessChange
    data.boredomChange = boredomChange

    self:trackValueChange(data, "stress", stressChange, hoursPassed)
    self:trackValueChange(data, "unhappiness", unhappinessChange, hoursPassed)
    self:trackValueChange(data, "boredom", boredomChange, hoursPassed)

    stats:setStressFromCigarettes(math.max(0,
        stats:getStressFromCigarettes() - stressChange))
    bodyDamage:setUnhappynessLevel(math.max(0,
        bodyDamage:getUnhappynessLevel() - unhappinessChange))
    bodyDamage:setBoredomLevel(math.max(0,
        bodyDamage:getBoredomLevel() - boredomChange))

    data.lastWithdrawalMessage = getGameTime():getWorldAgeHours()
    data.timeToNextWithdrawal = self:calculateMessageCooldown(data.withdrawalLevel)
end

function NicotineSystem:manageSmokerTrait(player)
    local data = player:getModData().nicotineSystem

    if data.addictionLevel >= self.Options.TRAIT_THRESHOLD and not player:HasTrait("Smoker") then
        player:getTraits():add("Smoker")
        HaloTextHelper.addTextWithArrow(player, getText("UI_TRUESMOKING_BECAME_SMOKER"), true,
            HaloTextHelper.getColorRed())
    elseif data.addictionLevel <= self.Options.CURE_THRESHOLD and player:HasTrait("Smoker") then
        player:getTraits():remove("Smoker")
        HaloTextHelper.addTextWithArrow(player, getText("UI_TRUESMOKING_QUIT_SMOKING"), true,
            HaloTextHelper.getColorGreen())
    end
end
