local originalFunc = ISInventoryPaneContextMenu.onEatItems
if getActivatedMods():contains('\\P4TidyUpMeister') then
    function ISInventoryPaneContextMenu.onEatItems(items, percentage, player)
        items = ISInventoryPane.getActualItems(items)
        for i,item in ipairs(items) do
            if item:hasTag('Smokable') then
                ISInventoryPaneContextMenu.eatItem(item, percentage, player)
            else
                originalFunc(items, percentage, player)
            end
        end
    end
end