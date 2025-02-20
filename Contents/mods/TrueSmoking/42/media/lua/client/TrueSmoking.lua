require 'ISUI/ISInventoryPaneContextMenu'

require 'Utils'
require 'Smokable'
require 'SmokingMoodle'

local InventoryUI = require("Starlit/client/ui/InventoryUI")

--[[
    This class serves as the entry point for the mod and stores references to the moodle and smokable object to retain the same instance.
    Apart from holding a few variables, and options there are a few functions to handle unpacking cigarrettes and finding them. Mostly this
    event code for context menu and key listeners.
]]

TrueSmoking = TrueSmoking or {}
TrueSmoking.__index = TrueSmoking
TrueSmoking.Options = TrueSmoking.Options or {}
TrueSmoking.Mods = TrueSmoking.Mods or {}
TrueSmoking.VisualItems = TrueSmoking.VisualItems or {}
TrueSmoking.SmokeLengths = TrueSmoking.SmokeLengths or {}
TrueSmoking.HotkeySmokes = TrueSmoking.HotkeySmokes or {}
TrueSmoking.HotkeyPacks = TrueSmoking.HotkeyPacks or {}
TrueSmoking.Config = require 'ModOptions'
--To support splitscreen we need to store each player seperately
TrueSmoking.Player_1 = TrueSmoking.Player_1 or {}
TrueSmoking.Player_2 = TrueSmoking.Player_2 or {}
TrueSmoking.Player_3 = TrueSmoking.Player_3 or {}
TrueSmoking.Player_4 = TrueSmoking.Player_4 or {}

--[[
    For modders use this to set smoke lengths on your smokables
    { [item:getFullType()] = <Smoke Length> }
    ex. { ['Base.CigaretteSingle'] = 1.5 }
]]
function TrueSmoking:setSmokeLengths(table)
    for index, value in pairs(table) do
        -- print(string.format('Smoke Lengths Setting: %s - %s',index, value))
        self.SmokeLengths[index] = value
    end
end

--[[
    For modders use this to set visualItems for your smokables
    { [item:getFullType()] = <Name of item> }
    ex. { ['Base.CigaretteSingle'] = 'Base.Mask_Cigarette' }
]]
function TrueSmoking:setVisualItems(table)
    for index, value in pairs(table) do
        -- print(string.format('Setting: %s - %s',index, value))
        self.VisualItems[index] = value
    end
end

--[[
    For modders use this to set smokes for the hotkey
    { [item:getFullType()] = <Name of item> }
    ex. { ['Base.CigaretteSingle'] = 'Base.Mask_Cigarette' }
]]
function TrueSmoking:setHotkeySmokes(list)
    for _, item in ipairs(list) do
        table.insert(self.HotkeySmokes, item)
    end
end

--[[
    For modders use this to set smoke packs for the hotkey
    { [item:getFullType()] = <Name of item> }
    ex. { ['Base.CigaretteSingle'] = 'Base.Mask_Cigarette' }
]]
function TrueSmoking:setHotkeyPacks(list)
    for _, item in ipairs(list) do
        table.insert(self.HotkeyPacks, item)
    end
end

function TrueSmoking:isVisualItem(item)
    for key, value in pairs(self.VisualItems) do
        if item:getFullType() == value then
            return true
        end
    end
    return false
end

--Mask helper functions
function TrueSmoking:checkForMaskAndRemove(player)
    if not TrueSmoking.Options.ManageHeadGear then return end
    local o = self:getPlayerReference(player)
    self:getWornMask(player)
    if o.mask then
        self:removeItem(player, o.mask, 50)
    end
    if o.shemagh then
        self:adjustShemagh(player, o.shemagh, true)
    end
end

function TrueSmoking:checkForMaskAndEquip(player)
    local o = self:getPlayerReference(player)
    if o.mask then
        self:equipItem(player, o.mask, 50)
    end
    if o.shemagh then
        self:getWornMask(player, true)
        self:adjustShemagh(player, o.shemagh, false)
    end
end

--[[
    Nothing is easy, have to rewrite this and find every item that makes sense.
    Shemagh support would be nice to reveal face to smoke.

    strip out some checks to be more liberal here for now.
]]
function TrueSmoking:getWornMask(player, reCover)
    local o = self:getPlayerReference(player)
    local items = {}
    items['Mask'] = player:getWornItem('Mask') or ''
    items['MaskEyes'] = player:getWornItem('MaskEyes') or ''
    items['FullHat'] = player:getWornItem('FullHat') or ''
    items['MaskFull'] = player:getWornItem('MaskFull') or ''
    items['Hat'] = player:getWornItem('Hat') or ''
    items['Neck'] = player:getWornItem('Neck') or ''
    for _, item in pairs(items) do
        if item ~= '' then
            local type = item:getFullType()
            if item:getTags():contains('CantSmoke') then
                if type:contains('Shemagh') then
                    o.shemagh = item
                    return item
                end
                o.mask = item
                return item
            elseif reCover and type:contains('Shemagh') then
                o.shemagh = item
                return item
            end
        end
    end
    return false
