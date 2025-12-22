require 'TimedActions/ISBaseTimedAction'
require 'TrueSmoking'

TrueSmoking = TrueSmoking or {}

Smokable = Smokable or {}
Smokable.__index = Smokable

local tsDebug = TrueSmoking.tsDebug

function Smokable:new(player, item)
    local obj = {}
    setmetatable(obj, self)
    obj:init(item, player)
    return obj
end

function Smokable:init(item, player)
    self.item = instanceItem(item:getFullType())
    self.itemFullType = item:getFullType()
    self.customEatSound = item:getCustomEatSound() or ''

    if instanceof(item, 'Drainable') then
        self.item = instanceItem('Base.CigaretteSingle')
        self.cigPack = item
    end

    self.player = player

    local data = self:getObject(self.item)
    for k, v in pairs(data) do
        self[k] = v
    end

    self.canDrop = self.conditions and self.conditions.canDrop or false

    print('TRUESMOKING::Custom Eat Sound' .. tostring(self.item:getCustomEatSound() or ''))
    self.onEat = self.item:getOnEat() or false

    local stats = self:getItemStats(self.item)
    stats.foodSick = data.foodSick or 0
    for k, v in pairs(stats) do
        self[k] = v
        local originalKey = 'original' .. k:sub(1, 1):upper() .. k:sub(2)
        self[originalKey] = v
    end

    self.replaceOnUse = self.item:getModData().replaceOnUse or false

    self.smokePercent = self.smokeLength / self.originalSmokeLength
    self.smokeLit = false
    self.puffPercent = 0.0
    self.burnRate = ZombRandFloat(self.burnMax * 0.75, self.burnMax * 1.15)
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
        reduceFoodSick = item:getFoodSicknessChange() or 0,
    }
end

function Smokable:getStats()
    return {
        stress = self.stress,
        boredom = self.boredom,
        unhappyness = self.unhappyness,
        fatigue = self.fatigue,
        thirst = self.thirst,
        hunger = self.hunger,
        pain = self.pain,
        endurance = self.endurance,
        reduceFoodSick = self.reduceFoodSick,
        originalStress = self.originalStress,
        originalBoredom = self.originalBoredom,
        originalUnhappyness = self.originalUnhappyness,
        originalFatigue = self.originalFatigue,
        originalThirst = self.originalThirst,
        originalHunger = self.originalHunger,
        originalPain = self.originalPain,
        originalEndurance = self.originalEndurance,
        originalReduceFoodSick = self.originalReduceFoodSick,

        effectMultiplier = self.effectMultiplier,
        puffPercent = self.puffPercent,
        smokeLit = self.smokeLit,
    }
end

