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
   Added a time param and check for putting out smoke on equipping headgear
]]
local originalNew = ISWearClothing.new
function ISWearClothing:new(character, item, time)
    local o = originalNew(self, character, item)
    if time then o.maxTime = time end

    local smokableBlacklist = {
        Mask = true,
        MaskEyes = true,
        MaskFull = true,
        FullHat = true,
        FullSuitHead = true,
        SCBA = true,
        SCBAnotank = true
    }

    local playerRef = TrueSmoking:getPlayerReference(character)

    print('Checking if we need to put out the smokable')
    print(item:getBodyLocation())
    print(item:getTags())
    if smokableBlacklist[item:getBodyLocation()] and not item:hasTag("CanEat") and playerRef.isSmoking then
        print('Putting out the smokable')
        playerRef.Smokable:putOut()
    end

    return o
end