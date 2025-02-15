require 'TrueSmoking'

TrueSmoking = TrueSmoking or {}
TrueSmoking.ISWearClothing = TrueSmoking.ISWearClothing or {}

-- TrueSmoking.ISWearClothing.isValid = ISWearClothing.isValid
-- function ISWearClothing:isValidStart()
--     if self.item:getClothingItemName() == 'Hat_Cigarette' then
--         return true
--     else
--         return ISBaseTimedAction.isValidStart(self)
--     end
-- end

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

TrueSmoking.ISWearClothing.new = ISWearClothing.new
function ISWearClothing:new(character, item, time)
    local o = TrueSmoking.ISWearClothing.new(self, character, item)
    if time then o.maxTime = time end
    print('Inside Wear-New')
    return o
end