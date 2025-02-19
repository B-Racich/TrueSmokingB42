require 'TimedActions/ISBaseTimedAction'
require 'Utils'

Smokable = Smokable or {}
Smokable.__index = Smokable

--[[
    Smokable class that creates our object from smokable items.

    The majority of the smoking logic is handled here, the update method runs onTick to calculate the burn rate and call the OnEat_OverTime
    method.

    The moodle is started/stopped here but stored in the TrueSmoking table reference

    visualItem is hardcoded to sync with the default smoking anim based on a timer
]]

--Create a new Smokable object from consumed item (ISEatFoodAction)
function Smokable:new(item, player)
    local obj = {}
    setmetatable(obj, self)

    local puffMin, puffMax = TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime
    obj.burnMin, obj.burnMax = 0.0000125, 0.000215

    obj.player = player

    obj.table = TrueSmoking:getPlayerReference(player)

    obj.item = item
    obj.onEat = item:getOnEat() or ''
    obj.replaceOnUse = item:getReplaceOnUse() or ''
    obj.fullType = item:getFullType() or ''

    obj.stress = item:getStressChange() or -5
    obj.originalStress = obj.stress

    obj.boredom = item:getBoredomChange() or 0
    obj.originalBoredom = obj.boredom

    obj.unhappyness = item:getUnhappyChange() or 0
    obj.originalUnhappyness = obj.unhappyness

    obj.fatigue = item:getFatigueChange() or 0
    obj.originalFatigue = obj.fatigue

    obj.thirst = item:getThirstChange() or 0
    obj.originalThirst = obj.thirst

    obj.hunger = item:getHungChange() or 0
    obj.originalHunger = obj.hunger

    obj.pain = item:getPainReduction() or 0
    obj.originalPain = obj.pain

    obj.endurance = item:getEnduranceChange() or 0
    obj.originalEndurance = obj.endurance

    obj.foodSick = self:getFoodSick(item)
    obj.originalFoodSick = obj.foodSick

    obj.reduceFoodSick = item:getReduceFoodSickness() or 0
    obj.originalReduceFoodSick = obj.reduceFoodSick

    obj.replaceOnUse = item:getReplaceOnUseFullType() or ''

    obj.smokeLength = self:getSmokeLength(item)
    obj.originalSmokeLength = obj.smokeLength
    item:getModData().OriginalSmokeLength = obj.smokeLength
    if item:getModData().SmokeLength then obj.smokeLength = item:getModData().SmokeLength print(item:getModData().SmokeLength)  end

    -- print(string.format('Smokable length: %s, original: %s',obj.smokeLength, obj.originalSmokeLength))

    obj.smokePercent = 1.0
    obj.smokeLit = false
    obj.burnRate = ZombRandFloat(obj.burnMin,obj.burnMax)
    obj.timeCheck = ZombRand(puffMin,puffMax)

    --NnC vals
    obj.NnC_StiffRemoval = 15
    obj.NnC_OriginalStiffRemoval = obj.NnC_StiffRemoval
    obj.NnC_PainThresh = 50
    obj.NnC_OriginalPainThresh = obj.NnC_PainThresh

    return obj
end

function Smokable:getFoodSick(item)
    local list = {
        ["OnEat_Cigarettes"] = 14,
        ["OnEat_Cigarillo"] = 21,
        ["OnEat_Cigar"] = 28,
        ['OnEat_WeedPipe'] = 8,
        ['OnEat_WeedJoint'] = 32
    }

    for name, val in pairs(list) do
        if item:getOnEat() == name then
            return val
        end
    end

    return 0
end

--Helper function to set smokeLengths
function Smokable:getSmokeLength(item)
    -- 1. If our override is set return that
    if TrueSmoking.Options.OverrideSmokeLength then return TrueSmoking.Options.SmokeLength end

    -- 2. If we have a value set return that
    for fullType, length in pairs(TrueSmoking.SmokeLengths) do
        if item:getFullType() == fullType then
            return length
        end
    end

    local OnEat_Defaults = {
        ['OnEat_Cigarettes'] = TrueSmoking.Options.CigaretteLength,
        ['OnEat_Cigarillo'] = TrueSmoking.Options.CigarilloLength,
        ['OnEat_Cigar'] = TrueSmoking.Options.CigarLength,
    }

    -- 3. If we can find a default use that
    for key, value in pairs(OnEat_Defaults) do
        if self.onEat == key then return value end
    end

    -- 4. Return our default value
    return TrueSmoking.Options.SmokeLength -- default smoke length
end

function Smokable:equipVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return end
    if not self.player:getWornItem('Mask') and self.table.visualItem then
        self.player:setWornItem(self.table.visualItem:getBodyLocation(), self.table.visualItem);
    elseif self.player:getWornItem('Mask') and TrueSmoking:isVisualItem(self.player:getWornItem('Mask')) then
        self.player:removeWornItem(self.player:getWornItem('Mask'))
        self:equipVisualItem()
    end
