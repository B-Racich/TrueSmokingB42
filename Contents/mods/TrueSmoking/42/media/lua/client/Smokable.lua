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
    obj.burnMin, obj.burnMax = 0.000125, 0.000315

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
    if item:getModData().SmokeLength then obj.smokeLength = item:getModData().SmokeLength end

    -- print(string.format('Smokable length: %s, original: %s',obj.smokeLength, obj.originalSmokeLength))

    obj.smokePercent = obj.smokeLength/obj.originalSmokeLength
    obj.smokeLit = false
    obj.burnRate = ZombRandFloat(obj.burnMax*.75,obj.burnMax*1.15)
    obj.timeCheck = ZombRand(puffMin,puffMax)
    obj.hasRolledForDrop = false

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
    if not self.player:getWornItem('Mask_Smoke') and self.table.visualItem then
        self.player:setWornItem(self.table.visualItem:getBodyLocation(), self.table.visualItem);
    elseif self.player:getWornItem('Mask_Smoke') then
        self.player:removeWornItem(self.player:getWornItem('Mask_Smoke'))
        self:equipVisualItem()
    end
end

function Smokable:removeVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return end
    if self.player:getWornItem('Mask_Smoke') then
        self.player:removeWornItem(self.player:getWornItem('Mask_Smoke'))
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
        self.player:getInventory():Remove(self.item)
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

function Smokable:stop()
    self.table.isSmoking = false
    self.table.visualItem = false

    -- self.table.isSmoking = false
    self.table.takingPuff = false
    self.smokeLit = false
    self.hasDropped = false
    self.table.Moodle:stop()

    self:removeVisualItem()

    if self.updateWrapper then
        Events.OnTick.Remove(self.updateWrapper)
        self.updateWrapper = nil
    end

    TrueSmoking:checkForMaskAndEquip(self.player)

    if self.item then
        local onUse = self.replaceOnUse
        if onUse and onUse ~= '' and self.smokeLength <= 0 then
            addOnUseItem(self.player)
        end

        if(self.smokeLength > 0) then
            self.player:getInventory():AddItem(self.item)
            self.player:getModData().Smokable = false
        end

        self.item = false  --clear item for safety.
    end
end

function Smokable:checkDropSmoke()
    if not TrueSmoking.Options.Dropping then return end
    local ClimbFenceOutcome = self.player:GetVariable("ClimbFenceOutcome")
    local dropChance = self.player:HasTrait('Smoker') and TrueSmoking.Options.DroppingChanceSmoker or TrueSmoking.Options.DroppingChanceNonSmoker
    if not self.hasRolledForDrop and ClimbFenceOutcome == 'fall' then
        local roll = ZombRandFloat(0.0,100.0)
        self.hasRolledForDrop = true
        if dropChance >= roll then
            self.hasDropped = true
        end
    end

    if self.hasRolledForDrop and ClimbFenceOutcome ~= 'fall' then
        self.hasRolledForDrop = false
        if self.hasDropped then
            local dropX,dropY,dropZ = ISTransferAction.GetDropItemOffset(self.player, self.player:getCurrentSquare(), self.item)
            self.player:getCurrentSquare():AddWorldInventoryItem(self.item, dropX, dropY, dropZ)
            self.item = false
            self.player:getModData().Smokable = false
            self:stop()
        end
    end
end

-- Updates the burnRate and smokeLength on game tick, tracks when the smoke is out or finished
function Smokable:update()
    -- Checks if we are falling and dropped the smoke
    self:checkDropSmoke()
    -- If smoke is lit, update burnRate
    if self.smokeLit then
        -- Calculate game speed (unchanged from original)
        local gameSpeed = getGameSpeed() == 1 and 1 or
                          getGameSpeed() == 2 and 5 or
                          getGameSpeed() == 3 and 20 or
                          getGameSpeed() == 4 and 40

        -- Try to take idle puff before calculating burn changes (unchanged)
        self:idlePuff()

        local isMoving = self.player:isMoving()
        local isRunning = self.player:isRunning()
        local isSprinting = self.player:isSprinting()
        local isStrafing = self.player:isStrafing()
        local inVehicle = self.player:isSeatedInVehicle()

        -- Define target burn rate for active states only
        local targetBurnRate
        if self.table.takingPuff then
            targetBurnRate = self.burnMax * TrueSmoking.Options.PuffFactor
        elseif isSprinting then
            targetBurnRate = self.burnMin * TrueSmoking.Options.SprintingFactor
        elseif isRunning then
            targetBurnRate = self.burnMin * TrueSmoking.Options.RunningFactor
        -- Note: Walking condition is commented out in the original; omitted here
        -- elseif (isMoving) or isStrafing then
        --     targetBurnRate = self.burnMin * TrueSmoking.Options.WalkingFactor
        end

        if targetBurnRate then
            -- Smoothly adjust burnRate toward targetBurnRate for active states
            local adjustmentSpeed = 0.0025  -- Controls transition speed (tune this value)
            if self.burnRate > self.burnMax then
                adjustmentSpeed = adjustmentSpeed * 0.25  -- Slower adjustment beyond burnMax
            end
            self.burnRate = self.burnRate + (targetBurnRate - self.burnRate) * adjustmentSpeed * gameSpeed
        else
            -- Apply exponential decay when idling
            local decayFactor = 0.9988  -- Tune this for desired decay speed (e.g., ~5 minutes to extinguish)
            self.burnRate = self.burnRate * (decayFactor ^ gameSpeed)
        end

        -- Calculate how much % was smoked this tick (unchanged)
        self.puffPercent = self.burnRate / self.originalSmokeLength

        -- Update smoke length (unchanged)
        self.smokeLength = self.smokeLength - self.burnRate

        -- Update smoke % left (unchanged)
        self.smokePercent = self.smokeLength / self.originalSmokeLength

        -- Apply stat changes (unchanged)
        OnEat_OverTime(self)

        -- Update item mod data (unchanged)
        self.item:getModData().SmokeLength = self.smokeLength
        self.player:getModData().Smokable = {self.item:getFullType(), self.smokeLength}
    end

    -- print(string.format('Burn Rate: %.8f', self.burnRate))

    -- Smoke went out (burn rate is very low)
    if TrueSmoking.Options.SmokeRelighting and self.burnRate < 0.0000025 then
        self.burnRate = 0
        self.smokeLit = false
    elseif not TrueSmoking.Options.SmokeRelighting and self.burnRate < self.burnMin then
        self.burnRate = self.burnMin
    end

    -- Smoke is finished (smokeLength is 0)
    if self.smokeLength <= 0 then
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

