NicotineSystem = NicotineSystem or {}
NicotineSystem.__index = NicotineSystem

NicotineSystem.Options = {
    NICOTINE_DECAY_RATE = 0.9,
    ADDICTION_GAIN_RATE = 0.065,
    ADDICTION_DECAY_RATE = 0.0012,
    ADDICTION_MIN_DECAY = 0.08,
    ADDICTION_GAIN_THRESHOLD = 10.0,
    SMOKER_TRAIT_THRESHOLD = 60,
    SMOKER_TRAIT_LOSE_THRESHOLD = 15,
    ADDICTION_GROWTH_CURVE = {
        EXPONENT = 1.8,
        MULTIPLIER = 50,
    },
    INTAKE_CONVERSION = 0.022,
    ACTIVE_SMOKING_BONUS = 0.125,
    FATIGUE_BASE = 0.0001,
    HUNGER_BASE = 0.0001,
    STRESS_BASE = 0.2,
    UNHAPPINESS_BASE = 1,
    BOREDOM_BASE = 1,
    UNHAPPINESS_MAX = 35,
    BOREDOM_MAX = 35,
    ADDICTION_CAP = 10000,
}

NicotineSystem.Constants = {
    INCREASE_FACTOR = 25,
    DECREASE_FACTOR = 60,
    BASE_RELIEF = 8,
    HIGH_ADDICTION_THRESHOLD = 80,
    HIGH_ADDICTION_BOOST = 0.5,
    MESSAGE_COOLDOWN_MIN = 0.0167,
    MESSAGE_COOLDOWN_MAX = 0.0833,
    METABOLIC_FACTOR_BASE = 0.8,
    INTAKE_MULTIPLIER = 1.0,
    SMOOTHING_FACTOR = 0.2,
    SMOKING_SMOOTHING = 0.7,
}

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
}

