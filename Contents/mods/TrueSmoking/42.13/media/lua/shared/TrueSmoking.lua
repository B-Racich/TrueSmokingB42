require 'ISUI/ISInventoryPaneContextMenu'
require 'Utils'

TrueSmoking = TrueSmoking or {}
TrueSmoking.__index = TrueSmoking
TrueSmoking.Options = TrueSmoking.Options or {}
TrueSmoking.HotkeySmokes = TrueSmoking.HotkeySmokes or {}
TrueSmoking.HotkeyPacks = TrueSmoking.HotkeyPacks or {}
TrueSmoking.SmokableObjects = TrueSmoking.SmokableObjects or {}
TrueSmoking.Callbacks = TrueSmoking.Callbacks or {}
-- TrueSmoking.Config = require 'Configuration/ModOptions'
--To support splitscreen we need to store each player seperately
TrueSmoking.Player_1 = TrueSmoking.Player_1 or {}
TrueSmoking.Player_2 = TrueSmoking.Player_2 or {}
TrueSmoking.Player_3 = TrueSmoking.Player_3 or {}
TrueSmoking.Player_4 = TrueSmoking.Player_4 or {}

local tsDebug = TrueSmoking.tsDebug

-- local originalGetEatingMask = ISInventoryPaneContextMenu.getEatingMask
-- local originalEatItem = ISInventoryPaneContextMenu.eatItem

function TrueSmoking:setHotkeySmokes(list)
    for _, item in ipairs(list) do
        table.insert(self.HotkeySmokes, item)
    end
end

function TrueSmoking:setHotkeyPacks(table)
    for key, item in pairs(table) do
        self.HotkeyPacks[key] = item
    end
end

function TrueSmoking:setCallback(func)
    table.insert(self.Callbacks, func)
end

function TrueSmoking:setSmokableObjects(table)
    for key, value in pairs(table) do
        self.SmokableObjects[key] = value
    end
end

function TrueSmoking:hasRequiredItem(smokable, player)
    if not smokable:getRequireInHandOrInventory() then
        return true
    end

    local types = smokable:getRequireInHandOrInventory()
    local typesTable = {}
    for i = 1, types:size() do
        typesTable[moduleDotType(smokable:getModule(), types:get(i - 1))] = true
    end

    local lightSource = false

    if player:getVehicle() and player:getVehicle():canLightSmoke(player) then lightSource = true end
    if not lightSource then
        lightSource = ISInventoryPaneContextMenu.hasOpenFlame(player)
    end

    local function predicateNotEmpty(item)
        -- return item:getCurrentUsesFloat() > 0 and ((item:getCurrentUsesFloat() - item:getUseDelta()) > 0)
        return item:getCurrentUsesFloat() > 0
    end

    if not lightSource then
        if not lightSource then
            local items = player:getInventory():getItems()
            for j = 1, items:size() do
                if typesTable[items:get(j - 1):getFullType()] and predicateNotEmpty(items:get(j - 1)) then
                    lightSource = items:get(j - 1)
                    break
                end
            end
        end
        -- Then check recurse in other containers
        if not lightSource then
            for v, _ in pairs(typesTable) do
                lightSource = player:getInventory():getFirstTypeRecurse(v)
                if lightSource and predicateNotEmpty(lightSource) then
                    break
                end
            end
        end
    end

    return lightSource
end

function TrueSmoking:getShemagh(player, reCover)
    local o = self:getModData(player)
    local items = {}
    items['FullHat'] = player:getWornItem('FullHat') or ''
    items['Hat'] = player:getWornItem('Hat') or ''
    items['Neck'] = player:getWornItem('Neck') or ''
    -- New Locations 42.9
    items['Scarf'] = player:getWornItem('Scarf') or ''
    items['Mask'] = player:getWornItem('Mask') or ''
    for _, item in pairs(items) do
        if item ~= '' then
            local type = item:getFullType()
            if item:hasTag('TrueSmoking:CantSmoke') then
                if type:contains('Shemagh') then
                    o.shemagh = item
                    return item
                end
            elseif reCover and type:contains('Shemagh') then
                o.shemagh = item
                return item
            end
        end
    end
    return false
end

