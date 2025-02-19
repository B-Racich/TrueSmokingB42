if getActivatedMods():contains('\\IMightNeedALighter') then
    function IsStoveSmoking:new(character, worldobject, item, time)
        return ISEatFoodAction:new(character, item, 1)
    end
end