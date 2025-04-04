require "TimedActions/ISBaseTimedAction"

LightSmoke = ISBaseTimedAction:derive("LightSmoke")

function LightSmoke:isValid()
    return self.trueSmoking.isSmoking and self.hasLighter
end

function LightSmoke:update()
end

function LightSmoke:waitToStart()
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
        and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then
        return false
    else
        return true
    end
end

local function predicateNotEmpty(item)
    return item:getCurrentUsesFloat() > 0
end

function LightSmoke:getRequiredItem()
    if not self.item:getRequireInHandOrInventory() then
        return
    end
    local types = self.item:getRequireInHandOrInventory()
    for i = 1, types:size() do
        local fullType = moduleDotType(self.item:getModule(), types:get(i - 1))
        local item2 = self.character:getInventory():getFirstTypeEvalRecurse(fullType, predicateNotEmpty)
        if item2 then
            return item2
        end
    end
    return nil
end

function LightSmoke:start()
    if TrueSmoking.Config.HideAllActionBars then
        self.action:setUseProgressBar(false)
    end

    if self.item:getRequireInHandOrInventory() and not (self.carLighter or self.openFlame) then
        local lighter = self:getRequiredItem()
        if not lighter then
            self.hasLighter = false
        else
            lighter:setUsedDelta(lighter:getCurrentUsesFloat() - lighter:getUseDelta())

            --Set the animation
            self:setActionAnim(CharacterActionAnims.Eat)
            self:setAnimVariable("FoodType", self.item:getEatType())

            if not self.trueSmoking.visualItem then
                self:setOverrideHandModels(nil, self.item)
            end

            -- Play custom sound when no sound is playing
            if getActivatedMods():contains("\\SmokingSoundsOverhaul") then
                local sound = SmokingSoundsOverhaul:getLightingSound(self.character)
                if self.eatSound == '' or self.eatSound == nil then -- No sound running for first time
                    self.eatSound = sound
                    if not self.character:getEmitter():isPlaying(self.trueSmoking.lightingEatSound) then
                        self.trueSmoking.lightingEatSound = self.eatSound
                        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
                    end
                end
            end
            self.character:reportEvent("EventEating");
        end
    end
end

function LightSmoke:stop()
    ISBaseTimedAction.stop(self)
end

function LightSmoke:perform()
    ISBaseTimedAction.perform(self)
    self.trueSmoking.Smokable.smokeLit = true
    self.trueSmoking.Smokable.puffTimeMark = os.time()

    if self.trueSmoking.Smokable.burnRate == 0 then
        self.trueSmoking.Smokable.burnRate = ZombRandFloat(self.trueSmoking.Smokable.burnMax * .75,
            self.trueSmoking.Smokable.burnMax * 1.15)
    end
end

function LightSmoke:complete()
    self.trueSmoking.lightingEatSound = ''
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
    o.carLighter = o.item:hasTag("Smokable") and o.character:getVehicle() and
    o.character:getVehicle():canLightSmoke(o.character)
    o.openFlame = false
    if o.item:hasTag("Smokable") then o.openFlame = ISInventoryPaneContextMenu.hasOpenFlame(o.character) end

    o.ignoreHandsWounds = true
    o.isEating = true
    o.hasLighter = true

    setmetatable(o, self)
    self.__index = self

    return o
end
