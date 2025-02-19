if getActivatedMods():contains('\\NoLighterNeeded') then
    function IsStoveSmoking:new(character, worldobject, item, item)
        return ISEatFoodAction:new(character, item, 1)
    end
end
