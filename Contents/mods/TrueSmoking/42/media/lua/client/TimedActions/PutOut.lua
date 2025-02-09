require "TimedActions/ISBaseTimedAction"

PutOut = ISBaseTimedAction:derive("PutOut")

function PutOut:isValid()
    --Check if we have a smoke lit
    return TrueSmoking.isSmoking
end

function PutOut:update()
    -- Trigger every game update when the action is performs
end

function PutOut:waitToStart()
    --Wait for timed actions to finish
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
            and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then return false else return true end
end

function PutOut:start()
    --Set the animation
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self:setOverrideHandModels(nil, self.item)
end

function PutOut:stop()
    TrueSmoking.takingPuff = false
    self:forceComplete()
    ISBaseTimedAction.stop(self)
    local item = TrueSmoking.Smokable.item:getReplaceOnUse()
end

function PutOut:perform()
    --Track puff
    ISBaseTimedAction.perform(self)
end

function PutOut:new(character)
    local o = {
        stopOnWalk = false,
        stopOnRun = true,
        stopOnAim = true,
        forceProgressBar = false,
        character = character,
        item = TrueSmoking.Smokable.item,
    }
    setmetatable(o, self)
    self.__index = self

    o.maxTime = 80
    return o
end