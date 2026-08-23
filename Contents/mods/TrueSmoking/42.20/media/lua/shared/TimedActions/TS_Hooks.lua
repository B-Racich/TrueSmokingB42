--[[
    TS_Hooks.lua - Vanilla Action Hooks

    Patches vanilla timed actions to integrate TrueSmoking:
    - ISEatFoodAction / ISTakePillAction → LightSmoke redirect
    - ISUnequipAction / ISWearClothing → Visual item management
]]

require 'TimedActions/ISClothingExtraAction'
require 'TimedActions/ISWearClothing'
require 'TimedActions/ISUnequipAction'
require 'TimedActions/ISEatFoodAction'
require 'TimedActions/ISTakePillAction'
require 'Core'
require 'Data'

--------------------------------------------------------------------------------
-- Smokable Detection
--------------------------------------------------------------------------------

local HOOKABLE_FUNCS = {
    'cigarettes',
    'RecipeCodeOnEat.consumeNicotine',
    'OnEat_Cigarettes',
    'OnEat_Cigarillo',
    'OnEat_Cigar',
    'OnEat_WeedSmoke',
    'OnEat_WeedJoint',
    'OnEat_WeedPipe',
    'OnEat_HempCigarillo',
    'OnEat_Tobacco',
    'OnEat_Weed',
    'OnSmoke_Blunt',
    'OnSmoke_Cannabis',
    'OnSmoke_CannaCigar',
    'OnSmoke_Spliff',
    'OnSmoke_Cigar',
}

--- Check if onEat function should be hooked
-- @param onEat string
-- @return boolean
local function isHookable(onEat)
    for _, func in ipairs(HOOKABLE_FUNCS) do
        if onEat == func then
            return true
        end
    end
    return false
end

--- Check if an item should be redirected into the smoking pipeline
-- @param item InventoryItem
-- @return boolean
local function isSmokable(item)
    if not item then return false end
    if item:getFullType() == 'Base.TobaccoChewing' then return false end

    local onEat = item:getOnEat() or ''
    if isHookable(onEat) then return true end

    return item:hasTag(ItemTag.SMOKABLE)
end

--- Setup item for TrueSmoking hook
-- @param item InventoryItem
local function setupSmokableHook(item)
    local replace = item:getReplaceOnUseFullType()
    if replace and replace ~= '' then
        item:getModData().replaceOnUse = replace
        item:setReplaceOnUse(nil)
    end
    item:getModData().modOnEat = 'OnEat_Hook'
end

--- Call a vanilla constructor while ISTimedActionQueue is guaranteed queryable.
-- Dedicated servers can have ISTimedActionQueue nil while NetTimedAction is
-- reconstructing an action; the vanilla/other-mod constructor chain we fall
-- back into may call ISTimedActionQueue.hasActionType() unconditionally.
-- @param parentCtor function Original vanilla constructor
local function callWithSafeTimedQueue(parentCtor, self, ...)
    if ISTimedActionQueue and ISTimedActionQueue.hasActionType then
        return parentCtor(self, ...)
    end

    local oldQueue = ISTimedActionQueue
    ISTimedActionQueue = { hasActionType = function() return false end }

    local ok, result = pcall(parentCtor, self, ...)
    ISTimedActionQueue = oldQueue

    if not ok then error(result) end
    return result
end

--------------------------------------------------------------------------------
-- Active-Smokable Redirect (relight / puff-from-context-menu)
--------------------------------------------------------------------------------

local function sameInventoryItem(a, b)
    if not a or not b then return false end
    if a == b then return true end
    if a.getID and b.getID then
        local aId, bId = a:getID(), b:getID()
        if aId and bId and aId == bId then return true end
    end
    return false
end

--- If the selected item is already the character's active smokable, redirect
-- to TakePuff (lit) or a LightSmoke relight (out) instead of starting a new
-- vanilla eat/pill action against the same item.
-- @param character IsoPlayer
-- @param item InventoryItem
-- @return ISBaseTimedAction|nil
local function makeExistingSmokeAction(character, item)
    if not character or not item then return nil end
    local data = TrueSmoking.Data.getSmoking(character)
    if not data or not data.isSmoking then return nil end

    local ref = TrueSmoking.getPlayerRef(character)
    local active = ref and ref.smokable
    if not active or not active.item or not sameInventoryItem(active.item, item) then
        return nil
    end

    -- Refresh the item reference used by the persistent object if MP replaced it.
    active.item = item

    if active.smokeLit then
        TrueSmoking.debug('Active smokable selected while lit; redirecting to TakePuff')
        return TakePuff:new(character, item, active.customEatSound, active.itemFullType)
    end

    -- Preserve the partial-cigarette ModData and re-enter only the lighting stage.
    setupSmokableHook(item)
    TrueSmoking.debug('Active smokable selected while out; redirecting to LightSmoke relight')
    return LightSmoke:new(character, item)
