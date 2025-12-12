require 'TimedActions/ISBaseTimedAction'

TestSmoke = ISBaseTimedAction:derive('TestSmoke')

function TestSmoke:isValidStart()
    return true
end

function TestSmoke:isValid()
    if isClient() and self.item then
        return self.character:getInventory():containsID(self.item:getID());
    else
        return self.character:getInventory():contains(self.item);
    end
end

function TestSmoke:waitToStart()
    return false
end

function TestSmoke:update()
    -- if self.item:getEatType() then
    --     self:setAnimVariable('FoodType', self.item:getEatType());
    -- 	self:setActionAnim(CharacterActionAnims.Eat);
    -- end
end

function TestSmoke:start()
    print('TRUESMOKING::TestSmoke started')
    if self.item:getEatType() then
        self:setAnimVariable('FoodType', self.item:getEatType());
        self:setActionAnim(CharacterActionAnims.Eat);
    end
end

function TestSmoke:serverStart()
    print('TRUESMOKING::TestSmoke server started')
end

function TestSmoke:stop()
    ISBaseTimedAction.stop(self);
    print('TRUESMOKING::TestSmoke stopped')
end

function TestSmoke:serverStop()
    print('TRUESMOKING::TestSmoke server stopped')
end

function TestSmoke:perform()
    print('TRUESMOKING::TestSmoke performed')
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function TestSmoke:complete()
    print('TRUESMOKING::TestSmoke completed')
    self.smokable:start()
    ISBaseTimedAction.complete(self);
end

function TestSmoke:getDuration()
    return 200
end

function TestSmoke:new(character, item)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnWalk = false
    o.stopOnRun = true
    o.stopOnAim = true
    o.forceProgressBar = false

    o.table = TrueSmoking:getPlayerReference(character)
    o.smokable = o.table.Smokable

    o.character = character
    o.item = item

    o.maxTime = o:getDuration()

    return o
end