function TrueSmoking:adjustShemagh(player, item, putDown)
    local fullCovers = {
        ['Base.Hat_ShemaghFull'] = 'Base.Hat_ShemaghFace',
        ['Base.Hat_ShemaghFull_Green'] = 'Base.Hat_ShemaghFace_Green',
        ['Base.Hat_ShemaghFull_Cotton'] = 'Base.Hat_ShemaghFace_Cotton',
        ['Base.Hat_ShemaghFull_Burlap'] = 'Base.Hat_ShemaghFace_Burlap',
    }
    local scarfCovers = {
        ['Base.ShemaghScarfFace'] = 'Base.ShemaghScarf',
        ['Base.ShemaghScarfFace_Green'] = 'Base.ShemaghScarf_Green',
    }
    local fullType = item:getFullType() or ''

    -- print(string.format('Fulltype of shemagh: %s',fullType))

    local function handleCovers(covers)
        for covered, open in pairs(covers) do
            local setTo = putDown and open or covered
            if (fullType == covered and putDown) or (fullType == open and not putDown) then
                print(string.format('TRUESMOKING::Adjusted Shegmah: %s - putDown: %s - setTo: %s', fullType,
                    putDown and 'true' or 'false', setTo))
                ISTimedActionQueue.add(ISClothingExtraAction:new(player, item, setTo))
                return true
            end
        end
        return false
    end

    if handleCovers(fullCovers) then return end
    handleCovers(scarfCovers)
end

function TrueSmoking:checkForMaskAndEquip(player)
    local o = self:getModData(player)
    if o.mask then
        self:equipItem(player, o.mask, 50)
    end
    if o.shemagh then
        o.shemagh = self:getShemagh(player, true)
        if o.shemagh then
            self:adjustShemagh(player, o.shemagh, false)
        end
    end
end

function TrueSmoking:removeItem(player, item, time)
    ISTimedActionQueue.add(ISUnequipAction:new(player, item))
end

function TrueSmoking:equipItem(player, item, time)
    ISTimedActionQueue.add(ISWearClothing:new(player, item))
end

function TrueSmoking:getModData(player)
    local num = player
    if type(player) ~= 'number' then
        num = player:getPlayerNum()
    end

    if not num or not getSpecificPlayer(num) then
        tsDebug('getModData - Invalid player number: ' .. tostring(num))
        return
    end
    -- print('TRUESMOKING::Getting player reference for player num: ' .. tostring(num))
    local md = getSpecificPlayer(num):getModData()
    if md and not md.TrueSmoking then
        tsDebug('getModData - Creating new TrueSmoking modData for player num: ' .. num)
        md.TrueSmoking = {}
    end

    return md.TrueSmoking
end

function TrueSmoking:getPlayerReference(player)
local num = player
    if type(player) ~= 'number' then
        num = player:getPlayerNum()
    end

    if num == 0 then
        return TrueSmoking.Player_1
    elseif num == 1 then
        return TrueSmoking.Player_2
    elseif num == 2 then
        return TrueSmoking.Player_3
    elseif num == 3 then
        return TrueSmoking.Player_4
    end
end

function TrueSmoking:useRecipe(item, player, recipeString)
    local containers = ISInventoryPaneContextMenu.getContainers(player)
    local recipes = CraftRecipeManager.getUniqueRecipeItems(item, player, containers)
    if recipes and recipes:size() > 0 then
        local recipe = recipes:get(0)
        local name = recipe:getName()
        if string.match(name, 'Take') then
            ISInventoryPaneContextMenu.OnNewCraft(item, recipe, player:getPlayerNum(), false)
        end
    end
end

