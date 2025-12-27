require 'TimedActions/ISBaseTimedAction'
require 'TrueSmoking'
require 'Smokable'
require 'Utils'

TakePuff = ISBaseTimedAction:derive('TakePuff')

function TakePuff:isValid()
    return self.data.isSmoking
end

function TakePuff:update()
    -- Sync up the anim to remove the visualItem when the hand reaches the mouth
    local curTime = os.time()
    if not self.visualItemFlag then
        if os.difftime(curTime, self.timer) > self.visualItemTimer then
            if isClient() then
                self.character:removeWornItem(self.character:getWornItem(TrueSmoking.registries.mask))
            end
            sendClientCommand(self.character, 'TrueSmoking', 'removeVisualItem', { TrueSmoking.Options })
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

    local ts = TrueSmoking:getPlayerReference(self.character)

    -- Reset job if keybind is held
    if self:getJobDelta() >= .98 then
        if ts.Smokable.smokeLength > 0 and (self.data.holdingPuffKey or self.data.B_HELD) and not self.endAction then -- We reset job delta for continous smoking
            self.LongJobDelta = self.LongJobDelta + self:getJobDelta()
            self:resetJobDelta()
        end
    end
end

function TakePuff:waitToStart()
    return false
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
    self.character:transmitModData()
    -- sendClientCommand(self.character, 'TrueSmoking', 'updatePlayerData', { self.data })
end

function TakePuff:stop()
    ISBaseTimedAction.stop(self)

    if self.character:getEmitter():isPlaying(self.eatSound) then
        self.character:getEmitter():stopSound(self.eatAudio)
    end

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
    local ts = TrueSmoking:getPlayerReference(self.character)
    ts.Smokable = Smokable:start(self.character, self.item)
    if isClient() then
        local visual = ts.Smokable:getVisualItem(self.item)
        self.character:setWornItem(visual:getBodyLocation(), visual)
    end
    sendClientCommand(self.character, 'TrueSmoking', 'equipVisualItem', { self.item, TrueSmoking.Options })
    self.data.takingPuff = false
    self.character:transmitModData()
    -- self:forceComplete()
end

function TakePuff:serverStop()
    self:forceComplete()
end

function TakePuff:perform()
    if TrueSmoking.getGameSpeedMultiplier() > 1 then
        if self.character:getEmitter():isPlaying(self.eatSound) then
            self.character:getEmitter():stopSound(self.eatAudio)
        end
    end


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
    self.data.takingPuff = false
    local ts = TrueSmoking:getPlayerReference(self.character)
    ts.Smokable = Smokable:start(self.character, self.item)
    if isClient() then
        local visual = ts.Smokable:getVisualItem(self.item)
        self.character:setWornItem(visual:getBodyLocation(), visual)
    end
    self.character:transmitModData()
    ISBaseTimedAction.perform(self)
end

function TakePuff:complete()
    self.data.takingPuff = false
    sendClientCommand(self.character, 'TrueSmoking', 'updatePlayerData', { { takingPuff = false } })
    sendClientCommand(self.character, 'TrueSmoking', 'equipVisualItem', { self.item, TrueSmoking.Options })
    -- TrueSmoking.EquipVisualItem(self.character, self.item)
    return true
end

function TakePuff:new(character, item, eatSound, fullType)
    local o = ISBaseTimedAction.new(self, character)

    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true

    o.character = character
    o.data = character:getModData().TrueSmoking
    -- o.ts = TrueSmoking:getPlayerReference(character)
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