function Smokable:getObject(item)
    local fullType = item:getFullType()
    print('TRUESMOKING::Looking for: ' .. fullType)

    local ob = TrueSmoking.SmokableObjects[fullType]
    local o = ob and TrueSmoking.deepCopy(ob) or {}

    local g = TrueSmoking.Options.Global
    local cat = TrueSmoking.Options.Category

    -- Determine base smoke length (from SmokableObjects or global fallback)
    local baseLength = o.smokeLength or TrueSmoking.Options.SmokeLength

    -- Determine category burn multiplier
    local categoryMult = cat.Cigarette -- default
    if fullType:find('Cigar$') and not fullType:find('Cigarillo') then
        categoryMult = cat.Cigar
    elseif fullType:find('Cigarillo') then
        categoryMult = cat.Cigarillo
    elseif fullType:find('Pipe') or fullType:find('CanPipe') then
        categoryMult = cat.Pipe
    elseif fullType:find('Can') then
        categoryMult = cat.Can
    elseif fullType:find('Rolled') then
        categoryMult = cat.Rolled
    end

    -- Final defaults (only applied if not set by modder or recipe)
    local defaults = {
        smokeLength      = baseLength,
        burnMin          = g.burnMin * categoryMult,
        burnMax          = g.burnMax * categoryMult,
        burnSpeed        = g.burnSpeed,
        burnSpeedDecay   = g.burnSpeedDecay,
        decayRate        = g.decayRate,
        puffFactor       = g.puffFactor,
        walkingFactor    = g.walkingFactor,
        runningFactor    = g.runningFactor,
        sprintingFactor  = g.sprintingFactor,
        effectMultiplier = 1,
        nicotineContent  = 100,
        conditions       = { idle = true, walking = true, running = true, sprinting = true, strafing = true, canDrop = true },
        visualItem       = 'Mask_Cigarette',
        callback         = false,
    }

    -- Apply defaults only where missing
    for k, v in pairs(defaults) do
        if o[k] == nil then
            o[k] = v
        end
    end

    -- Final setup
    o.fullType = fullType

    o.originalSmokeLength = o.smokeLength

    -- Load saved progress from modData (partially smoked cigs)
    local savedSmoke = self:getSavedSmokeLength(item)
    if savedSmoke then
        o.smokeLength = savedSmoke
    end

    -- Compatibility with SmokingSoundsOverhaul (halves puff burn to prevent double-puff bug)
    if getActivatedMods():contains('\\SmokingSoundsOverhaul') then
        o.puffFactor = o.puffFactor / 2
    end

    -- Save to item modData for persistence
    local modData = item:getModData()
    modData.SmokeLength = o.smokeLength
    modData.OriginalSmokeLength = o.originalSmokeLength

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

function Smokable:equipVisualItem(player, item)
    local visual = Smokable:getVisualItem(item)
    if not visual then
        tsDebug('TrueSmoking::No visual item found')
        return
    end
    if not TrueSmoking.Options.ManageHeadGear then return end
    if not player:getWornItem(TrueSmoking.registries.mask) and instanceItem(visual) then
        player:setWornItem(instanceItem(visual):getBodyLocation(), instanceItem(visual))
        -- triggerEvent('OnClothingUpdated', player)
    elseif player:getWornItem(TrueSmoking.registries.mask) then
        player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
        Smokable:equipVisualItem(player, item)
    end
end

function Smokable:removeVisualItem(player)
    if not TrueSmoking.Options.ManageHeadGear then return end
    if player:getWornItem(TrueSmoking.registries.mask) then
        player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
        -- triggerEvent('OnClothingUpdated',player)
    end
end

function Smokable:getVisualItem(item)
    if not TrueSmoking.Options.ManageHeadGear then
        tsDebug('TrueSmoking::Not manage headgear')
        return false
    end

    local OnEat_Defaults = {
        ['RecipeCodeOnEat.consumeNicotine'] = 'Base.Mask_Cigarette',
    }

    local typeMatches = {
        ['smokingpipe'] = 'Base.Mask_Pipe',
        ['joint'] = 'Base.Mask_Cigarette',
        ['blunt'] = 'Base.Mask_Cigarillo',
        ['spliff'] = 'Base.Mask_Cigarillo',
        ['can'] = false,
        ['bong'] = false,
    }

    local itemType = item:getFullType():lower()
    tsDebug('Looking for ' .. itemType)

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
    if not self.smokeLit then
        self.smokeLit = true
        self.lightingEatSound = ''

        if self.burnRate == 0 then
            self.burnRate = ZombRandFloat(self.burnMin,
                self.burnMax)
        end
    end
    if not ISTimedActionQueue.hasActionType(self.player, 'LightSmoke') then
        ISTimedActionQueue.add(LightSmoke:new(self.player))
    end
end

