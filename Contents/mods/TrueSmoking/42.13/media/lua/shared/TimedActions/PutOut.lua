require 'TimedActions/ISBaseTimedAction'
require 'TrueSmoking'
require 'Smokable'

PutOut = ISBaseTimedAction:derive('PutOut')

function PutOut:isValid()
    --Check if we have a smoke lit
    return self.data.isSmoking
end

function PutOut:update()
    -- Take smoke from mouth sync timer
    local curTime = os.time()
    if not self.visualItemFlag then
        if os.difftime(curTime, self.timer) > self.visualItemTimer then
            -- Smokable:removeVisualItem(self.character)
            sendClientCommand(self.character, 'TrueSmoking', 'removeSmokableItem', { self.item })
            self.visualItemFlag = true
            local hasPrimary = self.character:getPrimaryHandItem()
            if hasPrimary then
                self:setOverrideHandModels(hasPrimary, self.item)
            else
                self:setOverrideHandModels(nil, self.item)
            end
            -- self:setOverrideHandModels(self.character:getPrimaryHandItem():getStaticModel(), self.item)
        end
    end

    if self.eatSound ~= '' and self.eatAudio ~= 0 and not self.character:getEmitter():isPlaying(self.eatAudio) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
    end
end

function PutOut:waitToStart()
    --Wait for timed actions to finish
    if self.character:isStrafing() or self.character:isRunning() or self.character:isSprinting() or self.character:isAiming()
        or self.character:isAsleep() or self.character:isPerformingAnAction() then
        return true
    else
        return false
    end
end

function PutOut:start()
    if TrueSmoking.Config.HideAllActionBars then
        self.action:setUseProgressBar(false)
    end
    self.timer = os.time()
    --Set the animation
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable('FoodType', self.item:getEatType())
    self:setOverrideHandModels(nil, self.item)

    if self.eatSound ~= '' then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
    end
end

function PutOut:stop()
    ISBaseTimedAction.stop(self)
    local data = TrueSmoking:getModData(self.character)
    local ts = TrueSmoking:getPlayerReference(self.character)
    -- if data and self.item:getModData().SmokeLength <= 0 then
     if self.smokeLength > 0 then
        -- self.character:getInventory():Remove(self.item)
        -- local item = self.character:getInventory():AddItem(self.item)
        sendClientCommand(self.character, 'TrueSmoking', 'addSmokable', { self.fullType,self.smokeLength })
    end
    return true
    -- end
    -- If we are cancelling the action and the smoke is finished just get rid of it
    -- self:forceComplete()
end

function PutOut:serverStop()

end

function PutOut:complete()
    if self.smokeLength > 0 then
        local item = self.character:getInventory():AddItem(self.fullType)
        item:getModData().SmokeLength = self.smokeLength
        -- item:syncItemModData()
        -- syncItemModData(item)
        -- item:transmitModData()
        sendAddItemToContainer(self.character:getInventory(),item)
    end
    return true
end

function PutOut:perform()
    local data = TrueSmoking:getModData(self.character)
    local ts = TrueSmoking:getPlayerReference(self.character)
    -- data.isSmoking = false
    -- if ts then
        ts.Smokable:stop()
    -- end
    sendClientCommand(self.character, 'TrueSmoking', 'removeSmokableItem', { self.item })
    self.character:transmitModData()
    ISBaseTimedAction.perform(self)
end

function PutOut:new(character, item, smokeLength, eatSound, fullType)
    local o = ISBaseTimedAction.new(self, character)

    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true

    o.character = character
    o.data = TrueSmoking:getModData(character)
    o.item = item
    o.maxTime = 120
    o.smokeLength = smokeLength
    o.fullType = fullType

    o.eatSound = eatSound
    o.eatAudio = 0

    o.visualItemTimer = 0.7
    o.visualItemFlag = false

    return o
end
