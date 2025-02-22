--[[
    Hook the complete method to mark when our mask actually equipped, this allows the keybind to try again
    if it was interrupted
]]
local originalComplete = ISWearClothing.complete
function ISWearClothing:complete()
    local rtn = originalComplete(self)
    local o = TrueSmoking:getPlayerReference(self.character)
    if self.item == o.mask then
        o.mask = false
    end
    return rtn
end

--[[
    Added in a time param, not really needed now as we can directly call setWornItem, will leave for now...
]]
local originalNew = ISWearClothing.new
function ISWearClothing:new(character, item, time)
    local o = originalNew(self, character, item)
    if time then o.maxTime = time end
    return o
end