require "TimedActions/ISClothingExtraAction"
ISClothingExtraAction = ISBaseTimedAction:derive("ISClothingExtraAction")
--[[
    Added time param
]]
local originalNew = ISClothingExtraAction.new
function ISClothingExtraAction:new(character, item, extra)
    local o = originalNew(self, character, item, extra)
    return o
end