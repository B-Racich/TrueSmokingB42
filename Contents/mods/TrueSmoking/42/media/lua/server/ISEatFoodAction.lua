require 'TimedActions/ISEatFoodAction'

local originalActionNew = ISEatFoodAction.new
function ISEatFoodAction:new(character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:getTags():contains('Smokable')
    local funcsToHook = { 'OnEat_Cigarettes', 'OnEat_Cigarillo', 'OnEat_Cigar',
        'OnEat_WeedSmoke', 'OnEat_WeedJoint', 'OnEat_WeedPipe' }

    o = originalActionNew(self, character, item, percentage)

    local table = TrueSmoking:getPlayerReference(character)

    if (isInList(onEat, funcsToHook) or hasSmokableTag) then
        if not table.isSmoking then
            print('TRUESMOKING::Hooking: ' .. onEat)
            local replace = item:getReplaceOnUseFullType()

            if replace and (replace ~= nil and replace ~= '') then
                print('TRUESMOKING::Has replace on use: ' .. replace)
                item:getModData().replaceOnUse = replace
                item:setReplaceOnUse(nil)
            end

            print('TRUESMOKING::Setting up smokable')
            table.Smokable = Smokable:new(item, character)
            item:getModData().modOnEat = hook

            return LightSmoke:new(character)
        end
    end

    return o
end