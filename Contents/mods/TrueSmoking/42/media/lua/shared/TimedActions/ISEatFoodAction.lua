require 'TimedActions/ISEatFoodAction'
ISEatFoodAction = ISBaseTimedAction:derive("ISEatFoodAction")

local originalActionNew = ISEatFoodAction.new
function ISEatFoodAction:new(character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:hasTag(ItemTag.SMOKABLE)
    local funcsToHook = { 'RecipeCodeOnEat.consumeNicotine',
        'OnEat_WeedSmoke', 'OnEat_WeedJoint', 'OnEat_WeedPipe', 'OnEat_HempCigarillo', 'OnEat_Tobacco', 'OnSmoke_Blunt', 'OnSmoke_Cannabis',
        'OnSmoke_CannaCigar', 'OnSmoke_Spliff', 'OnSmoke_Cigar','OnSmoke_Blunt' }

    o = originalActionNew(self, character, item, percentage)

    local table = TrueSmoking:getPlayerReference(character)

    if (TrueSmoking.isInList(onEat, funcsToHook) or hasSmokableTag) and not ISTimedActionQueue.hasActionType(character, 'LightSmoke') then
        print('TRUESMOKING::Checking item onEat: ' .. onEat)
        print('TRUESMOKING::Item ID: ' .. item:getID())

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

            return LightSmoke:new(character, item)
        end
    end

    return o
end