function TrueSmoking:findSmokable(player)
    local itemData = {
        ['packed'] = {
            ['favorite'] = {},
            ['nonfavorite'] = {}
        },
        ['smokable'] = {
            ['favorite'] = {},
            ['nonfavorite'] = {}
        }
    }

    -- for index, value in ipairs(self.HotkeyPacks) do
    --     table.insert(itemData.packed.nonfavorite, value)
    -- end

    -- for index, value in ipairs(self.HotkeySmokes) do
    --     table.insert(itemData.smokable.nonfavorite, value)
    -- end

    local function processInventory(inv)
        local items = inv:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            -- print('TRUESMOKING::Checking item: ' .. item:getFullType())
            -- print('TRUESMOKING::Tags: ' .. item:getTags())
            if (item:hasTag(ItemTag.SMOKABLE)) and not item:hasTag(ItemTag.PACKED) then
                -- print('TRUESMOKING::Found Smokable: ' .. item:getFullType())
                if item:isFavorite() then
                    table.insert(itemData.smokable.favorite, item)
                else
                    table.insert(itemData.smokable.nonfavorite, item)
                end
            elseif item:hasTag(ItemTag.PACKED) then
                -- print('TRUESMOKING::Found Pack: ' .. item:getFullType())
                if item:isFavorite() then
                    table.insert(itemData.packed.favorite, item)
                else
                    table.insert(itemData.packed.nonfavorite, item)
                end
            end
        end
    end

    -- Process main inventory
    processInventory(player:getInventory())

    -- Process worn container inventories (e.g., bags, fanny packs)
    local wornItems = player:getWornItems()
    for i = 0, wornItems:size() - 1 do
        local wornItem = wornItems:get(i).item
        if wornItem and wornItem:IsInventoryContainer() then
            local containerInv = wornItem:getInventory()
            if containerInv then
                processInventory(containerInv)
            end
        end
    end

    --[[
    for i, v in ipairs(itemData.packed.favorite) do
        print('Packed Favorite:', v:getFullType())
    end
    for i, v in ipairs(itemData.packed.nonfavorite) do
        print('Packed Nonfavorite:', v:getFullType())
    end
    for i, v in ipairs(itemData.smokable) do
        print('Smokable:', v:getFullType())
    end
    --]]

    local cigarette = itemData.smokable.nonfavorite[1] or false
    local pack = itemData.packed.favorite[1] or itemData.packed.nonfavorite[1] or false
    local hasFavCig = itemData.smokable.favorite[1] or false
    local hasFavPack = itemData.packed.favorite[1] or false

    if hasFavCig and self:hasRequiredItem(hasFavCig, player) then
        print('TRUESMOKING::Using Favorite Cigarette')
        ISInventoryPaneContextMenu.eatItem(hasFavCig, 1, player:getPlayerNum())
    end

    if not hasFavCig and hasFavPack then
        print('TRUESMOKING::Using Favorite Pack to get Cigarette')
        self:useRecipe(hasFavPack, player, '')
    elseif not hasFavCig and not hasFavPack and not cigarette and pack then
        print('TRUESMOKING::Using Pack to get Cigarette')
        self:useRecipe(pack, player, 'TakeACigarette')
    end

    if cigarette and self:hasRequiredItem(cigarette, player) then
        print('TRUESMOKING::Using Cigarette')
        ISInventoryPaneContextMenu.eatItem(cigarette, 1, player:getPlayerNum())
        -- local table = TrueSmoking:getModData(player)
        -- table.Smokable = Smokable:new(cigarette, player)
        -- ISTimedActionQueue.add(TestSmoke:new(player, cigarette))
    end
end

function TrueSmoking:onKeyStartPressed(key)
    -- print(string.format('TRUESMOKING::KEY PRESSED - %s',key))
    local o = self:getModData(0)
    local player = getSpecificPlayer(0) -- Player_0 is always keyboard
    local ts = TrueSmoking:getPlayerReference(0)
    if player then
        if o.isSmoking and ts.Smokable.smokeLit and key == self.Config.keySmoke then
            ts.Smokable:puff()
        elseif o.isSmoking and not ts.Smokable.smokeLit and key == self.Config.keySmoke then
            -- o.isSmoking = false
            -- o.Smokable.smokeLit = false
            ts.Smokable:light()
        elseif self.Config.FindSmoke and not o.isSmoking and key == self.Config.keySmoke then
            print('TRUESMOKING::Find Smokable')
            self:findSmokable(player)
        elseif o.isSmoking and key == self.Config.keyStopSmoke then
            ts.Smokable:putOut()
        elseif not o.isSmoking and key == self.Config.keyStopSmoke and o.mask and self.Options.ManageHeadGear then
            self:equipItem(player, o.mask, false)
        end
    end
end

