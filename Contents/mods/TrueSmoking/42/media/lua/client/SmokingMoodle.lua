require 'MF_ISMoodle'

SmokingMoodle = SmokingMoodle or {}
SmokingMoodle.__index = SmokingMoodle

function SmokingMoodle:new(table, playerNum)
    local obj = {}
    setmetatable(obj, self)

    obj.table = table
    obj.playerNum = playerNum

    obj.moodleImage = TrueSmoking.Options.UseNewMoodle and 'smoking_new' or 'smoking_old'

    MF.createMoodle(obj.moodleImage)

    return obj
end

--Starts our moodle event
function SmokingMoodle:start()
    local function updateWrapper()
        self:update()
    end
    Events.OnTick.Add(updateWrapper)
    self.updateWrapper = updateWrapper
end

--Stops the moodle event and hides moodle
function SmokingMoodle:stop()
    local moodle = MF.getMoodle(self.moodleImage, self.playerNum)
    if moodle ~= nil then
        moodle:setValue(0.5)
    end
    if self.updateWrapper then
        Events.OnTick.Remove(self.updateWrapper)
        self.updateWrapper = nil
    end
end

--On tick event for the moodle to update
function SmokingMoodle:update()
    local moodle = MF.getMoodle(self.moodleImage,self.playerNum)
    if not self.table.isSmoking then return end
    if moodle == nil then return end
    local item = self.table.Smokable
    local smokeLit = item.smokeLit
    local percentVal = item.smokePercent
    local displayedPercentage = string.format('%.2f', percentVal * 100)

    local smokeLitText = smokeLit and 'lit' or 'out'

    moodle:setThresholds(0.10, 0.20, 0.35, 0.4999, 0.5001, 0.65, 0.85, 0.90)

    if not smokeLit then
        moodle:doWiggle()
    end
    moodle:setValue(percentVal)
    moodle:setDescription(moodle:getGoodBadNeutral(),moodle:getLevel(),getText('Moodles_smoking_Custom',smokeLitText, displayedPercentage))
end