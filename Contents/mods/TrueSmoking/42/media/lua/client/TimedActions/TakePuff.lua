require "TimedActions/ISBaseTimedAction"

TakePuff = ISBaseTimedAction:derive("TakePuff")

function TakePuff:isValid()
    --Check if we have a smoke lit
    return self.trueSmoking.isSmoking
        -- and ((isKeyDown(TrueSmoking.Config.keySmoke) or self.trueSmoking.B_HELD) or self.maxTime ~= -1)
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
            -- self:setOverrideHandModels(self.character:getPrimaryHandItem():getStaticModel(), self.item)
        end
    end

    -- Trigger every game update when the action is performs
    self.trueSmoking.Smokable.puffTimeMark = os.time()
    -- This should cover if the audio got stopped and needs to loop
    if self.eatSound ~= "" and self.eatAudio ~= 0 and not self.character:getEmitter():isPlaying(self.eatAudio) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end
    -- starts audio if starting with audio already playing
    if self.eatSound ~= '' and self.eatAudio == 0 and not self.character:getEmitter():isPlaying(self.trueSmoking.eatSound) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end

    if not (isKeyDown(TrueSmoking.Config.keySmoke) or self.trueSmoking.B_HELD) and not self.endAction then
        local diffTime = os.difftime(curTime, self.timer)
        local roundedDiffTime = tonumber(string.format("%.1f", diffTime))
        local roundedDiffTimeMod = tonumber(string.format('%.1f',roundedDiffTime % self.visualItemAnimLength))
        -- print(string.format('timer: %s - roundedDiffTime: %s - roundedDiffTimeMod: %s',self.timer, roundedDiffTime, roundedDiffTimeMod))
        if roundedDiffTime > self.visualItemTimer and roundedDiffTimeMod == self.visualItemTimer then
            self.maxTime = 1
            self.endAction = true
            self:stop()
        end
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
    -- set the anim for vanilla or modded
    local anim = getActivatedMods():contains("\\SmokingSoundsOverhaul") and 'Smoke_Quiet' or CharacterActionAnims.Eat
    -- print('anim is '..anim)
    self:setActionAnim(anim)
    -- local eatType = self.item:getEatType()
    -- print('eatType is '..eatType)
    self:setAnimVariable("FoodType", self.item:getEatType())
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    --Track puff
    self.trueSmoking.takingPuff = true
    self.puffTimeMark = os.time()

    --2x for 1/2 speed anim
    if anim == 'Smoke_Quiet' then
        self.visualItemTimer = self.visualItemTimer*2
        self.visualItemAnimLength = self.visualItemAnimLength*2
    end

    if not self.trueSmoking.visualItem then
        local hasPrimary = self.character:getPrimaryHandItem()
        if hasPrimary then
            self:setOverrideHandModels(hasPrimary, self.item)
        else
            self:setOverrideHandModels(nil, self.item)
        end
    end

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
    ISBaseTimedAction.perform(self)
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable:equipVisualItem() -- requip our visualItem
end

function TakePuff:complete()
    self.trueSmoking.takingPuff = false
    self.trueSmoking.Smokable:equipVisualItem() -- requip our visualItem
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
    o.maxTime = -1 -- -1 means it will never finish
    o.endAction = false
    o.visualItemAnimLength = 3.7
    o.visualItemTimer = 0.7
    o.visualItemFlag = false

    setmetatable(o, self)
    self.__index = self

    return o
end