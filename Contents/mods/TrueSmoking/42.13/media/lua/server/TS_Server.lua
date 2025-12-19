require 'TrueSmoking'
function TrueSmoking.onClientCommand(module, command, player, args)
    if module ~= 'TrueSmoking' then return end

    if command == 'equipSmokableItem' then
        local function getVisual(item)
            local OnEat_Defaults = {
                ['RecipeCodeOnEat.consumeNicotine'] = 'base.Mask_Cigarette',
            }

            local typeMatches = {
                ['smokingpipe'] = 'Mask_Pipe',
                ['joint'] = 'Mask_Cigarette',
                ['blunt'] = 'Mask_Cigarillo',
                ['spliff'] = 'Mask_Cigarillo',
                ['can'] = false,
                ['bong'] = false,
            }

            local itemType = item:getFullType():lower()
            print('Looking for ' .. itemType)

            for pattern, itemName in pairs(typeMatches) do
                if itemType:find(pattern) then
                    return itemName and instanceItem(itemName) or false
                end
            end

            for key, value in pairs(OnEat_Defaults) do
                if item:getOnEat() == key then return instanceItem(value) end
            end

            return false
        end

        if not TrueSmoking.Options.ManageHeadGear then return end
        local item = args[1]
        print('looking for ' .. item:getOnEat())
        local visual = getVisual(item)
        print('visual is ' .. tostring(visual))
        if not player:getWornItem(TrueSmoking.registries.mask) and visual then
            player:setWornItem(visual:getBodyLocation(), visual)
            -- triggerEvent('OnClothingUpdated', player)
        elseif player:getWornItem(TrueSmoking.registries.mask) then
            player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
            sendClientCommand(player, 'TrueSmoking', 'equipSmokableItem', { item })
        end
    end

    if command == 'removeSmokableItem' then
        if not TrueSmoking.Options.ManageHeadGear then return end
        if player:getWornItem(TrueSmoking.registries.mask) then
            player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
            -- triggerEvent('OnClothingUpdated',player)
        end
    end
end

Events.OnClientCommand.Add(TrueSmoking.onClientCommand)