end

function Smokable:removeVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return end
    if self.table.visualItem and self.player:getWornItem('Mask') == self.table.visualItem then
        self.player:removeWornItem(self.table.visualItem)
    end
end

function Smokable:getVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return false end
    if self.item and not self.table.visualItem then
        for fullType, item in pairs(TrueSmoking.VisualItems) do
            -- print(string.format('item: %s - fullType: %s - item: %s',self.fullType, fullType, item))
            if self.fullType == fullType then
                return instanceItem(item)
            end
        end

        local OnEat_Defaults = {
            ['OnEat_Cigarettes'] = 'Mask_Cigarette',
            ['OnEat_Cigarillo'] = 'Mask_Cigarillo',
            ['OnEat_Cigar'] = 'Mask_Cigar',
        }

        --If we can find a default use that
        for key, value in pairs(OnEat_Defaults) do
            if self.onEat == key then return instanceItem(value) end
        end

        -- If we found nothing do not display anything
        return false
    end
end

--Start smoking and light the smokable
function Smokable:light()
    if not self.table.isSmoking then
        self.table.isSmoking = true
        self.table.Moodle:start()

        --Start the update event
        local function updateWrapper()
            self:update()
        end
        Events.OnTick.Add(updateWrapper)
        self.updateWrapper = updateWrapper

        self.table.visualItem = self:getVisualItem()
        self:equipVisualItem()
    end
    if not self.smokeLit then
        ISTimedActionQueue.add(LightSmoke:new(self.player))
    end
end

--Stop smoking and remove the update event
function Smokable:putOut()
    if self.table.isSmoking then
        ISTimedActionQueue.add(PutOut:new(self.player))
    end
end

--Updates the burnRate and smokeLength on game tick, tracks when the smoke is out or finished
function Smokable:update()
    --If smoke is lit update burnRate
    if self.smokeLit then
        local gameSpeed = getGameSpeed() == 1 and 1 or
        getGameSpeed() == 2 and 5 or
        getGameSpeed() == 3 and 20 or
        getGameSpeed() == 4 and 40

        --Try to take idle puff before calculate burn changes
        self:idlePuff()
        -- print(string.format('Smokable is lit - Burn Rate: %.6f', self.burnRate))
        if self.table.takingPuff then
            --change burn rate with puffFactor
            if self.burnRate < self.burnMin then
                self.burnRate = self.burnRate + self.burnRate * 0.01 * TrueSmoking.Options.PuffFactor * gameSpeed
            elseif self.burnRate < self.burnMax then
                self.burnRate = self.burnRate + self.burnRate * 0.001 * TrueSmoking.Options.PuffFactor * gameSpeed
            else
                self.burnRate = self.burnRate + self.burnRate * 0.00001 * TrueSmoking.Options.PuffFactor * gameSpeed
            end
        elseif self.player:isRunning() or self.player:isSprinting() then
            --change burn rate with runningFactor
            self.burnRate = self.burnRate - self.burnRate * 0.001 * TrueSmoking.Options.RunningFactor * gameSpeed
        else
            --change burn rate with idleFactor
            self.burnRate = self.burnRate - self.burnRate * 0.001 * gameSpeed
        end

        --How much % we smoked this tick
        self.puffPercent = self.burnRate / self.originalSmokeLength
        --Update Smoke Length
        self.smokeLength = self.smokeLength - self.burnRate
        --Update smoke % left
        self.smokePercent = self.smokeLength / self.originalSmokeLength
        --Apply stat changes
        OnEat_OverTime(self)
        self.item:getModData().SmokeLength = self.smokeLength
    end

    --Smoke went out (burn rate is 0)
    if TrueSmoking.Options.SmokeRelighting and self.burnRate < 0.0000001 then
        self.burnRate = 0
        self.smokeLit = false
    elseif not TrueSmoking.Options.SmokeRelighting and self.burnRate < self.burnMin then
        self.burnRate = self.burnMin
    end

    --Smoke is finished (smokeLength is 0)
    if self.smokeLength < 0 then
        self.smokeLength = 0
        self:putOut()
    end
end

--Manual puff action while smokeKey is held
function Smokable:puff()
    ISTimedActionQueue.add(TakePuff:new(self.player))
end

--Passive puff action triggered by PassiveSmoking
function Smokable:idlePuff()
    local timeDiff = os.difftime(os.time(), self.puffTimeMark)

    if TrueSmoking.Config.PassiveSmoking and timeDiff >= self.timeCheck then
        local puff = TakePuff:new(self.player)
        -- puff.maxTime = 220
        ISTimedActionQueue.add(puff)
    end
end