end

--Wrappers for mask actions
function TrueSmoking:removeItem(player, item, time)
    ISTimedActionQueue.add(ISUnequipAction:new(player, item, time))
end

function TrueSmoking:adjustShemagh(player, item, putDown)
    local fullCovers = {
        ['Base.Hat_ShemaghFull'] = 'Base.Hat_ShemaghFace',
        ['Base.Hat_ShemaghFull_Green'] = 'Base.Hat_ShemaghFace_Green',
        ['Base.Hat_ShemaghFull_Cotton'] = 'Base.Hat_ShemaghFace_Cotton',
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
                print(string.format('Adjusted Shegmah: %s - putDown: %s - setTo: %s',fullType, putDown and 'true' or 'false', setTo))
                ISTimedActionQueue.add(ISClothingExtraAction:new(player, item, setTo, 30))
                return true
            end
        end
        return false
    end

    if handleCovers(fullCovers) then return end
    handleCovers(scarfCovers)
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

--Calls the crafting recipe from the item
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

--Finds a smokable object from the inventory or a pack of cigarettes
function TrueSmoking:findSmokable(player)
    local cigarette = false
    for _, value in ipairs(self.HotkeySmokes) do
        cigarette = player:getInventory():getFirstTypeRecurse(value)
        if cigarette then break end
    end

    local pack = false
    for _, value in ipairs(self.HotkeyPacks) do
        pack = player:getInventory():getFirstTypeRecurse(value)
        if pack then break end
    end

    if not cigarette and pack then
        self:useRecipe(pack, player, 'TakeACigarette')
        for index, value in ipairs(self.HotkeySmokes) do
            cigarette = player:getInventory():getFirstTypeRecurse(value)
        end
    end
    if cigarette and self:hasLightable(cigarette, player) then
        -- cigarette:
        ISInventoryPaneContextMenu.transferIfNeeded(player, cigarette)
        ISTimedActionQueue.add(ISEatFoodAction:new(player, cigarette, 1))
    end
end

--Checks if the player has a lightable item (lighter, matches, etc)
function TrueSmoking:hasLightable(item, player, onlyItems)
    --Predicate to check if the item has uses (lighters, matches, etc)
    local function predicateNotEmpty(item)
        return item:getCurrentUsesFloat() > 0
    end

    local function hasLighterTag(item)
        return item:getTags():contains('Lighter') and predicateNotEmpty(item)
    end

    local found = false;
    if item:hasTag("Smokable") and player:getVehicle() and player:getVehicle():canLightSmoke(player) then found = true end
    if item:hasTag("Smokable") and not found and not onlyItems then
       found = ISInventoryPaneContextMenu.hasOpenFlame(player)
    end
    if not found then
        local types = item:getRequireInHandOrInventory()
        if types then
            for i=1,types:size() do
                local fullType = moduleDotType(item:getModule(), types:get(i-1))
                local item2 = player:getInventory():getFirstTypeEvalRecurse(fullType, predicateNotEmpty)
                if item2 then
                    -- local fullType = moduleDotType(item:getModule(), item)
                    local fullType = item2:getFullType()
                    found = player:getInventory():getFirstTypeEvalRecurse(fullType, predicateNotEmpty)
                    if found then
                        return found
                    end
                end
            end
            if not found then
                found = player:getInventory():getFirstEvalRecurse(hasLighterTag)
                if found then
                    return found
                end
            end
        end
    end
    return found
end

--Key Event Listener
function TrueSmoking:onKeyStartPressed(key)
    -- print(string.format('KEY PRESSED - %s',key))
    local o = self.Player_1
    local player = getSpecificPlayer(0) -- Player_0 is always keyboard
    if player then
        if o.isSmoking and o.Smokable.smokeLit and key == self.Config.keySmoke then
            o.Smokable:puff()
        elseif o.isSmoking and not o.Smokable.smokeLit and key == self.Config.keySmoke then
            o.Smokable:light()
        elseif self.Config.FindSmoke and not o.isSmoking and key == self.Config.keySmoke then
            self:findSmokable(player)
        elseif o.isSmoking and key == self.Config.keyStopSmoke then
            o.Smokable:putOut()
        elseif not o.isSmoking and key == self.Config.keyStopSmoke and o.mask and self.Options.ManageHeadGear then
            self:equipItem(player, o.mask, false)
        end
    end
end

--Hook into context menu for Smokable objects and toggle the Smoke option when Smoking
function TrueSmoking:toggleSmokeMenuOption(player, context, items)
    for i, v in ipairs(items) do
        local item = v
        local hasSmoke = nil

        local o = self:getPlayerReference(player)

        if not instanceof(v, 'InventoryItem') then item = v.items[1] end

        --Context Menu Hook
        hasSmoke = context:getOptionFromName(getText('ContextMenu_Smoke'))
        if hasSmoke then
            if o.isSmoking then
                hasSmoke.notAvailable = true
            elseif not o.isSmoking and self:hasLightable(item, getSpecificPlayer(player)) then
                hasSmoke.notAvailable = false
            end
        end
    end
end

--Start our event listerns on player load
function TrueSmoking:start(playerNum, player)
    local o = self:getPlayerReference(player)
    o.Moodle = SmokingMoodle:new(o, playerNum)
    o.eatSound = ''
    o.lightingEatSound = ''

    -- 460 is vanilla
    self.lightTime = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 400 or 220
    self.relightTime = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 400 or 120

    --Start the update event
    local function keyWrapper(key)
        self:onKeyStartPressed(key)
    end
    o.keyWrapper = keyWrapper

    local function contextWrapper(player, context, items)
        self:toggleSmokeMenuOption(player, context, items)
    end
    o.contextWrapper = contextWrapper

    --Keybinds
    Events.OnKeyStartPressed.Add(o.keyWrapper)
    --Toggles the Smoke option in the context menu
    Events.OnFillInventoryObjectContextMenu.Add(o.contextWrapper)
end

--Stop our event listeners on player death
function TrueSmoking:stop(playerNum, player)
    local o = self:getPlayerReference(player)

    o.Moodle:stop()
    if o.Smokable then
        o.Smokable:putOut()
    end
    o.Moodle = nil
    o.Smokable = nil
    --Keybinds
    if o.keyWrapper then
        Events.OnKeyStartPressed.Remove(o.keyWrapper)
        o.keyWrapper = nil
    end
    --Context Menu Hook
    if o.contextWrapper then
        Events.OnFillInventoryObjectContextMenu.Remove(o.contextWrapper)
        o.contextWrapper = nil
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

--Events.OnGameBoot.Add(init)
Events.OnCreatePlayer.Add(function(playerNum, player)
    TrueSmoking:start(playerNum, player)
end)

Events.OnPlayerDeath.Add(function(playerNum, player)
    TrueSmoking:stop(playerNum, player)
end)

--Load SandboxVars
Events.OnInitGlobalModData.Add(function()
    TrueSmoking.Options.OverrideSmokeLength = SandboxVars.TrueSmoking.OverrideSmokeLength
    TrueSmoking.Options.SmokeLength = SandboxVars.TrueSmoking.SmokeLength

    TrueSmoking.Options.PuffFactor = SandboxVars.TrueSmoking.PuffFactor
    TrueSmoking.Options.RunningFactor = SandboxVars.TrueSmoking.RunningFactor
    TrueSmoking.Options.IdleFactor = SandboxVars.TrueSmoking.IdleFactor

    TrueSmoking.Options.ManageHeadGear = SandboxVars.TrueSmoking.ManageHeadGear

    TrueSmoking.Options.UseNewMoodle = SandboxVars.TrueSmoking.UseNewMoodle

    TrueSmoking.Options.SmokeRelighting = SandboxVars.TrueSmoking.SmokeRelighting

    TrueSmoking.Options.Coughing = SandboxVars.TrueSmoking.Coughing
    TrueSmoking.Options.CoughingChanceSmoker = SandboxVars.TrueSmoking.CoughingChanceSmoker
    TrueSmoking.Options.CoughingChanceNonSmoker = SandboxVars.TrueSmoking.CoughingChanceNonSmoker

    TrueSmoking.Options.CigaretteLength = SandboxVars.TrueSmoking.CigaretteLength
    TrueSmoking.Options.CigarilloLength = SandboxVars.TrueSmoking.CigarilloLength
    TrueSmoking.Options.CigarLength = SandboxVars.TrueSmoking.CigarLength
    TrueSmoking.Options.PipeLength = SandboxVars.TrueSmoking.PipeLength
    TrueSmoking.Options.CanLength = SandboxVars.TrueSmoking.CanLength
end)