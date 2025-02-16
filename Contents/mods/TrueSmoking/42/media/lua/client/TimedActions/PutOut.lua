require "TimedActions/ISBaseTimedAction"

PutOut = ISBaseTimedAction:derive("PutOut")

function PutOut:isValid()
    --Check if we have a smoke lit
    return self.trueSmoking.isSmoking
end

function PutOut:update()
    -- Trigger every game update when the action is performs
    local curTime = os.time()
    if not self.visualItemFlag then
        if os.difftime(curTime, self.timer) > self.visualItemTimer then
            self.trueSmoking.Smokable:removeVisualItem()
            self.visualItemFlag = true
            self:setOverrideHandModels(nil, self.item)
        end
    end
end

function PutOut:waitToStart()
    --Wait for timed actions to finish
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
            and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then return false else return true end
end

function PutOut:start()
    self.timer = os.time()
    --Set the animation
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable("FoodType", self.item:getEatType())
    -- self:setOverrideHandModels(nil, self.item)
end

function PutOut:stop()
    ISBaseTimedAction.stop(self)
    self:forceComplete()
end

function PutOut:complete()
    self.trueSmoking.isSmoking = false
    self.trueSmoking.visualItem = false

    -- self.table.isSmoking = false
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.smokeLit = false

    self.trueSmoking.Moodle:stop()

    if self.trueSmoking.Smokable.updateWrapper then
        Events.OnTick.Remove(self.trueSmoking.Smokable.updateWrapper)
        self.trueSmoking.Smokable.updateWrapper = nil
    end

    local onUse = self.trueSmoking.Smokable.replaceOnUse
    if onUse and onUse ~= '' then
        addOnUseItem()
    end

    -- self:removeVisualItem()
    -- self.table.visualItem = false
    TrueSmoking:checkForMaskAndEquip(self.character)

    self.trueSmoking.Smokable.item = {}  --clear item for safety.
end

function PutOut:perform()
    ISBaseTimedAction.perform(self)
end

function PutOut:new(character)
    local o = {
        stopOnWalk = false,
        stopOnRun = false,
        stopOnAim = true,
        forceProgressBar = false,
        character = character,
    }

    o.trueSmoking = TrueSmoking:getPlayerReference(character)
    o.item = o.trueSmoking.Smokable.item
    o.maxTime = 120

    o.visualItemTimer = 0.7
    o.visualItemFlag = false

    setmetatable(o, self)
    self.__index = self

    return o
end