function Smokable:start(player, item)
    self:init(item, player)
    local data = TrueSmoking:getModData(player)
    local ts = TrueSmoking:getPlayerReference(player)
    if not data then
        print('TRUESMOKING::No modData for player: ' .. player:getUsername())
        return
    end
    print('TRUESMOKING::Smokable start called - smokeLit: ' ..
        tostring(self.smokeLit) .. ', isSmoking: ' .. tostring(data.isSmoking))
    if not data.isSmoking then
        data.isSmoking = true
        -- data.smokeLit = true

        -- local function updateWrapper()
        --     self:update()
        -- end
        -- Events.OnPlayerUpdate.Add(updateWrapper)

        -- self.updateWrapper = updateWrapper
        -- self:equipVisualItem()
        -- if self.cigPack then
        --     self.cigPack:setUsedDelta(self.cigPack:getCurrentUsesFloat() - self.cigPack:getUseDelta())
        -- else
        --     self.player:getInventory():Remove(self.item)
        -- end
    end

    if not self.smokeLit then
        self.smokeLit = true
        self.lightingEatSound = ''

        if self.burnRate == 0 then
            self.burnRate = ZombRandFloat(self.burnMin,
                self.burnMax)
        end
    end
    -- data.Smokable = self
    print('TRUESMOKING::Smokable started - smokeLit: ' ..
        tostring(self.smokeLit) .. ', isSmoking: ' .. tostring(data.isSmoking))
    self.player:transmitModData()
    return self
end

function Smokable:putOut()
    local data = TrueSmoking:getModData(self.player)
    if data.isSmoking and not ISTimedActionQueue.hasActionType(self.player, 'PutOut') then
        ISTimedActionQueue.add(PutOut:new(self.player, instanceItem(self.itemFullType), self.smokeLength,
            self.customEatSound, self.itemFullType))
    end
end

function Smokable:stop()
    local data = TrueSmoking:getModData(self.player)
    data.isSmoking = false
    data.takingPuff = false
    self.smokeLit = false
    self.hasDropped = false
    self.dropState = false

    -- data.SmokingMoodle:stop()

    -- self:removeVisualItem()

    -- if self.updateWrapper then
    --     Events.OnPlayerUpdate.Remove(self.updateWrapper)
    --     self.updateWrapper = nil
    -- end

    TrueSmoking:checkForMaskAndEquip(self.player)

    if self.item then
        local onUse = self.replaceOnUse
        if onUse and onUse ~= '' and self.smokeLength <= 0 then
            print('TRUESMOKING::adding item: ' .. self.replaceOnUse)
            -- TrueSmoking.addOnUseItem(self.player)
            sendClientCommand(self.player, 'TrueSmoking', 'addSmokable', { self.replaceOnUse })
        end
    end

    if self.smokeLength > 0 then
        -- self.player:getInventory():AddItem(self.item)
        self.player:getModData().Smokable = false
    end

    self.player:transmitModData()
    -- self.item:transmitModData()
    -- self.item:syncItemModData()
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
    local state = TrueSmoking.getPlayerState(self.player)
    local dropStates = { ['CollideWithWallState'] = true }

    local ClimbFenceOutcome = self.player:GetVariable('ClimbFenceOutcome')
    local bumpType = self.player:getBumpType()
    local bumpTypes = { ['left'] = true, ['right'] = true }

    local result = ClimbFenceOutcome == 'fall' or dropStates[state] or bumpTypes[bumpType] or false

    return result
end

Events.OnPlayerUpdate.Add(function(player)
    Smokable:update(player)
end)

