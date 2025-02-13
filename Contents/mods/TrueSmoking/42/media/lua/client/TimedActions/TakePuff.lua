require "TimedActions/ISBaseTimedAction"

TakePuff = ISBaseTimedAction:derive("TakePuff")

function TakePuff:isValid()
    --Check if we have a smoke lit
    return self.trueSmoking.isSmoking and 
    (isKeyDown(TrueSmoking.Config.keySmoke) or self.maxTime ~= -1)
end

function TakePuff:update()
    -- Trigger every game update when the action is performs
    self.trueSmoking.Smokable.puffTimeMark = os.time()
end

function TakePuff:waitToStart()
    --Wait for timed actions to finish
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
            and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then return false else return true end
end

function TakePuff:start()
    --Play custom sound
    -- if getActivatedMods():contains("\\SmokingSoundsOverhaul") then
    --     if self.eatAudio then
    --         self.eatAudio = self.character:getEmitter():playSound("Smoking_matches2m");
    --     end
    -- end

    --Set the animation
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self:setOverrideHandModels(nil, self.item)
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    --Track puff
    self.trueSmoking.takingPuff = true
end

function TakePuff:stop()
    -- if getActivatedMods():contains("\\SmokingSoundsOverhaul") then
    --     if self.eatAudio then
    --         self.character:getEmitter():stopSound(self.eatAudio)
    --     end
    -- end

    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    self:forceComplete()
    ISBaseTimedAction.stop(self)

    if TrueSmoking.Options.Coughing then
        local coughChance = 100
        if self.character:HasTrait("Smoker") then
            if ZombRand(coughChance) <= TrueSmoking.Options.CoughingChanceSmoker then
                self.character:triggerCough()
            end
        else
            if ZombRand(coughChance) <= TrueSmoking.Options.CoughingChanceNonSmoker then
                self.character:triggerCough()
            end
        end
    end
end

function TakePuff:perform()
    if self.eatAudio then
        self.character:getEmitter():stopSound(self.eatAudio)
    end

    --Track puff
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    ISBaseTimedAction.perform(self)
end

function TakePuff:new(character)
    local o = {
        stopOnWalk = false,
        stopOnRun = true,
        stopOnAim = true,
        forceProgressBar = false,
        character = character,
    }

    if character:getPlayerNum() == 0 then o.trueSmoking = TrueSmoking.Player_1 else o.trueSmoking = TrueSmoking.Player_2 end
    o.item = o.trueSmoking.Smokable.item

    setmetatable(o, self)
    self.__index = self

    o.maxTime = -1 -- -1 means it will never finish
    return o
end