function NicotineSystem:initialize(player)
    local defaultNicotineSystem = {
        nicotineLevel = 0,
        addictionLevel = player:HasTrait("Smoker") and 200 or 0,
        lastUpdate = getGameTime():getWorldAgeHours(),
        lastWithdrawalMessage = 0,
        withdrawalLevel = 0,
        previousNicotineLevel = 0,
        previousAddictionLevel = 0,
        lastIntakeTimestamp = 0,
        timeToNextWithdrawal = 0,
        timeSinceLastMessage = 0,
        messageCooldown = 0,
        metabolicFactor = 1.0,
        toleranceFactor = 1.0,
        stressChange = 0,
        unhappinessChange = 0,
        boredomChange = 0,
        fatigueChange = 0,
        hungerChange = 0,
        unhappinessAccumulation = 0,
        boredomAccumulation = 0,
        stressAccumulation = 0,
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
    return math.max(0.5, math.min(1.5, finalFactor))
end

function NicotineSystem:calculateMessageCooldown(withdrawalLevel)
    local maxCooldown = self.Constants.MESSAGE_COOLDOWN_MAX
    local minCooldown = self.Constants.MESSAGE_COOLDOWN_MIN
    local range = maxCooldown - minCooldown
    return maxCooldown - (range * (withdrawalLevel / 100))
end

function NicotineSystem:calculateWithdrawalIntensity(addictionLevel)
    local normalizedAddiction = addictionLevel / self.Options.ADDICTION_CAP
    local intensity = normalizedAddiction * normalizedAddiction * normalizedAddiction
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
    local timeDelta = currentTime - data.lastUpdate
    data.lastUpdate = currentTime

    self:updateNicotineLevel(data, player, timeDelta)
    self:updateAddictionLevel(player, data, timeDelta)
    if TrueSmoking.Options.DynamicSmokerTrait then
        self:manageSmokerTrait(player)
    end

    local metabolicFactor = self:calculateDynamicMetabolicFactor(player)
    data.metabolicFactor = metabolicFactor
    local toleranceFactor = 1.0
    if data.addictionLevel > self.Options.SMOKER_TRAIT_THRESHOLD then
        toleranceFactor = (1.6 - toleranceFactor) * (1.0 / metabolicFactor)
    else
        toleranceFactor = 1.5 * (1.0 / metabolicFactor)
    end
    data.toleranceFactor = toleranceFactor
end

function NicotineSystem:updateNicotineLevel(data, player, timeDelta)
    if not data then return end
    local dynamicDecayRate = self:calculateDynamicDecayRate(player)
    data.currentDecayRate = dynamicDecayRate
    local isSmoking = TrueSmoking:getPlayerReference(player).Smokable.smokeLit
    if not isSmoking then
        data.nicotineLevel = data.nicotineLevel * (dynamicDecayRate ^ timeDelta)
    end
    if data.nicotineLevel < self.Options.ADDICTION_GAIN_THRESHOLD and player:HasTrait('Smoker') then
        local timeFactor = player:getTimeSinceLastSmoke() / 10
        if timeFactor == 0 then timeFactor = 0.15 end
        local increaseRate = (data.addictionLevel / 100) * self.Constants.INCREASE_FACTOR * timeFactor * timeDelta
        data.withdrawalLevel = math.min(100, data.withdrawalLevel + increaseRate)
        self:applyWithdrawalEffects(player, timeDelta)
    else
        local decreaseRate = self.Constants.DECREASE_FACTOR * timeDelta
        if isSmoking then decreaseRate = decreaseRate * 5 end
        data.withdrawalLevel = math.max(0, data.withdrawalLevel - decreaseRate)
        if data.nicotineLevel > 1 and data.withdrawalLevel >= 0 then
            self:relieveWithdrawalEffects(player, timeDelta)
        end
    end
    if data.nicotineLevel > 5 then
        local nicotineContent = data.nicotineLevel / 100
        local max_factor = 1.5
        local k = math.log(max_factor + 1)
        local factor = math.exp(k * nicotineContent) - 1
        local stats = player:getStats()
        local fatigueReduction = stats:getFatigue() * self.Options.FATIGUE_BASE * factor * timeDelta
        local hungerReduction = stats:getHunger() * self.Options.HUNGER_BASE * factor * timeDelta
        data.fatigueChange = fatigueReduction
        data.hungerChange = hungerReduction
        stats:setFatigue(math.max(0, stats:getFatigue() - fatigueReduction))
        stats:setHunger(math.max(0, stats:getHunger() - hungerReduction))
    end
    if data.nicotineLevel < 0.0005 then
        data.nicotineLevel = 0
    end
end

function NicotineSystem:updateAddictionLevel(player, data, timeDelta)
    if not data then return end
    local isSmoking = TrueSmoking:getPlayerReference(player).Smokable.smokeLit
    if data.nicotineLevel >= self.Options.ADDICTION_GAIN_THRESHOLD then
        local normalizedLevel = data.nicotineLevel / 100
        local thresholdFactor = math.max(0, (normalizedLevel - self.Options.ADDICTION_GAIN_THRESHOLD / 100) /
            (1 - self.Options.ADDICTION_GAIN_THRESHOLD / 100))
        local exponentialComponent = (thresholdFactor ^ self.Options.ADDICTION_GROWTH_CURVE.EXPONENT) *
            self.Options.ADDICTION_GROWTH_CURVE.MULTIPLIER *
            self.Options.ADDICTION_GAIN_RATE
        local activeSmokingBonus = 0
        if isSmoking then
            activeSmokingBonus = self.Options.ADDICTION_GAIN_RATE * self.Options.ACTIVE_SMOKING_BONUS * normalizedLevel
        end
        local addictionChange = (exponentialComponent + activeSmokingBonus) * timeDelta
        data.addictionLevel = math.min(self.Options.ADDICTION_CAP, data.addictionLevel + addictionChange)
    elseif not isSmoking then
        local baseDecayRate = self.Options.ADDICTION_DECAY_RATE
        local addictionFactor = math.min(data.addictionLevel / (self.Options.SMOKER_TRAIT_THRESHOLD * 2), 1.0)
        local decayScaler = 1.0 + (1.0 - addictionFactor) * 1.5
        local adjustedDecayRate = baseDecayRate * decayScaler
        local hasSmokerTrait = data.addictionLevel > self.Options.SMOKER_TRAIT_THRESHOLD
        local smokerMultiplier = hasSmokerTrait and 0.4 or 1.0
        local exponentialDecay = data.addictionLevel * (adjustedDecayRate * smokerMultiplier * timeDelta)
        local lowAddictionBoost = 0
        if data.addictionLevel < self.Options.SMOKER_TRAIT_LOSE_THRESHOLD * 2 then
            lowAddictionBoost = self.Options.ADDICTION_MIN_DECAY * timeDelta *
                (1.0 - data.addictionLevel / (self.Options.SMOKER_TRAIT_LOSE_THRESHOLD * 2))
        end
        local endurance = player:getStats():getEndurance()
        local enduranceModifier = 1.0 + (1.0 - endurance) * 0.5
        local totalDecay = (exponentialDecay + lowAddictionBoost) * enduranceModifier
        data.addictionLevel = math.max(0, data.addictionLevel - totalDecay)
    end
end

function NicotineSystem:calculateDynamicDecayRate(player)
    local data = player:getModData().nicotineSystem
    if not data then return 0.0001 end
    local baseRate = 0.38 -- Much lower value for faster decay
    local nicotineLevel = data.nicotineLevel
    local addictionLevel = data.addictionLevel
    local hasSmokerTrait = addictionLevel > self.Options.SMOKER_TRAIT_THRESHOLD
    local addictionCap = self.Options.SMOKER_TRAIT_THRESHOLD * 3
    local addictionFactor = math.min(addictionLevel / addictionCap, 1.0)
    local metabolicFactor = self:calculateDynamicMetabolicFactor(player)
    player:getModData().nicotineSystem.metabolicFactor = metabolicFactor
    local adjustedBaseRate = baseRate * metabolicFactor
    local traitMultiplier = hasSmokerTrait and 1.5 or 1.0
    local decayRate = math.min(0.95,
        adjustedBaseRate * traitMultiplier + addictionFactor * nicotineLevel / self.Options.SMOKER_TRAIT_THRESHOLD * 0.01)
    return math.max(0.0001, decayRate)
end

function NicotineSystem:addNicotine(player, amount)
    local data = player:getModData().nicotineSystem
    if not data then self:initialize(player) end
    data = player:getModData().nicotineSystem
    local previousNicotineLevel = data.nicotineLevel
    local adjustedAmount = amount * self.Constants.INTAKE_MULTIPLIER

    local finalAmount = adjustedAmount * data.toleranceFactor
    data.nicotineLevel = math.min(100, data.nicotineLevel + finalAmount)
    local baseAddiction = finalAmount * 0.01
    if data.nicotineLevel >= self.Options.ADDICTION_GAIN_THRESHOLD then
        local nicotineAdded = data.nicotineLevel - previousNicotineLevel
        local normalizedLevel = data.nicotineLevel / 100
        local thresholdFactor = math.max(0, (normalizedLevel - self.Options.ADDICTION_GAIN_THRESHOLD / 100) /
            (1 - self.Options.ADDICTION_GAIN_THRESHOLD / 100))
        local baseImpact = nicotineAdded * self.Options.INTAKE_CONVERSION
        local ADDICTION_GROWTH_CURVEImpact = nicotineAdded * 0.12 *
            thresholdFactor ^ self.Options.ADDICTION_GROWTH_CURVE.EXPONENT
        local earlyBoostMultiplier = 1.0
        if data.addictionLevel < 40 then
            earlyBoostMultiplier = 1.5
        end
        local totalAddiction = (baseAddiction + baseImpact + ADDICTION_GROWTH_CURVEImpact) * earlyBoostMultiplier
        data.addictionLevel = math.min(self.Options.ADDICTION_CAP, data.addictionLevel + totalAddiction)
    else
        data.addictionLevel = math.min(self.Options.ADDICTION_CAP, data.addictionLevel + (baseAddiction * 0.1))
    end
    local currentTime = getGameTime():getWorldAgeHours()
    data.lastIntakeTimestamp = currentTime
    data.lastUpdate = currentTime
end

function NicotineSystem:applyWithdrawalEffects(player, timeDelta)
    local data = player:getModData().nicotineSystem
    if not data then return end

    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    local timeSinceFactor = math.min(player:getTimeSinceLastSmoke() / 10, 0.8)
    local intensity = (((data.withdrawalLevel / 100) + timeSinceFactor) / 2)

    local maxStressPerUpdate = 0.002 * timeDelta
    local rawStressChange = intensity * self.Options.STRESS_BASE * timeDelta
    local stressChange = math.min(rawStressChange, maxStressPerUpdate)

    local unhappinessChange = intensity * self.Options.UNHAPPINESS_BASE * timeDelta
    local boredomChange = intensity * self.Options.BOREDOM_BASE * timeDelta

    data.stressChange = stressChange
    data.unhappinessChange = unhappinessChange
    data.boredomChange = boredomChange

    -- if stats:getStressFromCigarettes() >= 0.5 then
    --     local trueStress = stats:getStress() - stats:getStressFromCigarettes()
    --     if trueStress <= 1.0 then
    --         data.stressAccumulation = data.stressAccumulation + stressChange
    --         print('Stress Change: ' .. stressChange)
    --         stats:setStress(math.min(1.51, trueStress + stressChange))
    --     end
    -- end

    if data.boredomAccumulation < self.Options.BOREDOM_MAX then
        data.boredomAccumulation = data.boredomAccumulation + boredomChange
        bodyDamage:setBoredomLevel(math.min(100, bodyDamage:getBoredomLevel() + boredomChange))
    end

    if data.unhappinessAccumulation < self.Options.UNHAPPINESS_MAX then
        data.unhappinessAccumulation = data.unhappinessAccumulation + unhappinessChange
        bodyDamage:setUnhappynessLevel(math.min(100, bodyDamage:getUnhappynessLevel() + unhappinessChange))
    end

    if TrueSmoking.Config.WithdrawalText and player:HasTrait('Smoker') then
        local currentTime = getGameTime():getWorldAgeHours()
        if not data.lastWithdrawalMessage then data.lastWithdrawalMessage = 0 end
        local messageCooldown = self:calculateMessageCooldown(data.withdrawalLevel)
        data.messageCooldown = messageCooldown
        local timeSinceLastMessage = currentTime - data.lastWithdrawalMessage
        data.timeSinceLastMessage = timeSinceLastMessage
        if timeSinceLastMessage >= messageCooldown then
            local messageChance = 50
            if ZombRand(100) < messageChance then
                local symptomIndex = ZombRand(1, 10)
                player:Say(getText("UI_TRUESMOKING_WITHDRAWAL_SYMPTOM_" .. symptomIndex))
                data.lastWithdrawalMessage = currentTime
            end
        end
    end
end

function NicotineSystem:relieveWithdrawalEffects(player, timeDelta)
    local data = player:getModData().nicotineSystem
    if not data then return end

    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    local addiction = data.nicotineLevel > self.Options.SMOKER_TRAIT_THRESHOLD and self.Options.SMOKER_TRAIT_THRESHOLD or
        data.nicotineLevel
    local addictionFactor = addiction / self.Options.SMOKER_TRAIT_THRESHOLD
    local reliefFactor = (1.0 - (addictionFactor * 0.7))

    local stressChange = reliefFactor * self.Options.STRESS_BASE * timeDelta
    local unhappinessChange = reliefFactor * self.Options.UNHAPPINESS_BASE * timeDelta
    local boredomChange = reliefFactor * self.Options.BOREDOM_BASE * timeDelta
    data.stressChange = stressChange
    data.unhappinessChange = unhappinessChange
    data.boredomChange = boredomChange

    -- if data.stressAccumulation > 0 then
    --     data.stressAccumulation = math.max(0, data.stressAccumulation - stressChange)
    --     stats:setStress(math.max(0, stats:getStress() - stressChange))
    -- end

    if data.boredomAccumulation > 0 then
        data.boredomAccumulation = math.max(0, data.boredomAccumulation - boredomChange)
        bodyDamage:setBoredomLevel(math.max(0, bodyDamage:getBoredomLevel() - boredomChange))
    end

    if data.unhappinessAccumulation > 0 then
        data.unhappinessAccumulation = math.max(0, data.unhappinessAccumulation - unhappinessChange)
        bodyDamage:setUnhappynessLevel(math.min(100, bodyDamage:getUnhappynessLevel() - unhappinessChange))
    end

    data.lastWithdrawalMessage = getGameTime():getWorldAgeHours()
    data.timeToNextWithdrawal = self:calculateMessageCooldown(data.withdrawalLevel)
end

function NicotineSystem:manageSmokerTrait(player)
    local data = player:getModData().nicotineSystem
    if not data then return end
    if data.addictionLevel >= self.Options.SMOKER_TRAIT_THRESHOLD and not player:HasTrait("Smoker") then
        player:getTraits():add("Smoker")
        data.withdrawalLevel = 0
        player:getStats():setStressFromCigarettes(0)
        player:setTimeSinceLastSmoke(0)
        HaloTextHelper.addTextWithArrow(player, getText("UI_TRUESMOKING_BECAME_SMOKER"), true,
            HaloTextHelper.getColorRed())
    elseif data.addictionLevel <= self.Options.SMOKER_TRAIT_LOSE_THRESHOLD and player:HasTrait("Smoker") then
        player:getTraits():remove("Smoker")
        data.withdrawalLevel = 0
        player:getStats():setStressFromCigarettes(0)
        player:setTimeSinceLastSmoke(0)
        HaloTextHelper.addTextWithArrow(player, getText("UI_TRUESMOKING_QUIT_SMOKING"), true,
            HaloTextHelper.getColorGreen())
    end
end
