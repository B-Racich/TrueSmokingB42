require 'ISUI/ISInventoryPaneContextMenu'

require 'Utils'
require 'Smokable'
require 'SmokingMoodle'

TrueSmoking = TrueSmoking or {}
TrueSmoking.__index = TrueSmoking
TrueSmoking.Options = TrueSmoking.Options or {}
TrueSmoking.Config = require 'ModOptions'

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
function TrueSmoking:findSmokable()
    local cigarette = getPlayer():getInventory():getFirstTypeRecurse("Base.CigaretteSingle")
    local pack = getPlayer():getInventory():getFirstTypeRecurse("Base.CigarettePack")
    if not cigarette and pack then
        self:useRecipe(pack, getPlayer(), 'TakeACigarette')
        cigarette = getPlayer():getInventory():getFirstTypeRecurse("Base.CigaretteSingle")
    end
    if cigarette and self:hasLightable(cigarette) then
        -- cigarette:
        ISInventoryPaneContextMenu.transferIfNeeded(getPlayer(), cigarette)
        ISTimedActionQueue.add(ISEatFoodAction:new(getPlayer(), cigarette, 1))
    end
end

--Predicate to check if the item has uses (lighters, matches, etc)
local function predicateNotEmpty(item)
    return item:getCurrentUsesFloat() > 0
end

--Checks if the player has a lightable item (lighter, matches, etc)
function TrueSmoking:hasLightable(item)
    local found = false;
    local player = getPlayer()
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
    print('key pressed'..key)
    print(Keyboard.KEY_SEMICOLON)
    if getPlayer() then
        if self.isSmoking and self.Smokable.smokeLit and key == self.Config.keySmoke then
            self.Smokable:puff()
        elseif self.isSmoking and not self.Smokable.smokeLit and key == self.Config.keySmoke then
            self.Smokable:light()
        elseif self.Config.FindSmoke and not self.isSmoking and key == self.Config.keySmoke then
            self:findSmokable()
        elseif self.isSmoking and key == self.Config.keyStopSmoke then
            self.Smokable:putOut()
        end
    end
end

--Hook into context menu for Smokable objects and toggle the Smoke option when Smoking
function TrueSmoking:toggleSmokeMenuOption(player, context, items)
    for i, v in ipairs(items) do
        local item = v
        local hasSmoke = nil

        if not instanceof(v, 'InventoryItem') then item = v.items[1] end

        --Context Menu Hook
        hasSmoke = context:getOptionFromName(getText('ContextMenu_Smoke'))
        if hasSmoke then
            if self.isSmoking then
                hasSmoke.notAvailable = true
            elseif not self.isSmoking and self:hasLightable(item) then
                hasSmoke.notAvailable = false
            end
        end
    end
end

--Start our event listerns on player load
function TrueSmoking:start()
    self.Moodle = SmokingMoodle:new(self)

    --Start the update event
    local function keyWrapper(key)
        self:onKeyStartPressed(key)
    end
    self.keyWrapper = keyWrapper

    local function contextWrapper(player, context, items)
        self:toggleSmokeMenuOption(player, context, items)
    end
    self.contextWrapper = contextWrapper

    --Keybinds
    Events.OnKeyStartPressed.Add(self.keyWrapper)
    --Toggles the Smoke option in the context menu
    Events.OnFillInventoryObjectContextMenu.Add(self.contextWrapper)
end

--Stop our event listeners on player death
function TrueSmoking:stop()
    self.Moodle:stop()
    if self.Smokable then
        self.Smokable:putOut()
    end
    self.Moodle = nil
    self.Smokable = nil
    --Keybinds
    if self.keyWrapper then
        Events.OnKeyStartPressed.Remove(self.keyWrapper)
        self.keyWrapper = nil
    end
    --Context Menu Hook
    if self.contextWrapper then
        Events.OnFillInventoryObjectContextMenu.Remove(self.contextWrapper)
        self.contextWrapper = nil
    end
end

--Events.OnGameBoot.Add(init)
Events.OnCreatePlayer.Add(function()
    TrueSmoking:start()
end)

Events.OnPlayerDeath.Add(function()
    TrueSmoking:stop()
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