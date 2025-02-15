require 'TrueSmoking'

TrueSmoking = TrueSmoking or {}
TrueSmoking.ISWearClothing = TrueSmoking.ISWearClothing or {}

TrueSmoking.ISWearClothing.complete = ISWearClothing.complete
function ISWearClothing:complete()
    local rtn = TrueSmoking.ISWearClothing.complete(self)
    local o = TrueSmoking:getPlayerReference(self.character)
    if self.item == o.mask then
        o.mask = false
    end
    return rtn
end

TrueSmoking.ISWearClothing.new = ISWearClothing.new
function ISWearClothing:new(character, item)
    local o = TrueSmoking.ISWearClothing.new(self, character, item)
    print('dirty nasty item')
    -- local str = item:getClothingItem()
    -- local name = string.match(str, "Name:(%w+)")
    print(item:getClothingItemName())
    if item:getClothingItemName() == 'Hat_Cigarette' then
        print('returning 1')
        o.maxTime = 1
    end
    return o
end