end

--------------------------------------------------------------------------------
-- ISTakePillAction Hook
--------------------------------------------------------------------------------

local originalPillActionNew = ISTakePillAction.new
function ISTakePillAction:new(character, item)
    if character and isSmokable(item) then
        local existing = makeExistingSmokeAction(character, item)
        if existing then return existing end

        local data = TrueSmoking.Data.getSmoking(character)
        local ref = TrueSmoking.getPlayerRef(character)

        -- Locally we think we're smoking but lost the SmokableItem object
        -- (dedicated-server race); repair instead of sending another action.
        if data and data.isSmoking and not isServer() and not (ref and ref.smokable) then
            TrueSmoking.endSmokingCleanly(character, 'Repaired stale smoking state before pill-route relight')
            setupSmokableHook(item)
            return LightSmoke:new(character, item)
        end

        -- Bypass the vanilla constructor chain entirely for a fresh smoke: if
        -- another mod's getDuration hook can't handle the cigarette, it can
        -- error out before True Smoking ever gets to redirect the action.
        if data and not data.isSmoking
            and not (ISTimedActionQueue and ISTimedActionQueue.hasActionType
                and ISTimedActionQueue.hasActionType(character, 'LightSmoke')) then
            TrueSmoking.debug('ISTakePillAction:new - Hooking: ' .. tostring(item:getOnEat()))
            setupSmokableHook(item)
            return LightSmoke:new(character, item)
        end
    end

    return callWithSafeTimedQueue(originalPillActionNew, self, character, item)
end

--------------------------------------------------------------------------------
-- ISEatFoodAction Hook
--------------------------------------------------------------------------------

local originalFoodActionNew = ISEatFoodAction.new
function ISEatFoodAction:new(character, item, percentage)
    if character and isSmokable(item) then
        local existing = makeExistingSmokeAction(character, item)
        if existing then return existing end

        local data = TrueSmoking.Data.getSmoking(character)
        local ref = TrueSmoking.getPlayerRef(character)

        if data and data.isSmoking and not isServer() and not (ref and ref.smokable) then
            TrueSmoking.endSmokingCleanly(character, 'Repaired stale smoking state before relight')
            setupSmokableHook(item)
            return LightSmoke:new(character, item)
        end

        if data and not data.isSmoking
            and not (ISTimedActionQueue and ISTimedActionQueue.hasActionType
                and ISTimedActionQueue.hasActionType(character, 'LightSmoke')) then
            TrueSmoking.debug('ISEatFoodAction:new - Hooking: ' .. tostring(item:getOnEat()))
            setupSmokableHook(item)
            return LightSmoke:new(character, item)
        end
    end

    return callWithSafeTimedQueue(originalFoodActionNew, self, character, item, percentage)
end

--------------------------------------------------------------------------------
-- ISUnequipAction Hook
--------------------------------------------------------------------------------

-- The dedicated mouth visual is server-created and can arrive at
-- NetTimedAction.parseServer with no resolvable InventoryItem (item == nil on
-- the server), which would otherwise wedge this action in the queue forever.
local function isSmokingVisual(item)
    if not item or not item.getBodyLocation then return false end
    return item:getBodyLocation() == TrueSmoking.registries.mask
end

local function makeNoopUnequip(character)
    local o = ISBaseTimedAction.new(ISUnequipAction, character)
    o.character = character
    o.item = nil
    o.maxTime = 1
    o.stopOnWalk = false
    o.stopOnRun = false
    o.stopOnAim = false
    o._TrueSmokingNoop = true
    o.Type = 'ISUnequipAction'
    return o
end

local originalUnequipNew = ISUnequipAction.new
function ISUnequipAction:new(character, item, maxTime)
    local data = character and TrueSmoking.Data.getSmoking(character) or nil

    -- Unequipping the mouth visual as clothing is what produces a nil item on
    -- the server. Redirect the user's intent to the normal PutOut action.
    if item and isSmokingVisual(item) and data and data.isSmoking then
        local ref = TrueSmoking.getPlayerRef(character)
        local smokable = ref and ref.smokable

        if smokable and smokable.item then
            TrueSmoking.debug('Manual visual unequip redirected to PutOut')
            return PutOut:new(
                character,
                smokable.item,
                smokable.smokeLength,
                smokable.customEatSound,
                smokable.itemFullType
            )
        end

        -- State says smoking but the client lost its SmokableItem object.
        TrueSmoking.endSmokingCleanly(character, 'Manual visual unequip had no SmokableItem; cleaning state')
        return makeNoopUnequip(character)
    end

    -- Never enter the vanilla path with a nil item: the complete() hook below
    -- (and vanilla code) calls item:getBodyLocation() unconditionally.
    if not item then
        TrueSmoking.debug('ISUnequipAction:new received nil item; swallowing stale MP action')
        return makeNoopUnequip(character)
    end

    local o = originalUnequipNew(self, character, item, maxTime)

    -- Instant unequip for visual smoke items
    if item:getBodyLocation() == TrueSmoking.registries.mask and data.isSmoking then
        o.maxTime = 1
    end

    return o
