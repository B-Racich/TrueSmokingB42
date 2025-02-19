require "TimedActions/ISBaseTimedAction"

LightSmoke = ISBaseTimedAction:derive("LightSmoke")

function LightSmoke:isValid()
    --Check if we have a smoke lit
    return self.trueSmoking.isSmoking
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
    -- local anim = getActivatedMods():contains("\\SmokingSoundsOverhaul") and 'Smoke_Quiet' or CharacterActionAnims.Eat
    -- self:setActionAnim(anim)
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable("FoodType", self.item:getEatType())
    -- self:setOverrideHandModels(nil, self.item)

    -- Play custom sound when no sound is playing
    if getActivatedMods():contains("\\SmokingSoundsOverhaul") then
        local sound = SmokingSoundsOverhaul:getLightingSound(self.character)
        if self.eatSound == '' then -- No sound running for first time
            self.eatSound = sound
            -- Check if we previously started a puff and its audio is still playing
            if not self.character:getEmitter():isPlaying(self.trueSmoking.lightingEatSound) then
                self.trueSmoking.lightingEatSound = sound
                self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
            end
        end
    end
end

function LightSmoke:stop()
    ISBaseTimedAction.stop(self)
    self:forceComplete()
end

function LightSmoke:perform()
    ISBaseTimedAction.perform(self)
    self.trueSmoking.Smokable.smokeLit = true
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    if self.trueSmoking.Smokable.burnRate == 0 then
        self.trueSmoking.Smokable.burnRate = ZombRandFloat(self.trueSmoking.Smokable.burnMin, self.trueSmoking.Smokable.burnMax)
    end
end

function LightSmoke:complete()
    self.trueSmoking.Smokable.smokeLit = true
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    if self.trueSmoking.Smokable.burnRate == 0 then
        self.trueSmoking.Smokable.burnRate = ZombRandFloat(self.trueSmoking.Smokable.burnMin, self.trueSmoking.Smokable.burnMax)
    end
    return true
end

function LightSmoke:new(character)
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
    o.maxTime = TrueSmoking.relightTime

    setmetatable(o, self)
    self.__index = self

    return o
end