function TrueSmoking:toggleSmokeMenuOption(player, context, items)
    for i, v in ipairs(items) do
        local item = v
        local smokable = nil

        local o = self:getModData(player)

        if not instanceof(v, 'InventoryItem') then item = v.items[1] end

        smokable = context:getOptionFromName(getText('ContextMenu_Smoke'))
        if smokable then
            if o.isSmoking or not self:hasRequiredItem(item, getSpecificPlayer(player)) then
                smokable.notAvailable = true
            elseif not o.isSmoking and self:hasRequiredItem(item, getSpecificPlayer(player)) then
                smokable.notAvailable = false
            end
        end
    end
end

TrueSmoking.start = function(playerNum, player)
    local o = TrueSmoking:getModData(player)
    local ts = TrueSmoking:getPlayerReference(player)

    o.eatSound = ''
    o.lightingEatSound = ''

    ts.Smokable = {}
    ts.Smokable.smokeLit = false

    -- 460 is vanilla
    TrueSmoking.lightTime = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 460 or 220

    local function keyWrapper(key)
        TrueSmoking:onKeyStartPressed(key)
    end
    ts.keyWrapper = keyWrapper

    local function contextWrapper(player, context, items)
        TrueSmoking:toggleSmokeMenuOption(player, context, items)
    end
    ts.contextWrapper = contextWrapper

    if player:getModData().Smokable then
        local itemName = player:getModData().Smokable[1]
        -- local smokable = player:getInventory():AddItem(player:getModData().Smokable[1])
        local data = { SmokeLength = player:getModData().Smokable[2] }
        sendClientCommand(player, 'TrueSmoking', 'addSmokable', { itemName, data })
        -- if smokable then
        --     smokable:getModData().SmokeLength = player:getModData().Smokable[2]
        -- end
        player:getModData().Smokable = false
    end

    if TrueSmoking.Options.UseNicotineSystem then
        NicotineSystem:initialize(player)
        NicotineSystem:UpdateDynamicConfig(player)

        local function nicotineGameTimeWrapper()
            NicotineSystem:GameTimeUpdate(player)
        end
        Events.EveryOneMinute.Add(nicotineGameTimeWrapper)
        o.NicotineGameTimeWrapper = nicotineGameTimeWrapper
    end

    o.isSmoking = false

    player:transmitModData()
    Events.OnKeyStartPressed.Add(ts.keyWrapper)
    Events.OnFillInventoryObjectContextMenu.Add(ts.contextWrapper)
end

TrueSmoking.stop = function(player)
    local o = TrueSmoking:getModData(player)
    local ts = TrueSmoking:getPlayerReference(player)

    if ts.Smokable.smokeLit then
        ts.Smokable:stop()
    end

    o.Smokable = nil

    if ts.keyWrapper then
        Events.OnKeyStartPressed.Remove(ts.keyWrapper)
        ts.keyWrapper = nil
    end

    if ts.contextWrapper then
        Events.OnFillInventoryObjectContextMenu.Remove(ts.contextWrapper)
        ts.contextWrapper = nil
    end

    if ts.NicotineGameTimeWrapper then
        Events.EveryOneMinute.Remove(ts.NicotineGameTimeWrapper)
        ts.NicotineGameTimeWrapper = nil
    end
end

local group = BodyLocations.getGroup('Human')
group:getOrCreateLocation(TrueSmoking.registries.mask)

Events.OnCreatePlayer.Add(TrueSmoking.start)

Events.OnPlayerDeath.Add(TrueSmoking.stop)

