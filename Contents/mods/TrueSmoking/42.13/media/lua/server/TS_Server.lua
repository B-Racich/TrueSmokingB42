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

    if command == 'OnEat_ItemStats' then
        local stats = args[1]
        local puffPercent = args[2]
        TrueSmoking.OnEat_ItemStats(player, stats)
    end

    if command == 'OnEat_Tobacco' then
        local stats = args[1]
        local puffPercent = args[2]
        TrueSmoking.OnEat_Tobacco(player, stats)
    end

    if command == 'updateStats' then
        local stats = args[1]

        for statName, value in pairs(stats) do
            if player:getStats():get(CharacterStat[statName]) then
                player:getStats():set(CharacterStat[statName], value)
            end
        end
    end

    if command == 'addTrait' then
        local traitName = args[1]
        if not player:HasTrait(traitName) then
            player:getCharacterTraits():add(traitName)
        end
    end

    if command == 'removeTrait' then
        local traitName = args[1]
        if player:HasTrait(traitName) then
            player:getCharacterTraits():remove(traitName)
        end
    end

    if command == 'addSmokable' then
        local itemName = args[1]
        local data = args[2] or false
        local smokable = player:getInventory():AddItem(itemName)
        if smokable and data then
            smokable:getModData().SmokeLength = data.SmokeLength
        end
        -- syncItemModData(smokable)
        sendAddItemToContainer(player:getInventory(),smokable)

    end

    -- if command == 'removeSmokable' then
    --     local itemName = args[1]
    --     local item = player:getInventory():Remove(itemName)
    --     sendRemoveItemFromContainer(player:getInventory(),item)
    -- end

    if command == 'smokableCallback' then
        local callback = args[1]
        local smokable = args[2]
        if callback and type(callback) == 'function' then
            callback(player, smokable)
        end
    end
end

Events.OnClientCommand.Add(TrueSmoking.onClientCommand)
