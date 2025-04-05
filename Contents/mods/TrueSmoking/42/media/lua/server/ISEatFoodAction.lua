require 'TimedActions/ISEatFoodAction'

local originalActionNew = ISEatFoodAction.new
local originalActionStart = ISEatFoodAction.start
local originalActionComplete = ISEatFoodAction.complete

--Hook the ISEatFoodAction to grab smokable items and make our changes
function ISEatFoodAction:new(character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:getTags():contains('Smokable')
    local funcsToHook = { 'OnEat_Cigarettes', 'OnEat_Cigarillo', 'OnEat_Cigar',
        'OnEat_WeedSmoke', 'OnEat_WeedJoint', 'OnEat_WeedPipe', hook }

    o = originalActionNew(self, character, item, percentage)

    local table = TrueSmoking:getPlayerReference(character)
    o.table = table

    if isInList(onEat, funcsToHook) or hasSmokableTag then
        print('TRUESMOKING::Hooking: ' .. onEat .. ' -> ' .. hook)
        if not table.isSmoking then
            print('TRUESMOKING::Setting up smokable')
            local replace = item:getReplaceOnUseFullType()

            if replace and (replace ~= nil and replace ~= '') then
                print('TRUESMOKING::Has replace on use: ' .. replace)
                item:getModData().replaceOnUse = replace
                item:setReplaceOnUse(nil)
            end

            table.Smokable = Smokable:new(item, character)
            item:getModData().modOnEat = hook

            o.item = item
            o.maxTime = TrueSmoking.lightTime;
        end
    end

    return o
end

function ISEatFoodAction:complete()
    if self.item:getModData().modOnEat == 'OnEat_Hook' then
        self.table.Smokable:light()
        return true
    else
        originalActionComplete(self)
    end
    return true;
end

function ISEatFoodAction:start()
    originalActionStart(self)

    if self.item:getModData().modOnEat == 'OnEat_Hook' then
        if TrueSmoking.Config.HideAllActionBars then
            self.action:setUseProgressBar(false)
        end
        local hasPrimary = self.character:getPrimaryHandItem()
        if hasPrimary then
            self:setOverrideHandModels(hasPrimary, self.item)
        else
            self:setOverrideHandModels(nil, self.item)
        end
    end
end
