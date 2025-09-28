require 'ISUI/ISInventoryPaneContextMenu'

require 'Utils'
require 'Smokable'

local InventoryUI = require("Starlit/client/ui/InventoryUI")

--[[
    This class serves as the entry point for the mod and stores references to the moodle and smokable object to retain the same instance.
    Apart from holding a few variables, and options there are a few functions to handle unpacking cigarrettes and finding them. Mostly this
    event code for context menu and key listeners.
]]

TrueSmoking = TrueSmoking or {}
TrueSmoking.__index = TrueSmoking
TrueSmoking.Options = TrueSmoking.Options or {}
TrueSmoking.HotkeySmokes = TrueSmoking.HotkeySmokes or {}
TrueSmoking.HotkeyPacks = TrueSmoking.HotkeyPacks or {}
TrueSmoking.SmokableObjects = TrueSmoking.SmokableObjects or {}
TrueSmoking.Callbacks = TrueSmoking.Callbacks or {}
TrueSmoking.Config = require 'Configuration/ModOptions'
--To support splitscreen we need to store each player seperately
TrueSmoking.Player_1 = TrueSmoking.Player_1 or {}
TrueSmoking.Player_2 = TrueSmoking.Player_2 or {}
TrueSmoking.Player_3 = TrueSmoking.Player_3 or {}
TrueSmoking.Player_4 = TrueSmoking.Player_4 or {}

local originalGetEatingMask = ISInventoryPaneContextMenu.getEatingMask
local originalEatItem = ISInventoryPaneContextMenu.eatItem

--[[
    For modders use this to set smokes for the hotkey
    { [item:getFullType()] = <Name of item> }
    ex. { 'Base.CigaretteSingle' }
]]
function TrueSmoking:setHotkeySmokes(list)
    for _, item in ipairs(list) do
        table.insert(self.HotkeySmokes, item)
    end
end

--[[
    For modders use this to set smoke packs for the hotkey
    { [item:getFullType()] = recipeString }
    ex. { ['Base.CigarettePack'] = 'TakeACigarette' }
]]
function TrueSmoking:setHotkeyPacks(table)
    for key, item in pairs(table) do
        self.HotkeyPacks[key] = item
    end
end

--[[
    For modders use this to set a callback on the Smokable:update() method
    This will allow you to hook into the update method and do your own logic for effects as the item is smoked.
]]
function TrueSmoking:setCallback(func)
    table.insert(self.Callbacks, func)
end

--[[
    Set SmokableObjects that contain definitions for the different smokables
]]
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
    local o = self:getPlayerReference(player)
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
            if item:getTags():contains('CantSmoke') then
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
                ISTimedActionQueue.add(ISClothingExtraAction:new(player, item, setTo, 30))
                return true
            end
        end
        return false
    end

    if handleCovers(fullCovers) then return end
    handleCovers(scarfCovers)
end

function TrueSmoking:checkForMaskAndEquip(player)
    local o = self:getPlayerReference(player)
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
    ISTimedActionQueue.add(ISUnequipAction:new(player, item, time))
end

function TrueSmoking:equipItem(player, item, time)
    ISTimedActionQueue.add(ISWearClothing:new(player, item, time))
end

function TrueSmoking:getPlayerReference(player)
    local num = player
    if type(player) ~= 'number' then
        num = player:getPlayerNum()
    end

    if num == 0 then
        return self.Player_1
    elseif num == 1 then
        return self.Player_2
    elseif num == 2 then
        return self.Player_3
    elseif num == 3 then
        return self.Player_4
    end
end

function TrueSmoking:useRecipe(item, player, recipeString)
    local containers = ISInventoryPaneContextMenu.getContainers(player)
    local recipes = CraftRecipeManager.getUniqueRecipeItems(item, player, containers)
    if recipes and recipes:size() > 0 then
        local recipe = recipes:get(0)
        if recipe:getName() == recipeString then
            ISInventoryPaneContextMenu.OnNewCraft(item, recipe, player:getPlayerNum(), false)
        end
    end
end

