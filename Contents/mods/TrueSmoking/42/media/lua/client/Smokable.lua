require 'TimedActions/ISBaseTimedAction'
require 'Utils'

Smokable = Smokable or {}
Smokable.__index = Smokable

function Smokable:new(item, player)
    local obj = {}
    setmetatable(obj, self)
    obj:init(item, player)
    return obj
end

function Smokable:init(item, player)
    self.player = player
    self.table = TrueSmoking:getPlayerReference(player)

    local data = self:getObject(item)
    for k, v in pairs(data) do
        self[k] = v
    end

    self.canDrop = self.conditions and self.conditions.canDrop or false

    if self.visualItem then
        self.table.visualItem = instanceItem(self.visualItem)
    else
        local hasVisualItem = self:getVisualItem(item)
        if hasVisualItem then
            self.table.visualItem = hasVisualItem
        end
    end

    self.item = item
    self.onEat = item:getOnEat() or false

    local stats = self:getItemStats(item)
    stats.foodSick = data.foodSick or 0
    for k, v in pairs(stats) do
        self[k] = v
        local originalKey = 'original' .. k:sub(1, 1):upper() .. k:sub(2)
        self[originalKey] = v
    end

    self.replaceOnUse = item:getModData().replaceOnUse or false

    self.smokePercent = self.smokeLength / self.originalSmokeLength
    self.smokeLit = false
    self.puffPercent = 0.0
    self.burnRate = ZombRandFloat(self.burnMax * 0.75, self.burnMax * 1.15)
    self.timeCheck = ZombRand(TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime)
    self.hasRolledForDrop = false
end

function Smokable:getItemStats(item)
    return {
        stress = item:getStressChange() or -5,
        boredom = item:getBoredomChange() or 0,
        unhappyness = item:getUnhappyChange() or 0,
        fatigue = item:getFatigueChange() or 0,
        thirst = item:getThirstChange() or 0,
        hunger = item:getHungChange() or 0,
        pain = item:getPainReduction() or 0,
        endurance = item:getEnduranceChange() or 0,
        reduceFoodSick = item:getReduceFoodSickness() or 0,
    }
end

function Smokable:getObject(item)
    local fullType = item:getFullType()
    print('TRUESMOKING::Looking for: ' .. fullType)
    local ob = TrueSmoking.SmokableObjects[fullType]
    local o = {}

    if ob then
        print('TRUESMOKING::Retrieved Smokable Object')
        o = deepCopy(ob)
    end

    local onEat = item:getOnEat()
    local defaults = {
        ['OnEat_Cigarettes'] = {
            smokeLength = TrueSmoking.Options.CigaretteLength,
            foodSick = 14,
            nicotineContent = 40,
            effectMultiplier = 1.0,
            callback = OnEat_Tobacco,
            visualItem = 'Mask_Cigarette'
        },

        ['OnEat_Cigarillo'] = {
            smokeLength = TrueSmoking.Options.CigarilloLength,
            foodSick = 21,
            nicotineContent = 60,
            effectMultiplier = 2.0,
            callback = OnEat_Tobacco,
            visualItem = 'Mask_Cigarillo'
        },

        ['OnEat_Cigar'] = {
            smokeLength = TrueSmoking.Options.CigarLength,
            foodSick = 28,
            nicotineContent = 100,
            effectMultiplier = 3.0,
            callback = OnEat_Tobacco,
            visualItem = 'Mask_Cigar'
        },
    }
    local default = {
        smokeLength = defaults[onEat] and defaults[onEat].smokeLength or TrueSmoking.Options.SmokeLength,
        burnMin = 0.000125,
        burnMax = 0.000300,
        burnSpeed = 0.0025,
        burnSpeedDecay = 0.20,
        decayRate = 0.998,
        callback = defaults[onEat] and defaults[onEat].callback or false,
        conditions = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
        walkingFactor = 1.0,
        runningFactor = 1.15,
        sprintingFactor = 1.35,
        puffFactor = 1.35,
        effectMultiplier = defaults[onEat] and defaults[onEat].effectMultiplier or 0.0,
        nicotineContent = defaults[onEat] and defaults[onEat].nicotineContent or 0.0,
        visualItem = defaults[onEat] and defaults[onEat].visualItem or false,
    }

    for key, value in pairs(default) do
        if o[key] == nil then
            o[key] = value
        end
    end

    o.fullType = fullType
    o.smokeLength = TrueSmoking.Options.OverrideSmokeLength and TrueSmoking.Options.SmokeLength or o.smokeLength
    o.originalSmokeLength = o.smokeLength
    local savedSmoke = self:getSavedSmokeLength(item)
    o.smokeLength = savedSmoke and savedSmoke or o.smokeLength

    if getActivatedMods():contains('\\SmokingSoundsOverhaul') then
        o.puffFactor = o.puffFactor / 2
    end

    item:getModData().SmokeLength = o.smokeLength
    item:getModData().OriginalSmokeLength = o.originalSmokeLength

    return o
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
        self.player:setWornItem(self.table.visualItem:getBodyLocation(), self.table.visualItem)
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

    for pattern, itemName in pairs(typeMatches) do
        if itemType:find(pattern) then
            return itemName and instanceItem(itemName) or false
        end
    end

    for key, value in pairs(OnEat_Defaults) do
        if item:getOnEat() == key then return instanceItem(value) end
    end

    return false
