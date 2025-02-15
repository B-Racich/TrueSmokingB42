require "TimedActions/ISBaseTimedAction"

TakePuff = ISBaseTimedAction:derive("TakePuff")

function TakePuff:isValid()
    --Check if we have a smoke lit
    return self.trueSmoking.isSmoking and 
    ((isKeyDown(TrueSmoking.Config.keySmoke) or self.trueSmoking.B_HELD) or self.maxTime ~= -1)
end

function TakePuff:update()
    -- Trigger every game update when the action is performs
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    -- This should cover if the audio got stopped
    if self.eatSound ~= "" and self.eatAudio ~= 0 and not self.character:getEmitter():isPlaying(self.eatAudio) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end
    -- Restarts audio if starting with audio playing
    if self.eatSound ~= '' and self.eatAudio == 0 and not self.character:getEmitter():isPlaying(self.trueSmoking.eatSound) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end

    -- if not (isKeyDown(TrueSmoking.Config.keySmoke) or self.trueSmoking.B_HELD) then 
    --     self.maxTime = 1
    -- end
end

function TakePuff:waitToStart()
    if self.character:getEmitter():isPlaying(self.trueSmoking.eatSound)
        or (self.trueSmoking.lightingEatSound and self.character:getEmitter():isPlaying(self.trueSmoking.lightingEatSound)) then
        return true
    end
    --Wait for timed actions to finish
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
            and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then return false else return true end
end

function TakePuff:start()
    -- set the anim for vanilla or modded
    local anim = getActivatedMods():contains("\\SmokingSoundsOverhaul") and 'Smoke_Quiet' or CharacterActionAnims.Eat
    self:setActionAnim(anim)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self:setOverrideHandModels(nil, self.item)
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    --Track puff
    self.trueSmoking.takingPuff = true

    -- TODO base this off of anim instead for future expansion
    -- Play custom sound when no sound is playing
    if getActivatedMods():contains("\\SmokingSoundsOverhaul") then
        local gender = self.character:isFemale()
        local sound = SmokingSoundsOverhaul:getPuffSound(gender)
        if self.eatSound == '' then -- No sound running for first time
            self.eatSound = sound
            -- Check if we previously started a puff and its audio is still playing
            if not self.character:getEmitter():isPlaying(self.trueSmoking.eatSound) then
                self.trueSmoking.eatSound = sound
                self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
            end
        end
    end
    self.character:reportEvent("EventEating");
end

-- function TakePuff:forceStop()
--     print('we are force stopping')
--     ISBaseTimedAction.forceStop(self)
-- end

-- function TakePuff:forceComplete()
--     print('we are force completing')
--     ISBaseTimedAction.forceComplete(self)
-- end

function TakePuff:stop()
    print('STOP-1')
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
    print('STOP-2')
    -- self.trueSmoking.Smokable:equipVisualSmoke()
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    self:forceComplete()
    print('STOP-3')
end

function TakePuff:perform()
    ISBaseTimedAction.perform(self)
    --Track puff
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
end

function TakePuff:new(character)
    local o = {
        stopOnWalk = false,
        stopOnRun = true,
        stopOnAim = true,
        forceProgressBar = false,
        character = character,
    }

    o.trueSmoking = TrueSmoking:getPlayerReference(character)
    o.item = o.trueSmoking.Smokable.item
    o.eatSound = ''
    o.eatAudio = 0
    o.maxTime = -1 -- -1 means it will never finish

    setmetatable(o, self)
    self.__index = self

    return o
end