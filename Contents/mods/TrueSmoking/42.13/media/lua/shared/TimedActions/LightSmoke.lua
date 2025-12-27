require 'TimedActions/ISBaseTimedAction'
require 'TrueSmoking'
require 'Smokable'
require 'Utils'

LightSmoke = ISBaseTimedAction:derive('LightSmoke')

local tsDebug = TrueSmoking.tsDebug

function LightSmoke:isValidStart()
    return true
end

function LightSmoke:isValid()
    -- if isClient() and self.item then
    --     return self.character:getInventory():containsID(self.item:getID());
    -- else
    --     return self.character:getInventory():contains(self.item);
    -- end
    return true
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
    -- if self.cigPack then
    --     local cig = self.character:getInventory():AddItem('Base.CigaretteSingle')
    --     self.item = cig
    --     sendAddItemToContainer(self.character:getInventory(), cig)
    -- end

    if isClient() and self.item then
        self.item = self.character:getInventory():getItemById(self.item:getID())
    end

    if self.item and self.item.getCustomEatSound then
        self.eatSound = self.item:getCustomEatSound() or ''
    end

    -- fromRelaunch is added in ISTimedAction to not consume stuff again when we relaunch the action
    if self.item:getRequireInHandOrInventory() and not (self.carLighter or self.openFlame) then
        local lighter = self:getRequiredItem()
        self.lighter = lighter
        lighter:setUsedDelta(lighter:getCurrentUsesFloat() - lighter:getUseDelta())
        sendItemStats(lighter)
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

    local hasPrimary = self.character:getPrimaryHandItem()
    if hasPrimary then
        self:setOverrideHandModels(hasPrimary, self.item)
    else
        self:setOverrideHandModels(nil, self.item)
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
    local ts = TrueSmoking:getPlayerReference(self.character)

    if self.eatAudio ~= 0 and self.character:getEmitter():isPlaying(self.eatAudio) then
        self.character:stopOrTriggerSound(self.eatAudio);
    end
    -- if self.item then
    --     self.item = self.character:getInventory():AddItem(self.item)
    -- end
    ts.Smokable = Smokable:start(self.character, self.item)
    tsDebug('LightSmoke::perform - Started smoking action')

    ISBaseTimedAction.perform(self)
end

function LightSmoke:complete()
    print('TRUESMOKING::LightSmoke complete')
    if self.cigPack then
        -- local ts = TrueSmoking:getPlayerReference(self.character)
        self.cigPack:setUsedDelta(self.cigPack:getCurrentUsesFloat() - self.cigPack:getUseDelta())
        sendItemStats(self.cigPack)
        data.cigPackUsed = true
        -- local cig = self.character:getInventory():AddItem('Base.CigaretteSingle')
        -- self.item = cig
        -- sendAddItemToContainer(self.character:getInventory(), cig)
        -- ts.Smokable = Smokable:start(self.character, cig)
        -- sendAddItemToContainer(self.character:getInventory(), self.item)
        -- sendClientCommand(self.character, 'TrueSmoking', 'addSmokable', { self.item })
    end
    -- self.lighter:UseAndSync()
    -- local data = self.character:getModData().TrueSmoking
    local data = {}
    data.isSmoking = true
    data.takingPuff = false
    -- TrueSmoking.EquipVisualItem(self.character, self.item)
    sendClientCommand(self.character, 'TrueSmoking', 'equipVisualItem', { self.item, TrueSmoking.Options })

    -- self.character:transmitModData()
    sendClientCommand(self.character, 'TrueSmoking', 'updatePlayerData', { data })
    -- self.character:transmitModData()
    -- syncItemModData(self.character, self.item)
    tsDebug('LightSmoke::complete - Transmitted mod data after lighting smoke')
    return true
end

function LightSmoke:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 220
end

function LightSmoke:new(character, item)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true
    o.forceProgressBar = false

    o.character = character
    o.item = item
    if instanceof(item, 'Drainable') then
        -- o.item = instanceItem('Base.CigaretteSingle')
        o.cigPack = item
    end
    -- o.data = data

    -- o.eatSound = o.item:getCustomEatSound() or ''
    o.eatSound = ''
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
