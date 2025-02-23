function isInList(str, list)
    if str == "" then
        return false
    end
    local listString = table.concat(list, ",")
    return string.find(listString, str) ~= nil
end

function addOnUseItem(player)
    local trueSmoking = TrueSmoking:getPlayerReference(player)
    local type = trueSmoking.Smokable.item:getFullType()
    local item = trueSmoking.Smokable.replaceOnUse
    local base = type:match("^[^.]+")
    if base then
        local str = base..'.'..item
        if item and item ~= '' then
            -- print('add item')
            player:getInventory():AddItem(str)
        end
    end
end

function callModFunction(func)
    return function(item, player, percent)
        func(item, player, percent)
    end
end

function getStats()
    local o = {}

    local player = getPlayer()
    local stats, body = player:getStats(), player:getBodyDamage()

    o.stress = stats:getStress()
    o.stressFromCigarettes = stats:getStressFromCigarettes()
    o.timeSinceLastSmoke = player:getTimeSinceLastSmoke()
    o.unhappyness = body:getUnhappynessLevel()
    o.boredom = body:getBoredomLevel()
    o.foodSickness = body:getFoodSicknessLevel()

    return o
end

function setStats(o)
    local player = getPlayer()
    local stats, body = player:getStats(), player:getBodyDamage()

    stats:setStress(o.stress - stats:getStressFromCigarettes())
    stats:setStressFromCigarettes(o.stressFromCigarettes)
    player:setTimeSinceLastSmoke(o.timeSinceLastSmoke)
    body:setUnhappynessLevel(o.unhappyness)
    body:setBoredomLevel(o.boredom)
    body:setFoodSicknessLevel(o.foodSickness)
end

--Hooks onto the OnEat function to start the smokable event and lights the smokable
function OnEat_Hook(food, character, percent)
    --Deprecate this for now, we don't need to be calling the original code
    -- OnEat_Original(food, character, percent)
    local trueSmoking = TrueSmoking:getPlayerReference(character)
    local num = character:getPlayerNum()

    -- trueSmoking.Smokable:light()
end

