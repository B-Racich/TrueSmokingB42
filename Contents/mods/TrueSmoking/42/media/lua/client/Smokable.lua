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

    local data = self:getObject(item)

    for k, v in pairs(data) do
        obj[k] = v
    end

    obj.canDrop = obj.conditions and obj.conditions.canDrop or false

    obj.player = player

    obj.table = TrueSmoking:getPlayerReference(player)

    -- Get our instanceItem
    if obj.visualItem then
        obj.table.visualItem = instanceItem(obj.visualItem)
    else
        local hasVisualItem = self:getVisualItem(item)
        if hasVisualItem then
            obj.table.visualItem = hasVisualItem
        end
    end

    obj.item = item
    obj.onEat = item:getOnEat() or ''

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

    obj.replaceOnUse = item:getModData().replaceOnUse or ''
    print('Smokable Item ReplaceOnUse: '..obj.replaceOnUse)

    obj.smokePercent = obj.smokeLength / obj.originalSmokeLength
    obj.smokeLit = false
    obj.burnRate = ZombRandFloat(obj.burnMax * .75, obj.burnMax * 1.15)
    obj.timeCheck = ZombRand(puffMin, puffMax)
    obj.hasRolledForDrop = false

    return obj
end

function Smokable:getObject(item)
    local fullType = item:getFullType()
    print('Looking for: '..fullType)
    local ob = TrueSmoking.SmokableObjects[fullType]
    local o = {}
    if ob then
        print('Retrieved Smokable Object')
        o = deepCopy(ob)
    end

    -- If we have a object defined use it
    if not ob then
        print('Making Default Smokable Object')
        local onEat = item:getOnEat()
        local defaultCallback = (onEat == 'OnEat_Cigarettes' or onEat == 'OnEat_Cigarillo' or onEat == 'OnEat_Cigar') and OnEat_Tobacco or false
        local defaultSmokeLength = onEat == 'OnEat_Cigarettes' and TrueSmoking.Options.CigaretteLength or
            onEat == 'OnEat_Cigarillo' and TrueSmoking.Options.CigarilloLength or
            onEat == 'OnEat_Cigar' and TrueSmoking.Options.CigarLength or
            TrueSmoking.Options.SmokeLength
        o = {
            smokeLength = defaultSmokeLength,
            burnMin = 0.000125,
            burnMax = 0.000300,
            burnSpeed = 0.0025,
            burnSpeedDecay = 0.20,
            decayRate = 0.998,
            callback = defaultCallback,
            conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
            idleFactor = TrueSmoking.Options.IdleFactor,
            walkingFactor = TrueSmoking.Options.WalkingFactor,
            runningFactor = TrueSmoking.Options.RunningFactor,
            sprintingFactor = TrueSmoking.Options.SprintingFactor,
            puffFactor = TrueSmoking.Options.PuffFactor
        }
    end

    o.fullType = fullType
    o.smokeLength = TrueSmoking.Options.OverrideSmokeLength and TrueSmoking.Options.SmokeLength or o.smokeLength
    o.originalSmokeLength = o.smokeLength
    local savedSmoke = self:getSavedSmokeLength(item)
    o.smokeLength = savedSmoke and savedSmoke or o.smokeLength

    item:getModData().SmokeLength = o.smokeLength
    item:getModData().OriginalSmokeLength = o.originalSmokeLength

    local onEat = item:getOnEat()
    if not o.effectMultiplier then
        o.effectMultiplier = onEat == 'OnEat_Cigarettes' and 1.0 or
            onEat == 'OnEat_Cigarillo' and 2.0 or
            onEat == 'OnEat_Cigar' and 3.0 or
            0.0 --not a standard tobacco item
    end

    if not o.callback then
        if onEat == 'OnEat_Cigarettes' or
            onEat == 'OnEat_Cigarillo' or
            onEat == 'OnEat_Cigar'
        then
            o.callback = OnEat_OverTime
        end
    end

    print("=== Smoke Object Details ===")
    print('Smoke Length '..o.smokeLength)
    print('Original Smoke Length '..o.originalSmokeLength)
    print('Burn Min '..o.burnMin)
    print('Burn Max '..o.burnMax)
    print('Burn Speed '..o.burnSpeed)
    print('Burn Speed Decay '..o.burnSpeedDecay)
    print('Decay Rate '..o.decayRate)
    print("======================")

    return o
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

function Smokable:getSavedSmokeLength(item)
    local modData = item:getModData()
    if modData.SmokeLength then
        return modData.SmokeLength
    else
        return false
    end
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

function Smokable:getVisualItem(item)
    if not TrueSmoking.Options.ManageHeadGear then return false end

    local OnEat_Defaults = {
        ['OnEat_Cigarettes'] = 'Mask_Cigarette',
        ['OnEat_Cigarillo'] = 'Mask_Cigarillo',
        ['OnEat_Cigar'] = 'Mask_Cigar',
    }

    local typeMatches = {
        ['smokingpipe'] = 'Mask_Pipe',
        ['joint'] = 'Mask_Cigarette',
        ['blunt'] = 'Mask_Cigarillo',
        ['spliff'] = 'Mask_Cigarillo',
        ['can'] = false,
        ['bong'] = false,
    }

    local itemType = item:getFullType():lower()

    -- Then try partial match
    for pattern, itemName in pairs(typeMatches) do
        if itemType:find(pattern) then
            return itemName and instanceItem(itemName) or false
        end
    end

    --If we can find a default use that
    for key, value in pairs(OnEat_Defaults) do
        if item:getOnEat() == key then return instanceItem(value) end
    end

    -- If we found nothing do not display anything
    return false
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

        -- self.table.visualItem = self.visualItem
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
    -- if not self.table.isSmoking then return end
    self.table.isSmoking = false
    self.table.visualItem = false

    -- self.table.isSmoking = false
    self.table.takingPuff = false
    self.smokeLit = false
    self.hasDropped = false
    self.dropState = false
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
            print('adding item: '..self.replaceOnUse)
            addOnUseItem(self.player)
        end

        if self.smokeLength > 0 then
            self.player:getInventory():AddItem(self.item)
            self.player:getModData().Smokable = false
        end

        if self.smokeLength <= 0 then
            self.item:getModData().SmokeLength = 0
            self.player:getModData().Smokable = false
        end
    end
