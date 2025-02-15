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
    self.timer = os.time()
    -- --Set the animation
    local anim = getActivatedMods():contains("\\SmokingSoundsOverhaul") and 'Smoke_Quiet' or CharacterActionAnims.Eat
    self:setActionAnim(anim)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self:setOverrideHandModels(nil, self.item)
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    --Track puff
    self.trueSmoking.takingPuff = true

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
end

function TakePuff:stop()
    ISBaseTimedAction.stop(self)

    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    self:forceComplete()

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

    print('add ciggy back')
    TrueSmoking:equipItem(self.character, self.trueSmoking.visualItem, true)
end

function TakePuff:perform()
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

    o.eatSound = ''
    o.eatAudio = 0

    o.removedForPuff = false

    setmetatable(o, self)
    self.__index = self

    o.maxTime = -1 -- -1 means it will never finish
    return o
end