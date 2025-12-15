require "TimedActions/ISClothingExtraAction"

require "TimedActions/ISWearClothing"

require "TimedActions/ISUnequipAction"

require 'TimedActions/ISEatFoodAction'

require 'TimedActions/ISTakePillAction'

local originalActionNew = ISTakePillAction.new
function ISTakePillAction:new(character, item)
 local o = {}
    local onEat = item:getOnEat() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:hasTag(ItemTag.SMOKABLE)
    local funcsToHook = { 'cigarettes', 'RecipeCodeOnEat.consumeNicotine', 'OnEat_Cigarettes', 'OnEat_Cigarillo', 'OnEat_Cigar',
        'OnEat_WeedSmoke', 'OnEat_WeedJoint', 'OnEat_WeedPipe', 'OnEat_HempCigarillo', 'OnEat_Tobacco', 'OnEat_Weed' }

    o = originalActionNew(self, character, item)

    local table = TrueSmoking:getPlayerReference(character)

    if (TrueSmoking.isInList(onEat, funcsToHook) or hasSmokableTag) and not ISTimedActionQueue.hasActionType(character, 'LightSmoke') then
        print('TRUESMOKING::Checking item onEat: ' .. onEat)
        print('TRUESMOKING::Item ID: ' .. item:getID())
        if not table.isSmoking then
            print('TRUESMOKING::Hooking: ' .. onEat)
            local replace = item:getReplaceOnUseFullType()

            if replace and (replace ~= nil and replace ~= '') then
                print('TRUESMOKING::Has replace on use: ' .. replace)
                item:getModData().replaceOnUse = replace
                item:setReplaceOnUse(nil)
            end

            print('TRUESMOKING::Setting up smokable')
            table.Smokable = Smokable:new(item, character)
            item:getModData().modOnEat = hook

            return LightSmoke:new(character, item, table.Smokable)
        end
    end

    return o
end

local originalActionNew = ISEatFoodAction.new
function ISEatFoodAction:new(character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:hasTag(ItemTag.SMOKABLE)
    local funcsToHook = { 'RecipeCodeOnEat.consumeNicotine',
        'OnEat_WeedSmoke', 'OnEat_WeedJoint', 'OnEat_WeedPipe', 'OnEat_HempCigarillo', 'OnEat_Tobacco', 'OnSmoke_Blunt', 'OnSmoke_Cannabis',
        'OnSmoke_CannaCigar', 'OnSmoke_Spliff', 'OnSmoke_Cigar','OnSmoke_Blunt' }

    o = originalActionNew(self, character, item, percentage)

    local table = TrueSmoking:getPlayerReference(character)

    if (TrueSmoking.isInList(onEat, funcsToHook) or hasSmokableTag) and not ISTimedActionQueue.hasActionType(character, 'LightSmoke') then
        print('TRUESMOKING::Checking item onEat: ' .. onEat)
        print('TRUESMOKING::Item ID: ' .. item:getID())

        if not table.isSmoking then
            print('TRUESMOKING::Hooking: ' .. onEat)
            local replace = item:getReplaceOnUseFullType()

            if replace and (replace ~= nil and replace ~= '') then
                print('TRUESMOKING::Has replace on use: ' .. replace)
                item:getModData().replaceOnUse = replace
                item:setReplaceOnUse(nil)
            end

            print('TRUESMOKING::Setting up smokable')
            item:getModData().modOnEat = hook

            return LightSmoke:new(character, item, table.Smokable)
        end
    end

    return o
end

--[[
    Add instant equip time for the visual smoke
]]
local originalNew = ISUnequipAction.new
function ISUnequipAction:new(character, item, maxTime)
    local o = originalNew(self, character, item, maxTime)

    local playerRef = TrueSmoking:getPlayerReference(character)

    if item:getBodyLocation() == TrueSmoking.registries.mask and playerRef.isSmoking then
        o.maxTime = 1
    end

    return o
end

--[[
    If the player somehow unequips the visual smoke we need to put the smoke out
]]
local originalComplete = ISUnequipAction.complete
function ISUnequipAction:complete()
    originalComplete(self)

    local playerRef = TrueSmoking:getPlayerReference(self.character)

    if self.item:getBodyLocation() == TrueSmoking.registries.mask and playerRef.isSmoking then
        playerRef.Smokable:putOut()
    end

    return true
end


--[[
    Hook the complete method to mark when our mask actually equipped, this allows the keybind to try again
    if it was interrupted
]]
local originalComplete = ISWearClothing.complete
function ISWearClothing:complete()
    local rtn = originalComplete(self)
    local table = TrueSmoking:getPlayerReference(self.character)
    if self.item == table.mask then
        table.mask = false
    end
    return rtn
end

--[[
   Added a time param and check for putting out smoke on equipping headgear
]]
local originalNew = ISWearClothing.new
function ISWearClothing:new(character, item)
    local o = originalNew(self, character, item)

    local smokableBlacklist = {
        Mask = true,
        MaskEyes = true,
        MaskFull = true,
        FullHat = true,
        FullSuitHead = true,
        SCBA = true,
        SCBAnotank = true
    }

    local table = TrueSmoking:getPlayerReference(character)

    if smokableBlacklist[item:getBodyLocation()] and not item:hasTag(ItemTag.CAN_EAT) and table.isSmoking then
        table.Smokable:putOut()
    end

    return o
end

local originalNew = ISClothingExtraAction.new
function ISClothingExtraAction:new(character, item, extra)
    local o = originalNew(self, character, item, extra)
    return o
end