--[[
    LightSmoke.lua - Timed Action for Lighting a Smokable
    
    Handles the animation and state transition for lighting
    a cigarette, cigar, pipe, etc.
]]

require 'TimedActions/ISBaseTimedAction'
require 'Core'
require 'Data'

LightSmoke = ISBaseTimedAction:derive('LightSmoke')

--------------------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------------------

function LightSmoke:isValidStart()
    return true
end

function LightSmoke:isValid()
    return true
end

function LightSmoke:waitToStart()
    return false
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function predicateNotEmpty(item)
    return item:getCurrentUsesFloat() > 0
end

function LightSmoke:getRequiredItem()
    if not self.item:getRequireInHandOrInventory() then
        return nil
    end
    
    local types = self.item:getRequireInHandOrInventory()
    for i = 1, types:size() do
        local fullType = moduleDotType(self.item:getModule(), types:get(i - 1))
        local item = self.character:getInventory():getFirstTypeEvalRecurse(fullType, predicateNotEmpty)
        if item then
            return item
        end
    end
    return nil
end

function LightSmoke:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 220
end

--------------------------------------------------------------------------------
-- Action Lifecycle
--------------------------------------------------------------------------------

function LightSmoke:start()
    -- Refresh item reference for MP
    if isClient() and self.item then
        self.item = self.character:getInventory():getItemById(self.item:getID())
    end

    -- Get custom eat sound
    if self.item and self.item.getCustomEatSound then
        self.eatSound = self.item:getCustomEatSound() or ''
    end

    -- Consume lighter uses if needed
    if self.item:getRequireInHandOrInventory() and not (self.carLighter or self.openFlame) then
        local lighter = self:getRequiredItem()
        if lighter then
            self.lighter = lighter
            lighter:setUsedDelta(lighter:getCurrentUsesFloat() - lighter:getUseDelta())
            lighter:syncItemFields()
        end
    end

    -- Play sound
    if self.eatSound ~= '' then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end

    -- Set job type
    if self.item:getCustomMenuOption() then
        self.item:setJobType(self.item:getCustomMenuOption())
    else
        self.item:setJobType(getText('ContextMenu_Eat'))
    end

    -- Set hand models
    local primary = self.character:getPrimaryHandItem()
    self:setOverrideHandModels(primary, self.item)

    -- Set animation
    self:setAnimVariable('FoodType', self.item:getEatType())
    self:setActionAnim(CharacterActionAnims.Eat)
    
    TrueSmoking.debug('LightSmoke:start - Animation started')
end

function LightSmoke:update()
    -- Loop audio if needed
    if self.eatSound ~= '' and self.eatAudio ~= 0 then
        if not self.character:getEmitter():isPlaying(self.eatAudio) then
            self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
        end
    end
end

function LightSmoke:stop()
    TrueSmoking.debug('LightSmoke:stop - Action interrupted')
    ISBaseTimedAction.stop(self)
end

function LightSmoke:perform()
    TrueSmoking.debug('LightSmoke:perform - Starting smoke')
    
    local ref = TrueSmoking.getPlayerRef(self.character)
    
    -- Stop audio
    if self.eatAudio ~= 0 and self.character:getEmitter():isPlaying(self.eatAudio) then
        self.character:stopOrTriggerSound(self.eatAudio)
    end
    
    -- Create and start smokable
    local Smokable = require 'SmokableItem'
    ref.smokable = Smokable:start(self.character, self.item)
    
    -- Equip visual on client
    if isClient() then
        local visual = TrueSmoking.Visuals.createMask(self.item)
        if visual then
            self.character:setWornItem(TrueSmoking.registries.mask, visual)
        end
    end
    
    ISBaseTimedAction.perform(self)
end

function LightSmoke:complete()
    TrueSmoking.debug('LightSmoke:complete - Syncing state')
    
    -- Handle cigarette pack usage
    if self.cigPack then
        self.cigPack:setUsedDelta(self.cigPack:getCurrentUsesFloat() - self.cigPack:getUseDelta())
        sendItemStats(self.cigPack)
    end
    
    -- Sync state to server - send fullType string instead of item object for proper MP serialization
    local fullType = self.item and self.item:getFullType() or nil
    sendClientCommand(self.character, 'TrueSmoking', 'equipVisualItem', { 
        fullType = fullType, 
        options = TrueSmoking.Options 
    })
    sendClientCommand(self.character, 'TrueSmoking', 'updatePlayerData', { 
        { isSmoking = true, takingPuff = false } 
    })
    
    return true
end

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

function LightSmoke:new(character, item)
    local o = ISBaseTimedAction.new(self, character)
    
    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true
    o.forceProgressBar = false
    o.ignoreHandsWounds = true
    o.isEating = true
    
    o.character = character
    o.item = item
    o.maxTime = o:getDuration()
    
    -- Handle drainable items (packs)
    if instanceof(item, 'Drainable') then
        o.cigPack = item
    end
    
    -- Audio
    o.eatSound = ''
    o.eatAudio = 0
    
    -- Check for alternative light sources
    o.carLighter = item:hasTag(ItemTag.SMOKABLE) 
        and character:getVehicle() 
        and character:getVehicle():canLightSmoke(character)
    
    o.openFlame = false
    if not isServer() and item:hasTag(ItemTag.SMOKABLE) then
        o.openFlame = ISInventoryPaneContextMenu.hasOpenFlame(character)
    end
    
    return o
end