end

-- Every lifecycle method must stay away from vanilla code that expects
-- self.item to exist whenever a no-op action was returned above.
local originalUnequipIsValid = ISUnequipAction.isValid
function ISUnequipAction:isValid()
    if self._TrueSmokingNoop then return true end
    if not self.item then return false end
    return originalUnequipIsValid and originalUnequipIsValid(self) or true
end

local originalUnequipWaitToStart = ISUnequipAction.waitToStart
if originalUnequipWaitToStart then
    function ISUnequipAction:waitToStart()
        if self._TrueSmokingNoop then return false end
        return originalUnequipWaitToStart(self)
    end
end

local originalUnequipStart = ISUnequipAction.start
if originalUnequipStart then
    function ISUnequipAction:start()
        if self._TrueSmokingNoop then
            if self.setUseProgressBar then self:setUseProgressBar(false) end
            return
        end
        return originalUnequipStart(self)
    end
end

local originalUnequipUpdate = ISUnequipAction.update
if originalUnequipUpdate then
    function ISUnequipAction:update()
        if self._TrueSmokingNoop then return end
        return originalUnequipUpdate(self)
    end
end

local originalUnequipStop = ISUnequipAction.stop
if originalUnequipStop then
    function ISUnequipAction:stop()
        if self._TrueSmokingNoop then
            return ISBaseTimedAction.stop(self)
        end
        return originalUnequipStop(self)
    end
end

local originalUnequipPerform = ISUnequipAction.perform
if originalUnequipPerform then
    function ISUnequipAction:perform()
        if self._TrueSmokingNoop then
            return ISBaseTimedAction.perform(self)
        end
        return originalUnequipPerform(self)
    end
end

local originalUnequipComplete = ISUnequipAction.complete
function ISUnequipAction:complete()
    -- A no-op action, or a stale packet that lost its item, must never reach
    -- vanilla code that dereferences self.item.
    if self._TrueSmokingNoop or not self.item then
        local character = self.character
        if character then
            local data = TrueSmoking.Data.getSmoking(character)
            if data then
                data.isSmoking = false
                data.takingPuff = false
            end
            TrueSmoking.Visuals.removeMask(character)
            if isServer() then
                sendServerCommand(character, 'TrueSmoking', 'forceCleanup', {})
            end
        end
        return true
    end

    originalUnequipComplete(self)

    local data = TrueSmoking.Data.getSmoking(self.character)
    local ref = TrueSmoking.getPlayerRef(self.character)

    -- Put out smoke if visual item is unequipped while smoking
    if self.item:getBodyLocation() == TrueSmoking.registries.mask and data.isSmoking then
        if ref and ref.smokable then
            ref.smokable:putOut()
        end
    end

    return true
end

--------------------------------------------------------------------------------
-- ISWearClothing Hook
--------------------------------------------------------------------------------

local originalClothingComplete = ISWearClothing.complete
function ISWearClothing:complete()
    local rtn = originalClothingComplete(self)

    local data = TrueSmoking.Data.getSmoking(self.character)

    -- Clear mask flag when equipped
    if self.item == data.mask then
        data.mask = false
    end

    return rtn
end

local SMOKING_BLOCKERS = {
    Mask = true,
    MaskEyes = true,
    MaskFull = true,
    FullHat = true,
    FullSuitHead = true,
    SCBA = true,
    SCBAnotank = true,
}

local originalClothingNew = ISWearClothing.new
function ISWearClothing:new(character, item)
    local data = TrueSmoking.Data.getSmoking(character)
    local wasSmoking = data and data.isSmoking
    local bodyLoc = item and item.getBodyLocation and item:getBodyLocation() or nil
    local blocksSmoking = bodyLoc and SMOKING_BLOCKERS[bodyLoc]
        and not (item.hasTag and item:hasTag(ItemTag.CAN_EAT))

    local o = originalClothingNew(self, character, item)

    -- Equipping blocking headgear while smoking can otherwise leave the
    -- SmokableItem and visual mask alive; finish the session instead.
    if wasSmoking and blocksSmoking then
        TrueSmoking.endSmokingCleanly(character, 'Blocking headgear equipped while smoking; cleaning state')
    end

    return o
