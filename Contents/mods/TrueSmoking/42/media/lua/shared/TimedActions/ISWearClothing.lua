require "TimedActions/ISWearClothing"
ISWearClothing = ISBaseTimedAction:derive("ISWearClothing")
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