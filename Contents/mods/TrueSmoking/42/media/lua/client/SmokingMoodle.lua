require 'MF_ISMoodle'

SmokingMoodle = SmokingMoodle or {}
SmokingMoodle.__index = SmokingMoodle

function SmokingMoodle:new(TrueSmoking, playerNum)
    local obj = {}
    setmetatable(obj, self)

    obj.TrueSmoking = TrueSmoking
    obj.playerNum = playerNum
    MF.createMoodle('smoking')
    -- print('create moodle')

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
    local moodle = MF.getMoodle('smoking',self.playerNum)
    if moodle ~= nil then
        moodle:setValue(0.5)
        moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/notSmoking.png'))
    end
    if self.updateWrapper then
        Events.OnTick.Remove(self.updateWrapper)
        self.updateWrapper = nil
    end
end

--On tick event for the moodle to update
function SmokingMoodle:update()
    local moodle = MF.getMoodle('smoking',self.playerNum)
    if not self.TrueSmoking.isSmoking then return end
    if moodle == nil then return end
    local item = self.TrueSmoking.Smokable
    local smokeLit = item.smokeLit
    local percentVal = item.smokePercent
    local displayedPercentage = string.format('%.2f', percentVal * 100)

    local smokeLitText = smokeLit and 'lit' or 'out'

    moodle:setThresholds(0.10, 0.20, 0.35, 0.4999, 0.5001, 0.65, 0.85, 0.90)

    if smokeLit then
        moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/smoking.png'))
    else
        moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/notSmoking.png'))
        moodle:doWiggle()
    end
    moodle:setValue(percentVal)
    moodle:setDescription(moodle:getGoodBadNeutral(),moodle:getLevel(),getText('Moodles_smoking_Custom',smokeLitText, displayedPercentage))
    moodle:setBackground(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/bg.png'))
end