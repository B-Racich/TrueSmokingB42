require "TimedActions/ISBaseTimedAction"

LightSmoke = ISBaseTimedAction:derive("LightSmoke")

function LightSmoke:isValid()
    --Check if we have a smoke lit
    return TrueSmoking.isSmoking
end

function LightSmoke:update()
    -- Trigger every game update when the action is performs
end

function LightSmoke:waitToStart()
    --Wait for timed actions to finish
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
            and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then return false else return true end
end

function LightSmoke:start()
    --Set the animation
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self:setOverrideHandModels(nil, self.item)

    --Track puff
    TrueSmoking.takingPuff = true
    TrueSmoking.Smokable.puffTimeMark = os.time()
end

function LightSmoke:stop()
    TrueSmoking.takingPuff = false
    self:forceComplete()
    ISBaseTimedAction.stop(self)
end

function LightSmoke:perform()
    --Track puff
    TrueSmoking.takingPuff = false
    TrueSmoking.Smokable.puffTimeMark = os.time()
    ISBaseTimedAction.perform(self)
end

function LightSmoke:new(character)
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