function TrueSmoking:findSmokable(player)
    local map = {
        [1] = 'Base.CigaretteRolled',
        [2] = 'Base.CigaretteSingle',
        [3] = 'Base.Cigarillo',
        [4] = 'Base.Cigar',
        [5] = 'Base.CanPipe_Tobacco',
        [6] = 'Base.SmokingPipe_Tobacco'
    }

    local smokes = {}

    for i = 1, #map do
        if self.Config['HotKeySmokes_' .. tostring(i)] then
            table.insert(smokes, map[i])
        end
    end

    for _, item in ipairs(self.HotkeySmokes) do
        table.insert(smokes, item)
    end

    local cigarette = false
    for _, value in ipairs(smokes) do
        cigarette = player:getInventory():getFirstTypeRecurse(value)
        if cigarette then break end
    end

    local pack = false
    local recipe = false
    for key, val in pairs(self.HotkeyPacks) do
        pack = player:getInventory():getFirstTypeRecurse(key)
        recipe = val
        if pack then break end
    end

    if not cigarette and pack and recipe then
        self:useRecipe(pack, player, recipe)
        for index, value in ipairs(smokes) do
            cigarette = player:getInventory():getFirstTypeRecurse(value)
        end
    end

    if cigarette and self:hasRequiredItem(cigarette, player) then
        print('TRUESMOKING::FOUND CIG/PACK')
        ISInventoryPaneContextMenu.eatItem(cigarette, 1, player:getPlayerNum())
    end
end

ISInventoryPaneContextMenu.eatItem = function(item, percentage, player)
    if item:getTags():contains('Smokable') then
        TrueSmoking:getPlayerReference(player).CheckMaskSmoking = true
    else
        TrueSmoking:getPlayerReference(player).CheckMaskSmoking = false
    end
    originalEatItem(item, percentage, player)
end

ISInventoryPaneContextMenu.getEatingMask = function(playerObj, removeMask)
    local o = TrueSmoking:getPlayerReference(playerObj)

    --use native function to get blocking mask
    local mask = originalGetEatingMask(playerObj, false)

    if mask and mask:getFullType():contains('Shemagh') and mask:getTags():contains('CantSmoke') and o.CheckMaskSmoking then
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
end

function TrueSmoking:onKeyStartPressed(key)
    -- print(string.format('TRUESMOKING::KEY PRESSED - %s',key))
    local o = self.Player_1
    local player = getSpecificPlayer(0) -- Player_0 is always keyboard
    if player then
        if o.isSmoking and o.Smokable.smokeLit and key == self.Config.keySmoke then
            o.Smokable:puff()
        elseif o.isSmoking and not o.Smokable.smokeLit and key == self.Config.keySmoke then
            o.Smokable:light()
        elseif self.Config.FindSmoke and not o.isSmoking and key == self.Config.keySmoke then
            print('TRUESMOKING::Find Smokable')
            self:findSmokable(player)
        elseif o.isSmoking and key == self.Config.keyStopSmoke then
            o.Smokable:putOut()
        elseif not o.isSmoking and key == self.Config.keyStopSmoke and o.mask and self.Options.ManageHeadGear then
            self:equipItem(player, o.mask, false)
        end
    end
end

function TrueSmoking:toggleSmokeMenuOption(player, context, items)
    for i, v in ipairs(items) do
        local item = v
        local smokable = nil

        local o = self:getPlayerReference(player)

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

function TrueSmoking:start(playerNum, player)
    local o = self:getPlayerReference(player)

    o.eatSound = ''
    o.lightingEatSound = ''

    o.Smokable = {}
    o.Smokable.smokeLit = false

    local function NicotineUpdate()
        NicotineSystem:update(player)
    end
    o.NicotineUpdate = NicotineUpdate

    if TrueSmoking.Options.UseNicotineSystem then
        NicotineSystem:initialize(player)
        Events.EveryOneMinute.Add(o.NicotineUpdate)
    end

    if not TrueSmoking.Config.HideMoodles then
        o.SmokingMoodle = SmokingMoodle:new(o, playerNum)
        o.NicotineMoodle = NicotineMoodle:new(o, playerNum)
        o.NicotineMoodle:start()
    end

    -- 460 is vanilla
    self.lightTime = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 460 or 220

    local function keyWrapper(key)
        self:onKeyStartPressed(key)
    end
    o.keyWrapper = keyWrapper

    local function contextWrapper(player, context, items)
        self:toggleSmokeMenuOption(player, context, items)
    end
    o.contextWrapper = contextWrapper

    if player:getModData().Smokable then
        local smokable = player:getInventory():AddItem(player:getModData().Smokable[1])
        smokable:getModData().SmokeLength = player:getModData().Smokable[2]
        player:getModData().Smokable = false
    end

    Events.OnKeyStartPressed.Add(o.keyWrapper)
    Events.OnFillInventoryObjectContextMenu.Add(o.contextWrapper)
end