end

function Smokable:dropSmoke()
    self.hasRolledForDrop = false
    local dropX, dropY, dropZ = ISTransferAction.GetDropItemOffset(self.player, self.player:getCurrentSquare(), self
        .item)
    self.player:getCurrentSquare():AddWorldInventoryItem(self.item, dropX, dropY, dropZ)
    self.item = false
    self.player:getModData().Smokable = false
    self:stop()
end

function Smokable:checkDropConditions()
    local state = getPlayerState(self.player)
    local dropStates = { ['CollideWithWallState'] = true }

    local ClimbFenceOutcome = self.player:GetVariable("ClimbFenceOutcome")
    local bumpType = self.player:getBumpType()
    local bumpTypes = { ['left'] = true, ['right'] = true }

    local result = ClimbFenceOutcome == 'fall' or dropStates[state] or bumpTypes[bumpType] or false

    return result
end

-- Updates the burnRate and smokeLength on game tick, tracks when the smoke is out or finished
function Smokable:update()
    -- Checks if we are falling and dropped the smoke
    if TrueSmoking.Options.Dropping and self.canDrop then
        if not self.hasRolledForDrop and self:checkDropConditions() then
            self.hasRolledForDrop = true
            local roll = ZombRandFloat(0.0, 100.0)
            local dropChance = self.player:HasTrait('Smoker') and TrueSmoking.Options.DroppingChanceSmoker or
                TrueSmoking.Options.DroppingChanceNonSmoker
            -- print(string.format('rolled drop: %s -- %s', roll, dropChance))
            if dropChance >= roll then
                self.hasDropped = true
            end
        end
        if self.hasRolledForDrop and not self:checkDropConditions() then
            self.hasRolledForDrop = false
            if self.hasDropped then
                self.hasDropped = false
                self:dropSmoke()
            end
        end
    end
    -- If smoke is lit, update burnRate
    if self.smokeLit then
        -- Calculate game speed (unchanged from original)
        local gameSpeed = getGameSpeed() == 1 and 1 or
            getGameSpeed() == 2 and 5 or
            getGameSpeed() == 3 and 20 or
            getGameSpeed() == 4 and 40

        -- Try to take idle puff before calculating burn changes (unchanged)
        self:idlePuff()

        local isWalking = self.player:isWalking() and self.conditions['walking']
        local isRunning = self.player:isRunning() and self.conditions['running']
        local isSprinting = self.player:isSprinting() and self.conditions['sprinting']
        local isStrafing = self.player:isStrafing() and self.conditions['strafing']
        -- local inVehicle = self.player:isSeatedInVehicle()

        -- Define target burn rate for active states only
        local targetBurnRate
        if self.table.takingPuff then
            targetBurnRate = self.burnMax * self.puffFactor
        elseif isSprinting then
            targetBurnRate = self.burnMin * self.sprintingFactor
        elseif isRunning then
            targetBurnRate = self.burnMin * self.runningFactor
        elseif isWalking or isStrafing then
            targetBurnRate = self.burnMin * self.walkingFactor
        end

        if targetBurnRate then
            -- Smoothly adjust burnRate toward targetBurnRate for active states
            local adjustmentSpeed = self.burnSpeed
            local adjustmentSpeedDecay = self.burnSpeedDecay
            if self.burnRate > self.burnMax then
                adjustmentSpeed = adjustmentSpeed * adjustmentSpeedDecay -- Slower adjustment beyond burnMax
            end
            self.burnRate = self.burnRate + (targetBurnRate - self.burnRate) * adjustmentSpeed * gameSpeed
        else
            -- Apply exponential decay when idling
            local decayFactor = self
                .decayRate -- Tune this for desired decay speed (e.g., ~5 minutes to extinguish)
            self.burnRate = self.burnRate * (decayFactor ^ gameSpeed)
        end

        -- Calculate how much % was smoked this tick (unchanged)
        self.puffPercent = self.burnRate / self.originalSmokeLength

        -- Update smoke length (unchanged)
        self.smokeLength = self.smokeLength - self.burnRate

        -- Update smoke % left (unchanged)
        self.smokePercent = self.smokeLength / self.originalSmokeLength

        -- Apply stat changes from item
        OnEat_ItemStats(self)

        -- Item callback
        if self.callback then
            self.callback(self)
        end

        -- Mod callback
        for _, func in ipairs(TrueSmoking.Callbacks) do
            func(self)
        end

        -- print(string.format('Smoke Length: %f', self.smokeLength))
        -- print(string.format('Smoke Length Org: %f', self.originalSmokeLength))
        -- print(string.format('burnMin: %f', self.burnMin))
        -- print(string.format('burnMax: %f', self.burnMax))

        -- Update item mod data (unchanged)
        self.item:getModData().SmokeLength = self.smokeLength
        self.player:getModData().Smokable = { self.item:getFullType(), self.smokeLength }
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
        if TrueSmoking.Config.AutoPutOut then
            self:putOut()
        end
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
