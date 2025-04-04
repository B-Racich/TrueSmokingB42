require "TimedActions/ISBaseTimedAction"

TakePuff = ISBaseTimedAction:derive("TakePuff")

function TakePuff:isValid()
    return self.trueSmoking.isSmoking
end

function TakePuff:update()
    -- Sync up the anim to remove the visualItem when the hand reaches the mouth
    local curTime = os.time()
    if self.trueSmoking.visualItem and not self.visualItemFlag then
        if os.difftime(curTime, self.timer) > self.visualItemTimer then
            self.trueSmoking.Smokable:removeVisualItem()
            self.visualItemFlag = true
            local hasPrimary = self.character:getPrimaryHandItem()
            if hasPrimary then
                self:setOverrideHandModels(hasPrimary, self.item)
            else
                self:setOverrideHandModels(nil, self.item)
            end
        end
    end

    self.trueSmoking.Smokable.puffTimeMark = os.time()

    -- Reset job if keybind is held
    if self:getJobDelta() >= .98 then
        if self.trueSmoking.Smokable.smokeLength > 0 and ((isKeyDown(TrueSmoking.Config.keySmoke) or self.trueSmoking.B_HELD) and not self.endAction) then -- We reset job delta for continous smoking
            self.LongJobDelta = self.LongJobDelta + self:getJobDelta()
            self:resetJobDelta()
        end
    end
end

function TakePuff:waitToStart()
    if self.character:getEmitter():isPlaying(self.trueSmoking.eatSound)
        or (self.trueSmoking.lightingEatSound and self.character:getEmitter():isPlaying(self.trueSmoking.lightingEatSound)) then
        return true
    end
    --Wait for timed actions to finish
    if self.character:isStrafing() or self.character:isRunning() or self.character:isSprinting()
        or self.character:isAiming() or self.character:isAsleep() or self.character:isPerformingAnAction()
    then
        return true
    else
        return false
    end
end

function TakePuff:start()
    if TrueSmoking.Config.HideActionBar or TrueSmoking.Config.HideAllActionBars then
        self.action:setUseProgressBar(false)
    end
    self.timer = os.time()
    -- set the anim for vanilla or modded
    local anim = getActivatedMods():contains("\\SmokingSoundsOverhaul") and 'Smoke_Quiet' or CharacterActionAnims.Eat
    self:setActionAnim(anim)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    --Track puff
    self.trueSmoking.takingPuff = true
    self.puffTimeMark = os.time()

    --2x for 1/2 speed anim
    if anim == 'Smoke_Quiet' then
        self.visualItemTimer = self.visualItemTimer * 2
        self.visualItemAnimLength = self.visualItemAnimLength * 2
    end

    if not self.trueSmoking.visualItem then
        local hasPrimary = self.character:getPrimaryHandItem()
        if hasPrimary then
            self:setOverrideHandModels(hasPrimary, self.item)
        else
            self:setOverrideHandModels(nil, self.item)
        end
    end

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
    -- self.character:reportEvent("EventEating");
end

function TakePuff:stop()
    ISBaseTimedAction.stop(self)

    if self.character:getEmitter():isPlaying(self.eatSound) then
        self.character:getEmitter():stopSound(self.eatAudio)
    end

    self.trueSmoking.Smokable:equipVisualItem() -- requip our visualItem
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    self.trueSmoking.Smokable.timeCheck = ZombRand(TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime)

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

    self:forceComplete()
end

function TakePuff:perform()
    if self.character:getEmitter():isPlaying(self.eatSound) then
        self.character:getEmitter():stopSound(self.eatAudio)
    end

    self.trueSmoking.Smokable:equipVisualItem() -- requip our visualItem
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    self.trueSmoking.Smokable.timeCheck = ZombRand(TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime)

    ISBaseTimedAction.perform(self)
end

function TakePuff:complete()
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
    return true
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
    o.maxTime = 220
    o.visualItemAnimLength = 3.7
    o.visualItemTimer = 0.7
    o.visualItemFlag = false
    o.LongJobDelta = 0
    o.JobFactor = o.visualItemTimer / o.maxTime

    setmetatable(o, self)
    self.__index = self

    return o
end
