function TrueSmoking.onClientCommand(module, command, playerRaw, args)
    if module ~= 'TrueSmoking' then return end

    local player = false
    if not isClient() and not isServer() then
        player = playerRaw
    else
        player = getPlayerByOnlineID(playerRaw:getOnlineID())
    end

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
        local type = item:getFullType()

        local types = {
            ['Base.CigaretteSingle'] = 'Base.Mask_Cigarette',
            ['Base.CigaretteRolled'] = 'Base.Mask_Cigarette',
            ['Base.Cigarillo'] = 'Base.Mask_Cigarillo',
            ['Base.Cigar'] = 'Base.Mask_Cigar',
            ['Base.SmokingPipe_Tobacco'] = 'Base.Mask_Pipe',
        }

        visual = (types[type] and instanceItem(types[type]) or false)

        if not player:getWornItem(TrueSmoking.registries.mask) and visual then
            player:setWornItem(visual:getBodyLocation(), visual)
            triggerEvent('OnClothingUpdated', player)
        elseif player:getWornItem(TrueSmoking.registries.mask) then
            player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
            triggerEvent('OnClothingUpdated', player)
            sendClientCommand(player, 'TrueSmoking', 'equipSmokableItem', { item })
        end
    end

    if command == 'removeVisualItem' then
        local ts = args[1] or false
        if not ts then return end
        if not ts.ManageHeadGear then return end
        if player:getWornItem(TrueSmoking.registries.mask) then
            player:removeWornItem(player:getWornItem(TrueSmoking.registries.mask))
            triggerEvent('OnClothingUpdated', player)
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
        sendAddItemToContainer(player:getInventory(), smokable)
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

    if command == 'updatePlayerNicData' then
        local data = args[1]
        for key, value in pairs(data) do
            if not player:getModData().nicotineSystem then
                player:getModData().nicotineSystem = {}
            end
            player:getModData().nicotineSystem[key] = value
        end
        player:transmitModData()
    end

    if command == 'smokeNicotine' then
        local rawAmountPerPuff = args[1]
        local nicotineContent = args[2]
        local config = args[3]
        -- NicotineSystem:smoke(player, nicotineAmount, maxNicotine)

        local data = player:getModData().nicotineSystem
        if not data then return end

        local maxAddiction = 100
        local puffFraction = rawAmountPerPuff / nicotineContent

        local tolerance = math.min(data.addictionLevel / 100, 0.25)
        local effectiveIntake = rawAmountPerPuff * (1.0 - tolerance)

        if data.nicotineLevel > 70 then
            local reduction = (data.nicotineLevel - 70) / 50
            effectiveIntake = effectiveIntake * (1 - math.min(reduction, 0.65))
        end

        if data.nicotineLevel + effectiveIntake > 100 then
            local overflow = (data.nicotineLevel + effectiveIntake) - 100
            data.nicotineOverflow = data.nicotineOverflow + overflow
            data.nicotineLevel = 100
        else
            data.nicotineLevel = data.nicotineLevel + effectiveIntake
        end

        data.withdrawalLevel = math.max(0, data.withdrawalLevel - config.WITHDRAWAL_RELIEF_PER_PUFF * puffFraction)

        local addictionTolerance = data.addictionLevel / maxAddiction
        local effectiveGain = config.ADDICTION_GAIN_PER_PUFF * puffFraction *
            (1.0 - math.min(addictionTolerance * 0.85, 0.85))

        data.addictionLevel = math.min(maxAddiction, data.addictionLevel + effectiveGain)
        player:transmitModData()
        -- sendClientCommand(player, 'TrueSmoking', 'updatePlayerNicData', { data })
    end
end

Events.OnClientCommand.Add(TrueSmoking.onClientCommand)
