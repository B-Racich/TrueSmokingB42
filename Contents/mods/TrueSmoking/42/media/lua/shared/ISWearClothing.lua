require 'TrueSmoking'

TrueSmoking = TrueSmoking or {}
TrueSmoking.ISWearClothing = TrueSmoking.ISWearClothing or {}

--[[
    Hook the complete method to mark when our mask actually equipped, this allows the keybind to try again
    if it was interrupted
]]
TrueSmoking.ISWearClothing.complete = ISWearClothing.complete
function ISWearClothing:complete()
    local rtn = TrueSmoking.ISWearClothing.complete(self)
    local o = TrueSmoking:getPlayerReference(self.character)
    if self.item == o.mask then
        o.mask = false
    end
    print('Inside Wear-complete')
    return rtn
end

--[[
    Added in a time param, not really needed now as we can directly call setWornItem, will leave for now...
]]
TrueSmoking.ISWearClothing.new = ISWearClothing.new
function ISWearClothing:new(character, item, time)
    local o = TrueSmoking.ISWearClothing.new(self, character, item)
    if time then o.maxTime = time end
    print('Inside Wear-New')
    return o
end