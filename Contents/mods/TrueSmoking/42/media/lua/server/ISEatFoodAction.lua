require 'TimedActions/ISEatFoodAction'

local originalActionNew = ISEatFoodAction.new
local originalActionIsValid = ISEatFoodAction.isValid

--[[
    This file hooks the foodAction and houses on custom OnEat methods, here the Smokable object is created and stored into
    the global TrueSmoking object.
]]

--Hook the ISEatFoodAction to grab smokable items and make our changes, stop the vanilla actions and call our own.
function ISEatFoodAction:new (character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local modOnEat = item:getModData().modOnEat or ''
    local name = item:getFullType() or ''
    local funcsToHook = {'OnEat_Cigarettes','OnEat_Cigarillo','OnEat_Cigar',
                            'OnEat_WeedSmoke','OnEat_WeedJoint','OnEat_WeedPipe'}
    local itemsToSkip = {}
    local hook = 'OnEat_Hook'

    if getActivatedMods():contains("\\B42Hemp&Tobacco") then
        local displayName = item:getDisplayName()
        local fixList = {
            ['Cheroot (Hemp)'] = 'OnEat_Cigarillo',
            ['Cigar (Hemp)'] = 'OnEat_Cigar'
        }

        if fixList[displayName] then
            onEat = fixList[displayName]
        end
    end

    --Store the original action to return it if we don't need to hook it
    o = originalActionNew(self, character, item, percentage)

    local trueSmoking
    local num = character:getPlayerNum()
    if num == 0 then
         trueSmoking = TrueSmoking.Player_1
    elseif num == 1 then
        trueSmoking = TrueSmoking.Player_2
    elseif num == 2 then
        trueSmoking = TrueSmoking.Player_3
    else
        trueSmoking = TrueSmoking.Player_4
    end
    o.trueSmoking = trueSmoking


    if isInList(onEat, funcsToHook) and not isInList(name, itemsToSkip) then
        print('Hooking: '..onEat..' -> '..hook)
        if not trueSmoking.isSmoking then trueSmoking.Smokable = Smokable:new(item, character) end
        -- print(item:getReplaceOnUse())
        -- print(name)
        item:setReplaceOnUse(nil) --nil this fields to avoid consuming the item 
        if modOnEat ~= hook then
            item:getModData().modOnEat = onEat
            item:setOnEat(hook)
        end

        --Stop stat changes from item use
        item:setStressChange(0)
        item:setBoredomChange(0)
        item:setUnhappyChange(0)
        item:setPainReduction(0)
        item:setHungChange(0)
        item:setThirstChange(0)
        item:setFatigueChange(0)
        item:setEnduranceChange(0)
        item:setReduceFoodSickness(0)

        o.item = item
        o.maxTime = 50; --Shorten time to mimic 'lightng' the smokable
    end

    return o
end

function ISEatFoodAction:isValid()
    if self.item:getOnEat() == nil or self.item:getOnEat() == '' then
        return originalActionIsValid(self)
    else
        return not self.trueSmoking.isSmoking
    end
end

--Hooks onto the OnEat function to start the smokable event and lights the smokable
function OnEat_Hook(food, character, percent)
    --Deprecate this for now, we don't need to be calling the original code
    -- OnEat_Original(food, character, percent)
    local trueSmoking
    local num = character:getPlayerNum()
    if num == 0 then
         trueSmoking = TrueSmoking.Player_1
    elseif num == 1 then
        trueSmoking = TrueSmoking.Player_2
    elseif num == 2 then
        trueSmoking = TrueSmoking.Player_3
    else
        trueSmoking = TrueSmoking.Player_4
    end

    trueSmoking.Smokable:light()
end

--Modified OnEat function to cover Smokables and distribute stats over time
--Respects the vanilla logic and smoker trait
function OnEat_OverTime(smokable)
    -- local food = smokable.item
    local percent = smokable.puffPercent
    local character = smokable.player
    local body = character:getBodyDamage()
    local stats = character:getStats()

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
        temp = 100 * percent
        body:setUnhappynessLevel(adjustStat(body:getUnhappynessLevel(), temp, 'unhappy'))

        temp = 1 * percent
        stats:setStress(adjustStat(stats:getStress()-stats:getStressFromCigarettes(), percent, 'stress'))

        temp = 0.51 * percent
        stats:setStressFromCigarettes(adjustStat(stats:getStressFromCigarettes(), temp, 'cigs'))
        -- stats:setStressFromCigarettes(0)

        temp = 10 * percent
        character:setTimeSinceLastSmoke(character:getTimeSinceLastSmoke() - percent * 10)
    else --distribute stats for non smoker (stress and sickness)
        temp = smokable.originalStress * percent
        stats:setStress(adjustStat(stats:getStress(), temp))
        smokable.stress = smokable.stress - temp

        --Set these to 0 anyways for safety.
        stats:setStressFromCigarettes(0)
        character:setTimeSinceLastSmoke(0)

        if smokable.stress > 0 then
            smokable.stress = 0
        end

        if smokable.foodSick ~= 0 then
            temp = smokable.originalFoodSick * percent
            body:setFoodSicknessLevel(math.min(body:getFoodSicknessLevel() + temp, 100))
            smokable.foodSick = smokable.foodSick - temp
            if smokable.foodSick < 0 then
                smokable.foodSick = 0
            end
        end

        if smokable.unhappyness ~= 0 then
            temp = smokable.originalUnhappyness * percent
            body:setUnhappynessLevel(adjustStat(body:getUnhappynessLevel(), temp, 'unhappy'))
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
        temp = smokable.originalBoredom * percent
        body:setBoredomLevel(adjustStat(body:getBoredomLevel(), temp - ZomboidGlobals.BoredomIncrease, 'boredom'))
        smokable.boredom = smokable.boredom - temp
        -- print(string.format("Smokable boredom: %s | temp: %s", smokable.boredom, temp))
        if smokable.boredom > 0 then
            smokable.boredom = 0
        end
    end

    --Handles hunger
    if smokable.hunger ~= 0 then
        temp = smokable.originalHunger * percent
        stats:setHunger(adjustStat(stats:getHunger(), temp, 'hunger', true))
        smokable.hunger = smokable.hunger - temp
        if smokable.hunger < 0 then
            smokable.hunger = 0
        end
    end

    --Handles thirst
    if smokable.thirst ~= 0 then
        temp = smokable.originalThirst * percent
        stats:setThirst(adjustStat(stats:getThirst(), temp, 'thirst', true))
        smokable.thirst = smokable.thirst - temp
        if smokable.thirst < 0 then
            smokable.thirst = 0
        end
    end

    --Handles pain
    if smokable.pain ~= 0 then
        temp = smokable.originalPain * percent
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
        temp = smokable.originalEndurance * percent
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
        temp = smokable.originalFatigue * percent
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
        temp = smokable.originalReduceFoodSick * percent
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
                local stiffRemoval = smokable.NnC_OriginalStiffRemoval * percent
                local painThresh = smokable.NnC_OriginalPainThresh * percent
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
                        bodyPart:setAdditionalPain(currentPain - painThresh*percent)
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