function Smokable:update(player)
    local data = TrueSmoking:getModData(player)
    if not data or not data.isSmoking then return end
    -- if isServer() then return end
    -- tsDebug('TRUESMOKING::Smokable update tick')
    -- if TrueSmoking.Options.Dropping and self.canDrop then
    --     if not self.hasRolledForDrop and self:checkDropConditions() then
    --         self.hasRolledForDrop = true
    --         local roll = ZombRandFloat(0.0, 100.0)
    --         local dropChance = self.player:hasTrait(CharacterTrait.SMOKER) and TrueSmoking.Options.DroppingChanceSmoker or
    --             TrueSmoking.Options.DroppingChanceNonSmoker
    --         if dropChance >= roll then
    --             self.hasDropped = true
    --         end
    --     end
    --     if self.hasRolledForDrop and not self:checkDropConditions() then
    --         self.hasRolledForDrop = false
    --         if self.hasDropped then
    --             self.hasDropped = false
    --             self:dropSmoke()
    --         end
    --     end
    -- end
    if self.smokeLit then
        local gameSpeed = TrueSmoking.getGameSpeedMultiplier()
        local isWalking = self.player:isWalking() and self.conditions['walking']
        local isRunning = self.player:isRunning() and self.conditions['running']
        local isSprinting = self.player:isSprinting() and self.conditions['sprinting']
        local isStrafing = self.player:isStrafing() and self.conditions['strafing']
        local isReading = ISTimedActionQueue.hasActionType(self.player, 'ISReadABook')

        if not isServer() then
            if isKeyDown(TrueSmoking.Config.keySmoke) and data.holdingPuffKey == false then
                data.holdingPuffKey = true
            elseif data.holdingPuffKey == true and not isKeyDown(TrueSmoking.Config.keySmoke) then
                data.holdingPuffKey = false
            end
        end

        local targetBurnRate
        if data.takingPuff then
            targetBurnRate = self.burnMax * self.puffFactor
        elseif isSprinting then
            targetBurnRate = self.burnMin * self.sprintingFactor
        elseif isRunning then
            targetBurnRate = self.burnMin * self.runningFactor
        elseif isWalking or isStrafing then
            targetBurnRate = self.burnMin * self.walkingFactor
        elseif isReading then
            targetBurnRate = self.burnMin * self.walkingFactor * 0.5
        else
            targetBurnRate = nil
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

        if not isServer() then
            sendClientCommand(self.player, 'TrueSmoking', 'OnEat_ItemStats', { self:getStats() })
            if self.onEat == 'RecipeCodeOnEat.consumeNicotine' then
                sendClientCommand(self.player, 'TrueSmoking', 'OnEat_Tobacco', { self:getStats() })
            end
        end
        -- TrueSmoking.OnEat_ItemStats(self)

        if TrueSmoking.Options.UseNicotineSystem and self.onEat == 'RecipeCodeOnEat.consumeNicotine' and self.puffPercent > 0 and self.nicotineContent then
            local nicotineAmount = self.nicotineContent * self.puffPercent
            NicotineSystem:smoke(self.player, nicotineAmount, self.nicotineContent)
        end

        if self.callback then
            self.callback(self)
            -- sendClientCommand(self.player, 'TrueSmoking', 'smokableCallback', { self.callback, self:getStats() })
        end

        for _, func in ipairs(TrueSmoking.Callbacks) do
            -- func(self)
        end

        -- self.item:getModData().SmokeLength = self.smokeLength
        -- if isClient() then
        --     self.item:transmitModData()
        -- end
        -- self.item:syncItemModData()
        -- syncItemModData(self.item)
        self.player:getModData().Smokable = { self.item:getFullType(), self.smokeLength }
        self.player:transmitModData()
        self:idlePuff()
    end

    if TrueSmoking.Options.SmokeRelighting and self.burnRate < 0.0000025 then
        self.burnRate = 0
        self.smokeLit = false
    elseif not TrueSmoking.Options.SmokeRelighting and self.burnRate < self.burnMin then
        self.burnRate = self.burnMin
    end

    if self.smokeLength <= 0 then
        self.smokeLength = 0
        self.smokeLit = false
        if TrueSmoking.Config.AutoPutOut then
            self:putOut()
        end
    end
end

function Smokable:puff()
    if not ISTimedActionQueue.hasActionType(self.player, 'TakePuff') then
        ISTimedActionQueue.add(TakePuff:new(self.player, instanceItem(self.itemFullType), self.customEatSound,
            self.itemFullType))
    end
end

function Smokable:idlePuff()
    if (TrueSmoking.Config.KeepLit and self.burnRate < 0.00001 and self.smokeLit) then
        self:puff()
    end
end