--Modified OnEat function to cover Smokables and distribute stats over time
--Respects the vanilla logic and smoker trait
function OnEat_OverTime(smokable)
    -- local food = smokable.item
    local percent = smokable.puffPercent
    local character = smokable.player
    local body = character:getBodyDamage()
    local stats = character:getStats()
    local gameSpeed = getGameSpeed() == 1 and 1 or
        getGameSpeed() == 2 and 5 or
        getGameSpeed() == 3 and 20 or
        getGameSpeed() == 4 and 40

    --Multiplier for how much stats different smokables give (vanilla stats only)
    local onEat = smokable.onEat or 'OnEat_Cigarettes'
    local smokeTypeModifier =
        onEat == 'OnEat_Cigarettes' and 1.0 or
        onEat == 'OnEat_Cigarillo' and 2.0 or
        onEat == 'OnEat_Cigar' and 3.0 or
        1.0 -- default

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
        temp = 100 * percent * gameSpeed * smokeTypeModifier
        body:setUnhappynessLevel(adjustStat(body:getUnhappynessLevel(), temp, 'unhappy'))

        temp = 1 * percent * gameSpeed * smokeTypeModifier
        stats:setStress(adjustStat(stats:getStress()-stats:getStressFromCigarettes(), temp, 'stress'))

        temp = 0.51 * percent * gameSpeed * smokeTypeModifier
        stats:setStressFromCigarettes(adjustStat(stats:getStressFromCigarettes(), temp, 'cigs'))
        -- stats:setStressFromCigarettes(0)

        temp = 10 * percent * gameSpeed * smokeTypeModifier
        character:setTimeSinceLastSmoke(character:getTimeSinceLastSmoke() - temp)
    else --distribute stats for non smoker (stress and sickness)
        temp = smokable.originalStress * percent * gameSpeed
        stats:setStress(adjustStat(stats:getStress(), temp * smokeTypeModifier))
        smokable.stress = smokable.stress - temp

        --Set these to 0 anyways for safety.
        stats:setStressFromCigarettes(0)
        character:setTimeSinceLastSmoke(0)

        if smokable.stress > 0 then
            smokable.stress = 0
        end

        if smokable.foodSick ~= 0 then
            temp = smokable.originalFoodSick * percent * gameSpeed
            body:setFoodSicknessLevel(math.min(body:getFoodSicknessLevel() + temp * smokeTypeModifier, 100))
            smokable.foodSick = smokable.foodSick - temp
            if smokable.foodSick < 0 then
                smokable.foodSick = 0
            end
        end

        if smokable.unhappyness ~= 0 then
            temp = smokable.originalUnhappyness * percent * gameSpeed
            body:setUnhappynessLevel(adjustStat(body:getUnhappynessLevel(), temp * smokeTypeModifier, 'unhappy'))
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

    --NnC pain code
    if getActivatedMods():contains("\\N&CsNarcotics") then
        if smokable.item:getModData().modOnEat == "OnEat_WeedSmoke" then 
            if smokable.NnC_PainThresh ~= 0 or smokable.NnC_StiffRemoval ~= 0 then
                local stiffRemoval = smokable.NnC_OriginalStiffRemoval * percent * gameSpeed
                local painThresh = smokable.NnC_OriginalPainThresh * percent * gameSpeed
                local bodyDamage = character:getBodyDamage()
                local BodyPartsStiff = {BodyPartType.Head, BodyPartType.Neck, BodyPartType.Torso_Upper,
                                        BodyPartType.Torso_Lower, BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.UpperArm_R,
                                        BodyPartType.Hand_L, BodyPartType.ForeArm_L, BodyPartType.UpperArm_L, BodyPartType.Groin,
                                        BodyPartType.UpperLeg_L, BodyPartType.LowerLeg_L, BodyPartType.Foot_L, BodyPartType.UpperLeg_R,
                                        BodyPartType.LowerLeg_R, BodyPartType.Foot_R}
                for i=1, #BodyPartsStiff do
                    local bodyPart = bodyDamage:getBodyPart(BodyPartsStiff[i])
                    local stiffness = bodyPart:getStiffness()
                    local currentPain = bodyPart:getPain()
                    if stiffness and stiffness > stiffRemoval then
                        bodyPart:setStiffness(stiffness - stiffRemoval)
                    elseif stiffness and stiffness < stiffRemoval and stiffness > 0 then
                        bodyPart:setStiffness(0)
                        character:getFitness():removeStiffnessValue(BodyPartType.ToString(BodyPartsStiff[i]))
                    end
                    if currentPain >= 50 then
                        bodyPart:setAdditionalPain(currentPain - painThresh)
                    elseif currentPain < 50 then
                        bodyPart:setAdditionalPain(0);
                    end
                end
                smokable.NnC_StiffRemoval = smokable.NnC_StiffRemoval - stiffRemoval
                smokable.NnC_PainThresh = smokable.NnC_PainThresh - painThresh
            end
        end
    end
end

--Function to wrap and call original OnEat methods
--previous implementations used to record stat changes before and after calling the native function,
--record the stat changes, and apply them over time. The stat changes worked okay but it was a quick and dirty way to
--make it compatible with lots of mods that need to be calling their original functions. However things like ETW would simply
--mark the begininng of the smoke as having smoked the whole thing which was undesired.
function OnEat_Original(food, character, percent)
    -- local modOnEat = food:getModData().modOnEat or ''
    -- local tableName, funcName = modOnEat:match("([^%.]+)%.([^%.]+)")
    -- local modTable, functionToCall

    -- if tableName and funcName then
    --     modTable = _G[tableName]
    --     functionToCall = modTable and modTable[funcName]
    -- else
    --     functionToCall = _G[modOnEat]
    -- end

    -- TrueSmoking.statsBefore = getStats()

    -- if type(functionToCall) == "function" then
    --     print('Calling mod function: ' .. modOnEat)
    --     local modFunction = callModFunction(functionToCall)
    --     modFunction(food, character, percent)
    -- end

    -- TrueSmoking.statsAfter = getStats()

    -- setStats(TrueSmoking.statsBefore)
end