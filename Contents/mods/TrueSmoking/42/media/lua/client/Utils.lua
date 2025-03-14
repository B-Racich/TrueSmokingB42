function getPlayerState(player)
    local PlayerState = tostring(player:getCurrentState())
    local state = string.match(PlayerState, '([^%.]+)@')
    -- print(string.format('Character State: %s',state))
    return state or false
end

function isInList(str, list)
    if str == "" then
        return false
    end
    local listString = table.concat(list, ",")
    return string.find(listString, str) ~= nil
end

function addOnUseItem(player)
    local trueSmoking = TrueSmoking:getPlayerReference(player)
    local type = trueSmoking.Smokable.fullType
    local item = trueSmoking.Smokable.replaceOnUse
    local base = type:match("^[^.]+")
    if base then
        local str = base..'.'..item
        if item and item ~= '' then
            print('add item: '..str)
            player:getInventory():AddItem(str)
        end
    end
end

--Modified OnEat function to cover Smokables and distribute stats over time
function OnEat_OverTime(smokable)
    local percent = smokable.puffPercent
    local character = smokable.player
    local body = character:getBodyDamage()
    local stats = character:getStats()
    local gameSpeed = getGameSpeed() == 1 and 1 or
        getGameSpeed() == 2 and 5 or
        getGameSpeed() == 3 and 20 or
        getGameSpeed() == 4 and 40

    --Multiplier for how much stats different smokables give (vanilla stats only)
    local effectMultiplier = smokable.effectMultiplier

    local function adjustStat(stat, value, name, add)
        local name = name or 'nil'
        local newStat = stat - math.abs(value)
        -- print(string.format("Name: %s | Stat: %s | Value: %s | New Value: %s", name, stat, value, newStat))
        if newStat < 0 then
            newStat = 0
        end

        if add then newStat = stat + value end

        return newStat
    end

    local temp  --Store temp values for calculations

    --===Vanilla logic starts here

    --Mimic vanilla logic for smoker which essentially 0's these stats
    if character:HasTrait("Smoker") then
        temp = 100 * percent * gameSpeed * effectMultiplier
        body:setUnhappynessLevel(adjustStat(body:getUnhappynessLevel(), temp, 'unhappy'))

        temp = 1 * percent * gameSpeed * effectMultiplier
        stats:setStress(adjustStat(stats:getStress()-stats:getStressFromCigarettes(), temp, 'stress'))

        temp = 0.51 * percent * gameSpeed * effectMultiplier
        stats:setStressFromCigarettes(adjustStat(stats:getStressFromCigarettes(), temp, 'cigs'))
        -- stats:setStressFromCigarettes(0)

        temp = 10 * percent * gameSpeed * effectMultiplier
        character:setTimeSinceLastSmoke(character:getTimeSinceLastSmoke() - temp)
    else --distribute stats for non smoker (stress and sickness)
        temp = smokable.originalStress * percent * gameSpeed
        stats:setStress(adjustStat(stats:getStress(), temp * effectMultiplier))
        smokable.stress = smokable.stress - temp

        --Set these to 0 anyways for safety.
        stats:setStressFromCigarettes(0)
        character:setTimeSinceLastSmoke(0)

        if smokable.stress > 0 then
            smokable.stress = 0
        end

        if smokable.foodSick ~= 0 then
            temp = smokable.originalFoodSick * percent * gameSpeed
            body:setFoodSicknessLevel(math.min(body:getFoodSicknessLevel() + temp * effectMultiplier, 100))
            smokable.foodSick = smokable.foodSick - temp
            if smokable.foodSick < 0 then
                smokable.foodSick = 0
            end
        end

        if smokable.unhappyness ~= 0 then
            temp = smokable.originalUnhappyness * percent * gameSpeed
            body:setUnhappynessLevel(adjustStat(body:getUnhappynessLevel(), temp * effectMultiplier, 'unhappy'))
            smokable.unhappyness = smokable.unhappyness - temp
            -- print(string.format("Smokable unhappyness: %s | temp: %s", smokable.unhappyness, temp))
            if smokable.unhappyness > 0 then
                smokable.unhappyness = 0
            end
        end
    end

    --===Vanilla logic ends here===

    --===Check for item stats and start applying===

    --If smokable has boredom or unhappyness distribute them (these are applied in vanilla outside of OnEat, but we 0'd them earlier.)
    if smokable.boredom ~= 0 then
        temp = smokable.originalBoredom * percent * gameSpeed
        body:setBoredomLevel(adjustStat(body:getBoredomLevel(), temp - ZomboidGlobals.BoredomIncrease, 'boredom'))
        smokable.boredom = smokable.boredom - temp
        -- print(string.format("Smokable boredom: %s | temp: %s", smokable.boredom, temp))
        if smokable.boredom > 0 then
            smokable.boredom = 0
        end
    end

    --Handles hunger
    if smokable.hunger ~= 0 then
        temp = smokable.originalHunger * percent * gameSpeed
        stats:setHunger(adjustStat(stats:getHunger(), temp, 'hunger', true))
        smokable.hunger = smokable.hunger - temp
        if smokable.hunger < 0 then
            smokable.hunger = 0
        end
    end

    --Handles thirst
    if smokable.thirst ~= 0 then
        temp = smokable.originalThirst * percent * gameSpeed
        stats:setThirst(adjustStat(stats:getThirst(), temp, 'thirst', true))
        smokable.thirst = smokable.thirst - temp
        if smokable.thirst < 0 then
            smokable.thirst = 0
        end
    end

    --Handles pain
    if smokable.pain ~= 0 then
        temp = smokable.originalPain * percent * gameSpeed
        stats:setPain(adjustStat(stats:getPain(), temp, 'pain'))
        smokable.pain = smokable.pain - temp
        if smokable.pain < 0 then
            smokable.pain = 0
        end
    end

    --Handles endurance
    if smokable.endurance ~= 0 then
        local add = false;
        if smokable.endurance > 0 then add = true end
        temp = smokable.originalEndurance * percent * gameSpeed
        stats:setEndurance(adjustStat(stats:getEndurance(), temp, 'endurance'))
        smokable.endurance = smokable.endurance - temp
        if add and smokable.endurance < 0 then
            smokable.endurance = 0
        elseif not add and smokable.endurance > 0 then
            smokable.endurance = 0
        end
    end

    --Handles endurance
    if smokable.fatigue ~= 0 then
        local add = false;
        if smokable.fatigue > 0 then add = true end
        temp = smokable.originalFatigue * percent * gameSpeed
        stats:setFatigue(adjustStat(stats:getFatigue(), temp, 'fatigue', add))
        smokable.fatigue = smokable.fatigue - temp
        if add and smokable.fatigue < 0 then
            smokable.fatigue = 0
        elseif not add and smokable.fatigue > 0 then
            smokable.fatigue = 0
        end
    end

    --Handles reduceFoodSickness
    if smokable.reduceFoodSick ~= 0 then
        temp = smokable.originalReduceFoodSick * percent * gameSpeed
        body:setFoodSicknessLevel(math.min(body:getFoodSicknessLevel() - temp, 100))
        smokable.reduceFoodSick = smokable.reduceFoodSick - temp
        if smokable.reduceFoodSick < 0 then
            smokable.reduceFoodSick = 0
        end
    end
end