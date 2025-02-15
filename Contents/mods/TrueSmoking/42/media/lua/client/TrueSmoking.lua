require 'ISUI/ISInventoryPaneContextMenu'

require 'Utils'
require 'Smokable'
require 'SmokingMoodle'

--[[
    This class serves as the entry point for the mod and stores references to the moodle and smokable object to retain the same instance.
    Apart from holding a few variables, and options there are a few functions to handle unpacking cigarrettes and finding them. Mostly this
    event code for context menu and key listeners.
]]

TrueSmoking = TrueSmoking or {}
TrueSmoking.__index = TrueSmoking
TrueSmoking.Options = TrueSmoking.Options or {}
TrueSmoking.Config = require 'ModOptions'
--To support splitscreen we need to store each player seperately
TrueSmoking.Player_1 = TrueSmoking.Player_1 or {}
TrueSmoking.Player_2 = TrueSmoking.Player_2 or {}
TrueSmoking.Player_3 = TrueSmoking.Player_3 or {}
TrueSmoking.Player_4 = TrueSmoking.Player_4 or {}

function TrueSmoking:checkForMaskAndRemove(player)
    local o = self:getPlayerReference(player)
    local mask = self:wearingMask(player)
    if mask then
        o.mask = mask
        self:removeItem(player, mask, false)
    end
end

function TrueSmoking:checkForMaskAndEquip(player)
    local o = self:getPlayerReference(player)
    local mask = o.mask
    if mask then
        self:equipItem(player, mask, false)
    end
end

function TrueSmoking:wearingMask(player)
    local o = self:getPlayerReference(player)
    local items = {}
    items['Mask'] = player:getWornItem('Mask') or ''
    items['MaskEyes'] = player:getWornItem('MaskEyes') or ''
    items['FullHat'] = player:getWornItem('FullHat') or ''
    items['MaskFull'] = player:getWornItem('MaskFull') or ''
    items['Hat'] = player:getWornItem('Hat') or ''
    items['Neck'] = player:getWornItem('Neck') or ''
    for _, item in pairs(items) do
        if item ~= '' and not item:getTags():contains('CanEat') then
            print(item)
            return item
        end
    end
    return nil
end

function TrueSmoking:removeItem(player, item, instant)
    local o = self:getPlayerReference(player)
    local time = instant and 1 or 50
    ISTimedActionQueue.add(ISUnequipAction:new(player, item, time))
end

function TrueSmoking:equipItem(player, item, instant)
    local o = self:getPlayerReference(player)
    local time = instant and 1 or 50
    ISTimedActionQueue.add(ISWearClothing:new(player, item))
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
    local cigarette = player:getInventory():getFirstTypeRecurse("Base.CigaretteSingle")
    local pack = player:getInventory():getFirstTypeRecurse("Base.CigarettePack")
    if not cigarette and pack then
        self:useRecipe(pack, player, 'TakeACigarette')
        cigarette = player:getInventory():getFirstTypeRecurse("Base.CigaretteSingle")
    end
    if cigarette and self:hasLightable(cigarette, player) then
        -- cigarette:
        ISInventoryPaneContextMenu.transferIfNeeded(player, cigarette)
        ISTimedActionQueue.add(ISEatFoodAction:new(player, cigarette, 1))
    end
end

--Checks if the player has a lightable item (lighter, matches, etc)
function TrueSmoking:hasLightable(item, player)
    --Predicate to check if the item has uses (lighters, matches, etc)
    local function predicateNotEmpty(item)
        return item:getCurrentUsesFloat() > 0
    end

    local found = false;
    if item:hasTag("Smokable") and player:getVehicle() and player:getVehicle():canLightSmoke(player) then found = true end
    if item:hasTag("Smokable") and not found then
       found = ISInventoryPaneContextMenu.hasOpenFlame(player)
    end
    if not found then
        local types = item:getRequireInHandOrInventory()
        for i=1,types:size() do
            local fullType = moduleDotType(item:getModule(), types:get(i-1))
            local item2 = player:getInventory():getFirstTypeEvalRecurse(fullType, predicateNotEmpty)
            if item2 then
                -- local fullType = moduleDotType(item:getModule(), item)
                local fullType = item2:getFullType()
                if player:getInventory():getFirstTypeEvalRecurse(fullType, predicateNotEmpty) then
                    found = true;
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
        elseif not o.isSmoking and key == self.Config.keyStopSmoke and o.mask then
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

    -- self.lightTime = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 350 or 180
    self.lightTime = getActivatedMods():contains('\\SmokingSoundsOverhaul') and 350 or 220

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

--Events.OnGameBoot.Add(init)
Events.OnCreatePlayer.Add(function(playerNum, player)
    TrueSmoking:start(playerNum, player)
end)

Events.OnPlayerDeath.Add(function(playerNum, player)
    TrueSmoking:stop(playerNum, player)
end)

--Load SandboxVars
Events.OnPreMapLoad.Add(function()
    TrueSmoking.Options.OverrideSmokeLength = SandboxVars.TrueSmoking.OverrideSmokeLength
    TrueSmoking.Options.SmokeLength = SandboxVars.TrueSmoking.SmokeLength

    TrueSmoking.Options.PuffFactor = SandboxVars.TrueSmoking.PuffFactor
    TrueSmoking.Options.RunningFactor = SandboxVars.TrueSmoking.RunningFactor
    TrueSmoking.Options.IdleFactor = SandboxVars.TrueSmoking.IdleFactor

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