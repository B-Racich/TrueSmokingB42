require 'TimedActions/ISEatFoodAction'

local originalActionNew = ISEatFoodAction.new
local originalActionIsValid = ISEatFoodAction.isValid
local originalActionStop = ISEatFoodAction.stop
local originalActionPerform = ISEatFoodAction.perform
local originalActionStart = ISEatFoodAction.start

--[[
    This file hooks the foodAction, here the Smokable object is created and stored into
    the global TrueSmoking object.
]]

--Hook the ISEatFoodAction to grab smokable items and make our changes, stop the vanilla actions and call our own.
function ISEatFoodAction:new (character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local modOnEat = item:getModData().modOnEat or ''
    local name = item:getFullType() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:getTags():contains('Smokable')
    local funcsToHook = {'OnEat_Cigarettes','OnEat_Cigarillo','OnEat_Cigar',
    'OnEat_WeedSmoke','OnEat_WeedJoint','OnEat_WeedPipe'}
    local itemsToSkip = {}
    local hook = 'OnEat_Hook'

    --Store the original action to return it if we don't need to hook it
    o = originalActionNew(self, character, item, percentage)

    local trueSmoking = TrueSmoking:getPlayerReference(character)
    o.trueSmoking = trueSmoking

    trueSmoking.mask = false
    trueSmoking.shemagh = false
    TrueSmoking:checkForMaskAndRemove(character)

    if isInList(onEat, funcsToHook) and not isInList(name, itemsToSkip) or hasSmokableTag then
        print('Hooking: '..onEat..' -> '..hook)
        if not trueSmoking.isSmoking then trueSmoking.Smokable = Smokable:new(item, character) end
        item:setReplaceOnUse(nil) --nil this fields to avoid consuming the item 
        if modOnEat ~= hook then
            item:getModData().modOnEat = onEat
            item:setOnEat(hook)
        end

        --Stop stat changes from item use
        item:setStressChange(0)
        item:setBoredomChange(0)
        item:setUnhappyChange(0)
        item:setPainReduction(0)
        item:setHungChange(0)
        item:setThirstChange(0)
        item:setFatigueChange(0)
        item:setEnduranceChange(0)
        item:setReduceFoodSickness(0)

        o.item = item
        o.maxTime = TrueSmoking.lightTime;
    end

    return o
end

function ISEatFoodAction:isValid()
    if self.item:getOnEat() == nil or self.item:getOnEat() == '' then
        return originalActionIsValid(self)
    else
        return true
    end
end

function ISEatFoodAction:stop()
    if getActivatedMods():contains('\\SmokingSoundsOverhaul') and self.item:getModData().modOnEat
     and self.item:getModData().modOnEat ~= '' then
        self.trueSmoking.lightingEatSound = self.eatSound
        ISBaseTimedAction.stop(self);
        self.item:setJobDelta(0.0);
    else
        originalActionStop(self)
    end
end

function ISEatFoodAction:perform()
    if getActivatedMods():contains('\\SmokingSoundsOverhaul') and self.item:getModData().modOnEat
     and self.item:getModData().modOnEat ~= '' then
        self.trueSmoking.lightingEatSound = self.eatSound
        self.item:getContainer():setDrawDirty(true);
        self.item:setJobDelta(0.0);
        ISBaseTimedAction.perform(self);
    else
        originalActionPerform(self)
    end
end

function ISEatFoodAction:start()
    originalActionStart(self)
    if self.item:getOnEat() == 'OnEat_Hook' then
        local hasPrimary = self.character:getPrimaryHandItem() and self.character:getPrimaryHandItem():getStaticModel() or nil
        if hasPrimary then
            self:setOverrideHandModels(hasPrimary, self.item)
        else
            self:setOverrideHandModels(nil, self.item)
        end
    end
end