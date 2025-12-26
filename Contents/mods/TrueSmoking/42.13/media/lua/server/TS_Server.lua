function TrueSmoking.onClientCommand(module, command, playerRaw, args)
    if module ~= 'TrueSmoking' then return end

    local player = false
    if not isclient and not isServer() then player = playerRaw
    else player = getPlayerByOnlineID(playerRaw:getOnlineID()) end

    if command == 'equipVisualItem' then
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

        local ts = args[2] or false
        if not ts then return end

        if not ts.ManageHeadGear then return end
        local item = args[1]
        print('looking for ' .. item:getOnEat())
        local visual = getVisual(item)
        print('visual is ' .. tostring(visual))
        if not player:getWornItem(TrueSmoking.registries.mask) and visual then
            player:setWornItem(visual:getBodyLocation(), visual)
            triggerEvent('OnClothingUpdated', player)
        elseif player:getWornItem(TrueSmoking.registries.mask) then
            player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
            sendClientCommand(player, 'TrueSmoking', 'equipSmokableItem', { item })
        end
    end

    if command == 'removeVisualItem' then
        local ts = args[1] or false
        if not ts then return end
        if not ts.ManageHeadGear then return end
        if player:getWornItem(TrueSmoking.registries.mask) then
            player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
            triggerEvent('OnClothingUpdated',player)
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
        -- syncItemModData(player, smokable)
        sendAddItemToContainer(player:getInventory(),smokable)

    end

    if command == 'updatePlayerData' then
        local data = args[1]
        for key, value in pairs(data) do
            if not player:getModData().TrueSmoking then
                player:getModData().TrueSmoking = {}
            end
            player:getModData().TrueSmoking[key] = value
        end
        player:transmitModData()
    end

    if command == 'updateItemData' then
        local item = args[1]
        local data = args[2]
        for k, v in pairs(data) do
            item:getModData()[k] = v
        end
        -- syncItemModData(player, item)
    end
end

Events.OnClientCommand.Add(TrueSmoking.onClientCommand)
