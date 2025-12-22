require 'TimedActions/ISBaseTimedAction'
require 'TrueSmoking'
require 'Smokable'

TakePuff = ISBaseTimedAction:derive('TakePuff')

function TakePuff:isValid()
    return self.data.isSmoking and self.ts.Smokable.smokeLength > 0
end

function TakePuff:update()
    -- Sync up the anim to remove the visualItem when the hand reaches the mouth
    local curTime = os.time()
    if not self.visualItemFlag then
        if os.difftime(curTime, self.timer) > self.visualItemTimer then
            -- Smokable:removeVisualItem(self.character)
            sendClientCommand(self.character, 'TrueSmoking', 'removeSmokableItem', {})
            -- self.data.Smokable:removeVisualItem()
            self.visualItemFlag = true
            local hasPrimary = self.character:getPrimaryHandItem()
            if hasPrimary then
                self:setOverrideHandModels(hasPrimary, self.item)
            else
                self:setOverrideHandModels(nil, self.item)
            end
        end
    end

    -- Loop audio
    if self.eatSound ~= '' and self.eatAudio ~= 0 and not self.character:getEmitter():isPlaying(self.eatAudio) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end

    -- Reset job if keybind is held
        if self:getJobDelta() >= .98 then
            if self.ts.Smokable.smokeLength > 0 and (self.data.holdingPuffKey or self.data.B_HELD) and not self.endAction then -- We reset job delta for continous smoking
                self.LongJobDelta = self.LongJobDelta + self:getJobDelta()
                self:resetJobDelta()
            end
        end
end

function TakePuff:waitToStart()
    if TrueSmoking.getGameSpeedMultiplier() == 1 then
        if self.character:getEmitter():isPlaying(self.data.eatSound)
            or (self.data.lightingEatSound and self.character:getEmitter():isPlaying(self.data.lightingEatSound)) then
            return true
        end
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
    local anim = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 'Smoke_Quiet' or CharacterActionAnims.Eat
    self:setActionAnim(anim)
    self:setAnimVariable('FoodType', self.item:getEatType())

    --Track puff
    self.data.takingPuff = true

    -- if not self.data.visualItem then
    --     local hasPrimary = self.character:getPrimaryHandItem()
    --     if hasPrimary then
    --         self:setOverrideHandModels(hasPrimary, self.item)
    --     else
    --         self:setOverrideHandModels(nil, self.item)
    --     end
    -- end

    if self.eatSound ~= '' then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
    end

    -- Play custom sound when no sound is playing
    if getActivatedMods():contains('\\SmokingSoundsOverhaul') then
        local gender = self.character:isFemale()
        local sound = SmokingSoundsOverhaul:getPuffSound(gender)
        if self.eatSound == '' then -- No sound running for first time
            self.eatSound = sound
            -- Check if we previously started a puff and its audio is still playing
            if not self.character:getEmitter():isPlaying(self.data.eatSound) then
                self.data.eatSound = sound
                self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
            end
        end
    end
    -- self.character:reportEvent('EventEating');
end

function TakePuff:stop()
    ISBaseTimedAction.stop(self)

    if self.character:getEmitter():isPlaying(self.eatSound) then
        self.character:getEmitter():stopSound(self.eatAudio)
    end

    -- Smokable:equipVisualItem(self.character, self.item) -- requip our visualItem
    self.data.takingPuff = false

    if TrueSmoking.Options.Coughing then
        local coughChance = 100
        if self.character:hasTrait(CharacterTrait.SMOKER) then
            if ZombRand(coughChance) <= TrueSmoking.Options.CoughingChanceSmoker then
                self.character:triggerCough()
            end
        else
            if ZombRand(coughChance) <= TrueSmoking.Options.CoughingChanceNonSmoker then
                self.character:triggerCough()
            end
        end
    end
    sendClientCommand(self.character, 'TrueSmoking', 'equipSmokableItem',{self.fullType})
    self:forceComplete()
end

function TakePuff:serverStop()
    -- Smokable:equipVisualItem(self.character, self.item) -- requip our visualItem
    sendClientCommand(self.character, 'TrueSmoking', 'equipSmokableItem',{self.fullType})
end

function TakePuff:perform()
    if TrueSmoking.getGameSpeedMultiplier() > 1 then
        if self.character:getEmitter():isPlaying(self.eatSound) then
            self.character:getEmitter():stopSound(self.eatAudio)
        end
    end

    self.data.takingPuff = false

    if TrueSmoking.Options.Coughing then
        local coughChance = 100
        if self.character:hasTrait(CharacterTrait.SMOKER) then
            if ZombRand(coughChance) <= TrueSmoking.Options.CoughingChanceSmoker then
                self.character:triggerCough()
            end
        else
            if ZombRand(coughChance) <= TrueSmoking.Options.CoughingChanceNonSmoker then
                self.character:triggerCough()
            end
        end
    end
    self.character:transmitModData()
    sendClientCommand(self.character, 'TrueSmoking', 'equipSmokableItem',{self.fullType})
    ISBaseTimedAction.perform(self)
end

function TakePuff:complete()
    -- Smokable:equipVisualItem(self.character, self.item) -- requip our visualItem
    -- self.data.Smokable:equipVisualItem() -- requip our visualItem

    return true
end

function TakePuff:new(character, item, eatSound, fullType)
    local o = ISBaseTimedAction.new(self, character)

    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true

    o.character = character
    o.data = TrueSmoking:getModData(character)
    o.ts = TrueSmoking:getPlayerReference(character)
    o.item = item
    o.eatSound = eatSound
    o.fullType = fullType
    -- o.eatSound = ''
    o.eatAudio = 0
    o.maxTime = 220
    o.visualItemAnimLength = 3.7
    o.visualItemTimer = 0.7
    o.visualItemFlag = false
    o.LongJobDelta = 0
    o.JobFactor = o.visualItemTimer / o.maxTime

    return o
end