end

--------------------------------------------------------------------------------
-- ISClothingExtraAction Hook (minimal)
--------------------------------------------------------------------------------

local originalExtraActionNew = ISClothingExtraAction.new
function ISClothingExtraAction:new(character, item, extra)
    return originalExtraActionNew(self, character, item, extra)
end

--------------------------------------------------------------------------------
-- I Don't Need A Lighter (NoLighterNeeded) Compatibility
--
-- IDNAL's B42 branch uses its own IsCarSmoking / IsStoveSmoking timed actions
-- whose complete() calls character:Eat(item, 1), consuming the item through
-- vanilla instead of True Smoking's LightSmoke/SmokableItem pipeline. That
-- bypasses partial-cigarette persistence, puffing, and nicotine handling.
--
-- Redirect only the final smoking action. IDNAL keeps ownership of finding and
-- validating the source, walking to it, and heating the car/stove lighter.
--------------------------------------------------------------------------------

local function prepareIDNALSmokable(item)
    if not item then return end

    -- Mirror the normal preparation above so replace-on-use smokables (pipes,
    -- etc.) retain their normal True Smoking behavior.
    local replace = item.getReplaceOnUseFullType and item:getReplaceOnUseFullType() or nil
    if replace and replace ~= '' then
        item:getModData().replaceOnUse = replace
        item:setReplaceOnUse(nil)
    end

    item:getModData().modOnEat = 'OnEat_Hook'
end

local function makeIDNALLightSmoke(character, item, source)
    if not character or not item or not LightSmoke or not LightSmoke.new then
        return nil
    end

    local data = TrueSmoking.Data.getSmoking(character)

    -- If a True Smoking session/action is already active, fall back to IDNAL's
    -- original action instead of starting a second smoking state.
    if data and data.isSmoking then return nil end
    if ISTimedActionQueue and ISTimedActionQueue.hasActionType
        and ISTimedActionQueue.hasActionType(character, 'LightSmoke') then
        return nil
    end

    prepareIDNALSmokable(item)

    local action = LightSmoke:new(character, item)
    if not action then return nil end

    -- IDNAL already validated the selected source; force it into LightSmoke so
    -- it doesn't try to consume a normal inventory lighter.
    if source == 'car' then
        action.carLighter = true
        action.openFlame = false
    elseif source == 'heat' then
        action.openFlame = true
        action.carLighter = false
    end

    return action
end

local idnalCompatibilityInstalled = false

local function installIDNALCompatibility()
    if idnalCompatibilityInstalled then return end

    local patchedCar, patchedStove = false, false

    if IsCarSmoking and IsCarSmoking.new and not IsCarSmoking._TrueSmokingHooked then
        local originalCarNew = IsCarSmoking.new
        IsCarSmoking._TrueSmokingHooked = true
        function IsCarSmoking:new(character, item)
            local redirected = makeIDNALLightSmoke(character, item, 'car')
            if redirected then
                TrueSmoking.debug('Redirected IDNAL car lighter to LightSmoke')
                return redirected
            end
            return originalCarNew(self, character, item)
        end
        patchedCar = true
    elseif IsCarSmoking and IsCarSmoking._TrueSmokingHooked then
        patchedCar = true
    end

    if IsStoveSmoking and IsStoveSmoking.new and not IsStoveSmoking._TrueSmokingHooked then
        local originalStoveNew = IsStoveSmoking.new
        IsStoveSmoking._TrueSmokingHooked = true
        function IsStoveSmoking:new(character, worldobject, item)
            local redirected = makeIDNALLightSmoke(character, item, 'heat')
            if redirected then
                TrueSmoking.debug('Redirected IDNAL heat source to LightSmoke')
                return redirected
            end
            return originalStoveNew(self, character, worldobject, item)
        end
        patchedStove = true
    elseif IsStoveSmoking and IsStoveSmoking._TrueSmokingHooked then
        patchedStove = true
    end

    -- IDNAL may load after True Smoking. Only mark installed once both
    -- classes actually exist and were patched.
    if patchedCar and patchedStove then
        idnalCompatibilityInstalled = true
    end
end

-- Immediate attempt plus lifecycle retries for MP load-order safety.
installIDNALCompatibility()
Events.OnGameStart.Add(installIDNALCompatibility)
Events.OnCreatePlayer.Add(function()
    installIDNALCompatibility()
end)