end

function Smokable:light()
    if not ISTimedActionQueue.hasActionType(self.player, 'LightSmoke') then
        ISTimedActionQueue.add(LightSmoke:new(self.player))
    end
end

function Smokable:start()
    if not self.table.isSmoking then
        self.table.isSmoking = true
        if not TrueSmoking.Config.HideMoodles then
            self.table.SmokingMoodle:start()
        end
        local function updateWrapper()
            self:update()
        end
        Events.OnPlayerUpdate.Add(updateWrapper)
        self.updateWrapper = updateWrapper
        self:equipVisualItem()
        self.player:getInventory():Remove(self.item)
    end

    if not self.smokeLit then
        self.smokeLit = true
        self.puffTimeMark = os.time()
        self.table.lightingEatSound = ''

        if self.burnRate == 0 then
            self.burnRate = ZombRandFloat(self.burnMin,
                self.burnMax)
        end
    end
end

function Smokable:putOut()
    if self.table.isSmoking and not ISTimedActionQueue.hasActionType(self.player, 'PutOut') then
        ISTimedActionQueue.add(PutOut:new(self.player))
    end
end

function Smokable:stop()
    self.table.isSmoking = false
    self.table.visualItem = false
    self.table.takingPuff = false
    self.smokeLit = false
    self.hasDropped = false
    self.dropState = false

    if not TrueSmoking.Config.HideMoodles then
        self.table.SmokingMoodle:stop()
    end

    self:removeVisualItem()

    if self.updateWrapper then
        Events.OnPlayerUpdate.Remove(self.updateWrapper)
        self.updateWrapper = nil
    end

    TrueSmoking:checkForMaskAndEquip(self.player)

    if self.item then
        local onUse = self.replaceOnUse
        if onUse and onUse ~= '' and self.smokeLength <= 0 then
            print('TRUESMOKING::adding item: ' .. self.replaceOnUse)
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

function Smokable:update()
    if TrueSmoking.Options.Dropping and self.canDrop then
        if not self.hasRolledForDrop and self:checkDropConditions() then
            self.hasRolledForDrop = true
            local roll = ZombRandFloat(0.0, 100.0)
            local dropChance = self.player:HasTrait('Smoker') and TrueSmoking.Options.DroppingChanceSmoker or
                TrueSmoking.Options.DroppingChanceNonSmoker
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
    if self.smokeLit then
        local gameSpeed = getGameSpeedMultiplier()
        local isWalking = self.player:isWalking() and self.conditions['walking']
        local isRunning = self.player:isRunning() and self.conditions['running']
        local isSprinting = self.player:isSprinting() and self.conditions['sprinting']
        local isStrafing = self.player:isStrafing() and self.conditions['strafing']

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
            local adjustmentSpeed = self.burnSpeed
            local adjustmentSpeedDecay = self.burnSpeedDecay
            if self.burnRate > self.burnMax then
                adjustmentSpeed = adjustmentSpeed * adjustmentSpeedDecay
            end
            self.burnRate = self.burnRate + (targetBurnRate - self.burnRate) * adjustmentSpeed * gameSpeed
        else
            local decayFactor = self.decayRate
            self.burnRate = self.burnRate * (decayFactor ^ gameSpeed)
        end

        self.puffPercent = self.burnRate * gameSpeed / self.originalSmokeLength
        self.smokeLength = self.smokeLength - self.burnRate * gameSpeed
        self.smokePercent = self.smokeLength / self.originalSmokeLength

        OnEat_ItemStats(self)

        if TrueSmoking.Options.UseNicotineSystem and self.puffPercent > 0 and self.nicotineContent then
            local nicotineAmount = self.nicotineContent * self.puffPercent
            NicotineSystem:addNicotine(self.player, nicotineAmount)
        end

        if self.callback then
            self.callback(self)
        end

        for _, func in ipairs(TrueSmoking.Callbacks) do
            func(self)
        end

        self.item:getModData().SmokeLength = self.smokeLength
        self.player:getModData().Smokable = { self.item:getFullType(), self.smokeLength }
    end

    if TrueSmoking.Options.SmokeRelighting and self.burnRate < 0.0000025 then
        self.burnRate = 0
        self.smokeLit = false
    elseif not TrueSmoking.Options.SmokeRelighting and self.burnRate < self.burnMin then
        self.burnRate = self.burnMin
    end

    if self.smokeLength <= 0 then
        self.smokeLength = 0
        if TrueSmoking.Config.AutoPutOut then
            self:putOut()
        end
    else
        self:idlePuff()
    end
end

function Smokable:puff()
    if not ISTimedActionQueue.hasActionType(self.player, 'TakePuff') then
        ISTimedActionQueue.add(TakePuff:new(self.player))
    end
end

function Smokable:idlePuff()
    local timeDiff = os.difftime(os.time(), self.puffTimeMark)
    if (TrueSmoking.Config.PassiveSmoking and timeDiff >= self.timeCheck) or (TrueSmoking.Config.KeepLit and self.burnRate < 0.00001 and self.smokeLit) then
        self:puff()
    end
end
