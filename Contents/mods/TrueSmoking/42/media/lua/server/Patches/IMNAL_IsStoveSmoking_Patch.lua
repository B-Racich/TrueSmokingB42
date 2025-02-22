if getActivatedMods():contains('\\IMightNeedALighter') then
    function OnStoveSmoking(_player, stove, _cigarette)
        ISWorldObjectContextMenu.Test = true

        --We need to make sure the clicked player is still smoking
        if instanceof(stove, 'IsoPlayer') then
            if not string.match(stove:getAnimationDebug(), "foodtype : Cigarettes") then return end
        end

        --Do we need to transfer cigarette from a bag first ?
        if luautils.walkAdj(_player, stove:getSquare(), true) then
            if _cigarette:getContainer() ~= _player:getInventory() then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(_player, _cigarette, _cigarette:getContainer(),
                    _player:getInventory(), 5))
            end
        end

        --This is where we calculate the length of the timed action and outcome
        local outcome = DeterminateStoveSmokingOutcome(_player, stove, _cigarette)

        --Let's light what we've found
        if luautils.walkAdj(_player, stove:getSquare(), true) then
            if instanceof(stove, 'IsoStove') and not stove:isMicrowave() then
                ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                    SandboxVars.IMNAL.stoveBaseTimer / outcome))
            elseif instanceof(stove, 'IsoStove') and stove:isMicrowave() then
                ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                    SandboxVars.IMNAL.microwaveBaseTimer / outcome))
            elseif instanceof(stove, 'IsoFireplace') and stove:isLit() then
                ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                    SandboxVars.IMNAL.fireplaceBaseTimer / outcome))
            elseif instanceof(stove, 'IsoBarbecue') and stove:isLit() then
                ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                    SandboxVars.IMNAL.barbecueBaseTimer / outcome))
            elseif instanceof(stove, "IsoObject") and stove:getSpriteName() == "camping_01_5" then
                ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                    SandboxVars.IMNAL.campingBaseTimer / outcome))
            elseif stove:getSquare():haveFire() then
                ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                    SandboxVars.IMNAL.fireBaseTimer / outcome))
            else
                for i = 0, stove:getSquare():getMovingObjects():size() - 1 do
                    local o = stove:getSquare():getMovingObjects():get(i)
                    if instanceof(o, "IsoPlayer") and (o ~= playerObj) then
                        if string.match(o:getAnimationDebug(), "foodtype : Cigarettes") then
                            ISTimedActionQueue.add(IsStoveLighting:new(_player, stove, _cigarette, outcome,
                                SandboxVars.IMNAL.playerBaseTimer / outcome))
                        end
                    end
                end
            end
        end

        --Now it's lit, let's smoke it
        if luautils.walkAdj(_player, stove:getSquare(), true) then
            ISInventoryPaneContextMenu.eatItem(_cigarette, 1, _player:getPlayerNum())
        end
    end
end
