require 'TimedActions/ISBaseTimedAction'

LightSmoke = ISBaseTimedAction:derive('LightSmoke')

function LightSmoke:isValidStart()
    return true
end

function LightSmoke:isValid()
    if isClient() and self.item then
        return self.character:getInventory():containsID(self.item:getID());
    else
        return self.character:getInventory():contains(self.item);
    end
end

function LightSmoke:update()
    if self.eatSound ~= '' and self.eatAudio ~= 0 and not self.character:getEmitter():isPlaying(self.eatAudio) then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
        --        self.eatAudio = getSoundManager():PlayWorldSoundWav( self.eatSound, self.character:getCurrentSquare(), 0.5, 2, 0.5, true);
    end
end

function LightSmoke:waitToStart()
    return false
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
    if isClient() and self.item then
        self.item = self.character:getInventory():getItemById(self.item:getID())
    end

    -- fromRelaunch is added in ISTimedAction to not consume stuff again when we relaunch the action
    if not self.fromRelaunch and self.item:getRequireInHandOrInventory() and not (self.carLighter or self.openFlame) then
        local lighter = self:getRequiredItem()
        lighter:setUsedDelta(lighter:getCurrentUsesFloat() - lighter:getUseDelta())
    end

    if self.eatSound ~= '' then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound);
        --		self.eatAudio = getSoundManager():PlayWorldSoundWav( self.eatSound, self.character:getCurrentSquare(), 0.5, 2, 0.5, true);
    end
    if self.item:getCustomMenuOption() then
        self.item:setJobType(self.item:getCustomMenuOption())
    else
        self.item:setJobType(getText('ContextMenu_Eat'));
    end

    self:setAnimVariable('FoodType', self.item:getEatType());
    self:setActionAnim(CharacterActionAnims.Eat);
    print('TRUESMOKING::LightSmoke started end')
end

function LightSmoke:stop()
    print('TRUESMOKING::LightSmoke stopped')
    ISBaseTimedAction.stop(self)

    if not isClient() and not isServer() then
        self:serverStop();
    end
end

function LightSmoke:serverStop()
    print('TRUESMOKING::LightSmoke server stopped')
end

function LightSmoke:perform()
    print('TRUESMOKING::LightSmoke perform')
    if self.eatAudio ~= 0 and self.character:getEmitter():isPlaying(self.eatAudio) then
        self.character:stopOrTriggerSound(self.eatAudio);
    end
    -- self.container:setDrawDirty(true);

    ISBaseTimedAction.perform(self)
end

function LightSmoke:complete()
    print('TRUESMOKING::LightSmoke complete')
    local smokable = Smokable:new(self.character, self.item, self.table)
    local table = TrueSmoking:getPlayerReference(self.character)
    table.Smokable = smokable
    smokable:start()
    local function updateWrapper()
        print('TRUESMOKING::Smokable add update wrapper tick')
        smokable:update()
    end
    Events.OnPlayerUpdate.Add(updateWrapper)
    return true
end

function LightSmoke:getDuration()
     if self.character:isTimedActionInstant() then
        return 1
    end
    return 460
end

function LightSmoke:new(character, item)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true
    o.forceProgressBar = false

    -- o.table = TrueSmoking:getPlayerReference(character)
    o.table = TrueSmoking:getPlayerReference(character)
    o.item = item
    o.character = character

    o.eatSound = o.item:getCustomEatSound() or ''
    o.eatAudio = 0
    o.maxTime = o:getDuration()

    o.carLighter = item:hasTag(ItemTag.SMOKABLE) and character:getVehicle() and
        character:getVehicle():canLightSmoke(character)
    o.openFlame = false;
    if not isServer() then
        if item:hasTag(ItemTag.SMOKABLE) then o.openFlame = ISInventoryPaneContextMenu.hasOpenFlame(character) end
    end

    o.ignoreHandsWounds = true
    o.isEating = true
    return o
end