function TrueSmoking:stop(player)
    local o = self:getPlayerReference(player)

    if not TrueSmoking.Config.HideMoodles then
        o.SmokingMoodle:stop()
        o.NicotineMoodle:stop()
    end

    if o.Smokable.smokeLit then
        o.Smokable:stop()
    end

    o.SmokingMoodle = nil
    o.Smokable = nil

    if o.keyWrapper then
        Events.OnKeyStartPressed.Remove(o.keyWrapper)
        o.keyWrapper = nil
    end

    if o.contextWrapper then
        Events.OnFillInventoryObjectContextMenu.Remove(o.contextWrapper)
        o.contextWrapper = nil
    end

    if o.NicotineUpdate then
        Events.EveryOneMinute.Remove(o.NicotineUpdate)
        o.NicotineUpdate = nil
    end
end

local remainingSmokeTooltip = function(tooltip, layout, item)
    if item and item:getModData().SmokeLength and item:getModData().OriginalSmokeLength then
        local current = item:getModData().SmokeLength
        local original = item:getModData().OriginalSmokeLength
        local amt = (current / original)
        amt = amt >= 0 and amt or 0

        InventoryUI.addTooltipBar(layout, "Remaining:", amt)
    end
end

InventoryUI.onFillItemTooltip:addListener(remainingSmokeTooltip)

local group = BodyLocations.getGroup("Human")
local bodyLocation = BodyLocation.new(group, "Mask_Smoke")
group:getAllLocations():add(bodyLocation)

Events.OnCreatePlayer.Add(function(playerNum, player)
    TrueSmoking:start(playerNum, player)
end)

Events.OnPlayerDeath.Add(function(player)
    TrueSmoking:stop(player)
end)

