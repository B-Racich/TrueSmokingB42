local InventoryUI = require("Starlit/client/ui/InventoryUI")

local remainingSmokeTooltip = function(tooltip, layout, item)
    -- if item then item:syncItemModData() end
    if item and item:getModData().SmokeLength and item:getModData().OriginalSmokeLength then
        local current = item:getModData().SmokeLength
        local original = item:getModData().OriginalSmokeLength
        local amt = (current / original)
        amt = amt >= 0 and amt or 0

        InventoryUI.addTooltipBar(layout, "Remaining:", amt)
    end
end

InventoryUI.onFillItemTooltip:addListener(remainingSmokeTooltip)

local originalEatItem = ISInventoryPaneContextMenu.eatItem
ISInventoryPaneContextMenu.eatItem = function(item, percentage, player)
    if item:hasTag(ItemTag.SMOKABLE) then
        TrueSmoking:getModData(player).CheckMaskSmoking = true
    else
        TrueSmoking:getModData(player).CheckMaskSmoking = false
    end
    originalEatItem(item, percentage, player)
end

local originalGetEatingMask = ISInventoryPaneContextMenu.getEatingMask
ISInventoryPaneContextMenu.getEatingMask = function(playerObj, removeMask)
    local o = TrueSmoking:getModData(playerObj)

    --use native function to get blocking mask
    local mask = originalGetEatingMask(playerObj, false)

    if mask and mask:getFullType():contains('Shemagh') and mask:hasTag(TrueSmoking.registries.tag) and o.CheckMaskSmoking then
        o.shemagh = mask
        o.mask = false
        TrueSmoking:adjustShemagh(playerObj, mask, true)
    else --let the game handle it normally
        mask = originalGetEatingMask(playerObj, removeMask)
        o.mask = mask
        o.shemagh = false
    end

    --If we want to handle re-equipping tell the game we took nothing off
    if o.CheckMaskSmoking then
        return false
    end

    return mask