Events.OnInitGlobalModData.Add(function()
    local sandbox               = SandboxVars.TrueSmoking
    local opt                   = TrueSmoking.Options

    -- Old Defaults for redundancy
    opt.PuffFactor              = 1.35
    opt.RunningFactor           = 1.15
    opt.SprintingFactor         = 1.35
    opt.WalkingFactor           = 1.0
    opt.IdleFactor              = 1.0
    opt.SmokeLength             = 1.0

    -- 1. Core global options
    opt.ManageHeadGear          = sandbox.ManageHeadGear
    opt.SmokeRelighting         = sandbox.SmokeRelighting
    opt.Dropping                = sandbox.Dropping or true
    opt.DroppingChanceSmoker    = (sandbox.DropChanceSmoker or 6) / 100
    opt.DroppingChanceNonSmoker = (sandbox.DropChanceNonSmoker or 35) / 100

    opt.Coughing                = sandbox.Coughing
    opt.CoughingChanceSmoker    = (sandbox.CoughingChanceSmoker or 4) / 100
    opt.CoughingChanceNonSmoker = (sandbox.CoughingChanceNonSmoker or 15) / 100

    opt.UseNewMoodle            = sandbox.UseNewMoodle

    local smokingSpeed          = sandbox.SmokingSpeed or 1.0
    local puffStrength          = sandbox.PuffStrength or 1.0
    local movementBurn          = sandbox.MovementBurn or 1.0
    local idleBurnOut           = sandbox.IdleBurnOut or 1.0
    local effectMultiplier      = sandbox.EffectMultiplier or 1.0

    opt.Global                  = {
        burnMin = 0.000125 * smokingSpeed,
        burnMax = 0.000300 * smokingSpeed,
        burnSpeed = 0.0025,
        burnSpeedDecay = 0.20,
        puffFactor = 1.35 * puffStrength,
        walkingFactor = 1.0 + (movementBurn - 1) * 0.5,
        runningFactor = 1.15 + (movementBurn - 1) * 0.8,
        sprintingFactor = 1.35 + (movementBurn - 1) * 1.2,
        decayRate = 0.995 + (0.998 - 0.995) * (1 - idleBurnOut),
    }

    opt.Category                = {
        Cigarette = smokingSpeed,
        RolledCigarette = smokingSpeed * 0.9,
        Cigarillo = smokingSpeed * 0.75,
        Cigar = smokingSpeed * 0.50,
        Pipe = smokingSpeed * 0.40,
        Can = smokingSpeed * 0.60,
    }

    local lengthRatios          = {
        Cigarette = 1.0,
        RolledCigarette = 1.0,
        Cigarillo = 1.5,
        Cigar = 3,
        Pipe = 2.5,
        Can = 1.25,
    }

    local function spoofCategory(catName)
        local mult = opt.Category[catName] or 1.0
        local ratio = lengthRatios[catName] or 1.0
        local len = opt.SmokeLength * ratio

        opt[catName] = {
            length = len,
            burnMin = opt.Global.burnMin * mult,
            burnMax = opt.Global.burnMax * mult,
            burnSpeed = opt.Global.burnSpeed,
            burnSpeedDecay = opt.Global.burnSpeedDecay,
            decayRate = opt.Global.decayRate,
            effectMultiplier = lengthRatios[catName] * effectMultiplier,
            puffFactor = opt.Global.puffFactor,
            walkingFactor = opt.Global.walkingFactor,
            runningFactor = opt.Global.runningFactor,
            sprintingFactor = opt.Global.sprintingFactor,
        }

        opt[catName .. 'Length'] = len
    end

    spoofCategory('Cigarette')
    spoofCategory('RolledCigarette')
    spoofCategory('Cigarillo')
    spoofCategory('Cigar')
    spoofCategory('Pipe')
    spoofCategory('Can')

    opt.ManageHeadGear             = sandbox.ManageHeadGear
    opt.SmokeRelighting            = sandbox.SmokeRelighting

    opt.Coughing                   = sandbox.Coughing
    opt.CoughingChanceSmoker       = sandbox.CoughingChanceSmoker or 5
    opt.CoughingChanceNonSmoker    = sandbox.CoughingChanceNonSmoker or 25

    opt.Dropping                   = sandbox.Dropping
    opt.DroppingChanceSmoker       = (sandbox.DropChanceSmoker or 5) / 100
    opt.DroppingChanceNonSmoker    = (sandbox.DropChanceNonSmoker or 25) / 100

    -- Nicotine system options
    opt.UseNicotineSystem          = sandbox.UseNicotineSystem
    opt.DynamicSmokerTrait         = sandbox.DynamicSmokerTrait

    local nic                      = NicotineSystem.Options

    nic.DaysToAddiction            = sandbox.DaysToAddiction
    nic.DaysToDetox                = sandbox.DaysToDetox
    nic.DaysToPeakWithdrawal       = sandbox.DaysToPeakWithdrawal
    nic.SmokerTraitDecayMultiplier = sandbox.SmokerTraitDecayMultiplier
end)