Events.OnInitGlobalModData.Add(function()
    local sandbox = SandboxVars.TrueSmoking
    local opt = TrueSmoking.Options

    opt.OverrideSmokeLength = sandbox.OverrideSmokeLength
    opt.SmokeLength = sandbox.SmokeLength

    opt.ManageHeadGear = sandbox.ManageHeadGear

    opt.UseNewMoodle = sandbox.UseNewMoodle

    opt.SmokeRelighting = sandbox.SmokeRelighting

    opt.Coughing = sandbox.Coughing
    opt.CoughingChanceSmoker = sandbox.CoughingChanceSmoker
    opt.CoughingChanceNonSmoker = sandbox.CoughingChanceNonSmoker

    opt.Dropping = sandbox.Dropping
    opt.DroppingChanceSmoker = sandbox.DroppingChanceSmoker
    opt.DroppingChanceNonSmoker = sandbox.DroppingChanceNonSmoker

    -- Old Defaults for redundancy
    opt.PuffFactor = 1.35
    opt.RunningFactor = 1.15
    opt.SprintingFactor = 1.35
    opt.WalkingFactor = 1.0
    opt.IdleFactor = 1.0

    -- Smokable config options [Keep the length for redundancy]
    opt.CigaretteLength = sandbox.CigaretteLength
    opt.Cigarette = {
        length = sandbox.CigaretteLength,
        burnMin = sandbox.CigaretteBurnMin,
        burnMax = sandbox.CigaretteBurnMax,
        burnSpeed = sandbox.CigaretteBurnSpeed,
        burnSpeedDecay = sandbox.CigaretteBurnSpeedDecay,
        decayRate = sandbox.CigaretteDecayRate,
        effectMultiplier = sandbox.CigaretteEffectMultiplier,
        puffFactor = sandbox.CigarettePuffFactor,
        walkingFactor = sandbox.CigaretteWalkingFactor,
        runningFactor = sandbox.CigaretteRunningFactor,
        sprintingFactor = sandbox.CigaretteSprintingFactor
    }

    opt.RolledCigaretteLength = sandbox.RolledCigaretteLength
    opt.RolledCigarette = {
        length = sandbox.RolledCigaretteLength,
        burnMin = sandbox.RolledCigaretteBurnMin,
        burnMax = sandbox.RolledCigaretteBurnMax,
        burnSpeed = sandbox.RolledCigaretteBurnSpeed,
        burnSpeedDecay = sandbox.RolledCigaretteBurnSpeedDecay,
        decayRate = sandbox.RolledCigaretteDecayRate,
        effectMultiplier = sandbox.RolledCigaretteEffectMultiplier,
        puffFactor = sandbox.RolledCigarettePuffFactor,
        walkingFactor = sandbox.RolledCigaretteWalkingFactor,
        runningFactor = sandbox.RolledCigaretteRunningFactor,
        sprintingFactor = sandbox.RolledCigaretteSprintingFactor
    }

    opt.CigarilloLength = sandbox.CigarilloLength
    opt.Cigarillo = {
        length = sandbox.CigarilloLength,
        burnMin = sandbox.CigarilloBurnMin,
        burnMax = sandbox.CigarilloBurnMax,
        burnSpeed = sandbox.CigarilloBurnSpeed,
        burnSpeedDecay = sandbox.CigarilloBurnSpeedDecay,
        decayRate = sandbox.CigarilloDecayRate,
        effectMultiplier = sandbox.CigarilloEffectMultiplier,
        puffFactor = sandbox.CigarilloPuffFactor,
        walkingFactor = sandbox.CigarilloWalkingFactor,
        runningFactor = sandbox.CigarilloRunningFactor,
        sprintingFactor = sandbox.CigarilloSprintingFactor
    }

    opt.CigarLength = sandbox.CigarLength
    opt.Cigar = {
        length = sandbox.CigarLength,
        burnMin = sandbox.CigarBurnMin,
        burnMax = sandbox.CigarBurnMax,
        burnSpeed = sandbox.CigarBurnSpeed,
        burnSpeedDecay = sandbox.CigarBurnSpeedDecay,
        decayRate = sandbox.CigarDecayRate,
        effectMultiplier = sandbox.CigarEffectMultiplier,
        puffFactor = sandbox.CigarPuffFactor,
        walkingFactor = sandbox.CigarWalkingFactor,
        runningFactor = sandbox.CigarRunningFactor,
        sprintingFactor = sandbox.CigarSprintingFactor
    }

    opt.PipeLength = sandbox.PipeLength
    opt.Pipe = {
        length = sandbox.PipeLength,
        burnMin = sandbox.PipeBurnMin,
        burnMax = sandbox.PipeBurnMax,
        burnSpeed = sandbox.PipeBurnSpeed,
        burnSpeedDecay = sandbox.PipeBurnSpeedDecay,
        decayRate = sandbox.PipeDecayRate,
        effectMultiplier = sandbox.PipeEffectMultiplier,
        puffFactor = sandbox.PipePuffFactor,
        walkingFactor = sandbox.PipeWalkingFactor,
        runningFactor = sandbox.PipeRunningFactor,
        sprintingFactor = sandbox.PipeSprintingFactor
    }

    opt.CanLength = sandbox.CanLength
    opt.Can = {
        length = sandbox.CanLength,
        burnMin = sandbox.CanBurnMin,
        burnMax = sandbox.CanBurnMax,
        burnSpeed = sandbox.CanBurnSpeed,
        burnSpeedDecay = sandbox.CanBurnSpeedDecay,
        decayRate = sandbox.CanDecayRate,
        effectMultiplier = sandbox.CanEffectMultiplier,
        puffFactor = sandbox.CanPuffFactor,
        walkingFactor = sandbox.CanWalkingFactor,
        runningFactor = sandbox.CanRunningFactor,
        sprintingFactor = sandbox.CanSprintingFactor
    }

    -- Nicotine system options
    opt.UseNicotineSystem = sandbox.UseNicotineSystem
    opt.DynamicSmokerTrait = sandbox.DynamicSmokerTrait

    local nic = NicotineSystem.Options

    nic.NICOTINE_DECAY_RATE = sandbox.MetabolismBaseDecayRate

    nic.ADDICTION_GAIN_RATE = sandbox.AddictionGainRate
    nic.ADDICTION_DECAY_RATE = sandbox.AddictionDecayRate
    nic.ADDICTION_MIN_DECAY = sandbox.AddictionMinDecay
    nic.ADDICTION_GAIN_THRESHOLD = sandbox.AddictionGrowthThreshold

    nic.SMOKER_TRAIT_THRESHOLD = sandbox.AddictionTraitThreshold
    nic.SMOKER_TRAIT_LOSE_THRESHOLD = sandbox.AddictionCureThreshold

    nic.INTAKE_CONVERSION = sandbox.AddictionIntakeConversion
    nic.ACTIVE_SMOKING_BONUS = sandbox.AddictionActiveSmoking

    nic.HUNGER_BASE = sandbox.HungerReduction
    nic.FATIGUE_BASE = sandbox.FatigueReduction

    nic.STRESS_BASE = sandbox.StressGain
    nic.UNHAPPINESS_BASE = sandbox.UnhappinessGain
    nic.BOREDOM_BASE = sandbox.BoredomGain

    nic.STRESS_MAX = sandbox.StressMax
    nic.UNHAPPINESS_MAX = sandbox.UnhappinessMax
    nic.BOREDOM_MAX = sandbox.BoredomMax

    nic.ADDICTION_CAP = sandbox.AddictionCap
end)
