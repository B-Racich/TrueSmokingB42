local InventoryUI = require('Starlit/client/ui/InventoryUI')

local remainingSmokeTooltip = function(tooltip, layout, item)
    if item and item:getModData().SmokeLength and item:getModData().OriginalSmokeLength then
        local current = item:getModData().SmokeLength
        local original = item:getModData().OriginalSmokeLength
        local amt = (current / original)
        amt = amt >= 0 and amt or 0

        InventoryUI.addTooltipBar(layout, 'Remaining:', amt)
    end
end

InventoryUI.onFillItemTooltip:addListener(remainingSmokeTooltip)