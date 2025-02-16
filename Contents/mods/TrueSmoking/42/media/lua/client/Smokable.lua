require 'TimedActions/ISBaseTimedAction'
require 'Utils'

Smokable = Smokable or {}
Smokable.__index = Smokable

--[[
    Smokable class that creates our object from smokable items.

    The majority of the smoking logic is handled here, the update method runs onTick to calculate the burn rate and call the OnEat_OverTime
    method.

    The moodle is started/stopped here but stored in the TrueSmoking table reference

    visualItem is hardcoded to sync with the default smoking anim based on a timer
]]

--Create a new Smokable object from consumed item (ISEatFoodAction)
function Smokable:new(item, player)
    local obj = {}
    setmetatable(obj, self)

    local puffMin, puffMax = TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime
    obj.burnMin, obj.burnMax = 0.000135, 0.000365

    obj.player = player

    obj.table = TrueSmoking:getPlayerReference(player)

    obj.item = item
    obj.onEat = item:getOnEat() or ''
    obj.replaceOnUse = item:getReplaceOnUse() or ''

    obj.stress = item:getStressChange() or -5
    obj.originalStress = obj.stress

    obj.boredom = item:getBoredomChange() or 0
    obj.originalBoredom = obj.boredom

    obj.unhappyness = item:getUnhappyChange() or 0
    obj.originalUnhappyness = obj.unhappyness

    obj.fatigue = item:getFatigueChange() or 0
    obj.originalFatigue = obj.fatigue

    obj.thirst = item:getThirstChange() or 0
    obj.originalThirst = obj.thirst

    obj.hunger = item:getHungChange() or 0
    obj.originalHunger = obj.hunger

    obj.pain = item:getPainReduction() or 0
    obj.originalPain = obj.pain

    obj.endurance = item:getEnduranceChange() or 0
    obj.originalEndurance = obj.endurance

    obj.foodSick = self:getFoodSick(item)
    obj.originalFoodSick = obj.foodSick

    obj.reduceFoodSick = item:getReduceFoodSickness() or 0
    obj.originalReduceFoodSick = obj.reduceFoodSick

    obj.replaceOnUse = item:getReplaceOnUseFullType() or ''

    obj.smokeLength = self:getSmokeLength(item)

    obj.originalSmokeLength = obj.smokeLength
    obj.smokePercent = 1.0
    obj.smokeLit = false
    obj.burnRate = ZombRandFloat(obj.burnMin,obj.burnMax)
    obj.timeCheck = ZombRand(puffMin,puffMax)
    obj.removedVisualItem = false

    --NnC vals
    obj.NnC_StiffRemoval = 15
    obj.NnC_OriginalStiffRemoval = obj.NnC_StiffRemoval
    obj.NnC_PainThresh = 50
    obj.NnC_OriginalPainThresh = obj.NnC_PainThresh

    return obj
end

function Smokable:getFoodSick(item)
    local list = {
        ["OnEat_Cigarettes"] = 14,
        ["OnEat_Cigarillo"] = 21,
        ["OnEat_Cigar"] = 28,
        ['OnEat_WeedPipe'] = 8,
        ['OnEat_WeedJoint'] = 32
    }

    for name, val in pairs(list) do
        if item:getOnEat() == name then
            return val
        end
    end

    return 0
end

--Helper function to set smokeLengths
--TODO likely rewrite this
function Smokable:getSmokeLength(item)
    --The vanilla items could be checking onEat but we have to use names to properly set Hemp&Tobacco
    local list = {
        ["Cigarette"] = TrueSmoking.Options.CigaretteLength or 1.0,
        ["Cigar"] = TrueSmoking.Options.CigarLength or 3.0,
        ["Cigarillo"] = TrueSmoking.Options.CigarilloLength or 1.5,
        ["Smoking Pipe with Tobacco"] = TrueSmoking.Options.PipeLength or 1.75,
        ["Can Pipe with Tobacco"] = TrueSmoking.Options.CanLength or 2.5,
        --Hemp&Tobacco
        ["Hemp Cigarette"] = TrueSmoking.Options.CigaretteLength or 1.0,
        ["Cigar (Hemp)"] = TrueSmoking.Options.CigarLength or 3.0,
        ["Cheroot (Hemp)"] = TrueSmoking.Options.CigarilloLength or 1.5,
        ["Smoking Pipe with Hemp"] = TrueSmoking.Options.PipeLength or 1.75,
        -- Give these a slightly faster smoke time (more effecient)
        ["Glass Smoking Pipe with Hemp"] = 1.5,
        ["Glass Smoking Pipe with Tobacco"] = 1.5,
    }

    --ReeferMadness adjustment, we we just check the modded onEat
    local listReeferMadness = {
        ['OnEat_WeedPipe'] = 1.5,
        ['OnEat_WeedJoint'] = 1.0
    }

    -- 1. if our override is set, return that
    if TrueSmoking.Options.OverrideSmokeLength then return TrueSmoking.Options.SmokeLength end

    -- 2. if an item has smokeLength set use that
    if item:getModData().smokeLength and item:getModData().smokeLength > 0 then
        return item:getModData().smokeLength
    end

    -- 3. check our lists for predefined values (sandbox/hard coded)
    for name, length in pairs(listReeferMadness) do
        if item:getOnEat() == name then
            return length
        end
    end
    -- 4. use displayNames after checking onEat
    for name, length in pairs(list) do
        if item:getDisplayName() == name then
            return length
        end
    end

    -- 5. safety return for default value
    return TrueSmoking.Options.SmokeLength -- default smoke length
end

function Smokable:equipVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return end
    if not self.player:getWornItem('Mask') then
        self.player:setWornItem(self.table.visualItem:getBodyLocation(), self.table.visualItem);
    end
end

function Smokable:removeVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return end
    if self.table.visualItem and self.player:getWornItem('Mask') == self.table.visualItem then
        self.player:removeWornItem(self.table.visualItem)
    end
end

function Smokable:getVisualItem()
    if not TrueSmoking.Options.ManageHeadGear then return false end
    if self.item and not self.table.visualItem then
        local items = {
            ['Cigarette'] = 'Mask_Cigarette',
            ['Cheroot'] = 'Mask_Cigarillo',
            ['Cigar'] = 'Mask_Cigar',
            ['Smoking Pipe with Tobacco'] = 'Mask_Pipe'
        }
        local itemName = self.item:getDisplayName()
        print(string.format('Item Display Name: %s',itemName))

        if items[itemName] then
            return instanceItem(items[itemName])
        else
            return false
        end
    end
end

--Start smoking and light the smokable
function Smokable:light()
    if not self.table.isSmoking then
        self.table.isSmoking = true
        self.table.Moodle:start()

        --Start the update event
        local function updateWrapper()
            self:update()
        end
        Events.OnTick.Add(updateWrapper)
        self.updateWrapper = updateWrapper
    end
    if not self.smokeLit then
        --Allows relighting of smoke but lets the native call run first time
        if self.smokeLength ~= self.originalSmokeLength then
            ISTimedActionQueue.add(LightSmoke:new(self.player))
        end

        self.smokeLit = true
        self.puffTimeMark = os.time() --Record the light as a puff

        if self.burnRate == 0 then
            self.burnRate = ZombRandFloat(self.burnMin, self.burnMax)
        end

        self.table.visualItem = self:getVisualItem()
        self:equipVisualItem()
    end
end

--Stop smoking and remove the update event
function Smokable:putOut()
    if self.table.takingPuff then return end
    --Placeholder for putOut action (need a custom animation to be proper)
    if self.table.isSmoking then
        ISTimedActionQueue.add(PutOut:new(self.player))
    end
end

--Updates the burnRate and smokeLength on game tick, tracks when the smoke is out or finished
function Smokable:update()
    --If smoke is lit update burnRate
    if self.smokeLit then
        --Try to take idle puff before calculate burn changes
        self:idlePuff()
        -- print(string.format('Smokable is lit - Burn Rate: %.6f', self.burnRate))
        if self.table.takingPuff then
            --change burn rate with puffFactor
            if self.burnRate < self.burnMin then
                self.burnRate = self.burnRate + self.burnRate * 0.01 * TrueSmoking.Options.PuffFactor
            elseif self.burnRate < self.burnMax then
                self.burnRate = self.burnRate + self.burnRate * 0.001 * TrueSmoking.Options.PuffFactor
            else
                self.burnRate = self.burnRate + self.burnRate * 0.00001 * TrueSmoking.Options.PuffFactor
            end
        elseif self.player:isRunning() or self.player:isSprinting() then
            --change burn rate with runningFactor
            self.burnRate = self.burnRate - self.burnRate * 0.001 * TrueSmoking.Options.RunningFactor
        else
            --change burn rate with idleFactor
            self.burnRate = self.burnRate - self.burnRate * 0.001
        end

        --How much % we smoked this tick
        self.puffPercent = self.burnRate / self.originalSmokeLength
        --Update Smoke Length
        self.smokeLength = self.smokeLength - self.burnRate
        --Update smoke % left
        self.smokePercent = self.smokeLength / self.originalSmokeLength
        --Apply stat changes
        OnEat_OverTime(self)
    end

    --Smoke went out (burn rate is 0)
    if TrueSmoking.Options.SmokeRelighting and self.burnRate < 0.000002 then
        self.burnRate = 0
        self.smokeLit = false
    elseif not TrueSmoking.Options.SmokeRelighting and self.burnRate < self.burnMin then
        self.burnRate = self.burnMin
    end

    --Smoke is finished (smokeLength is 0)
    if self.smokeLength < 0 then
        self.smokeLength = 0
        self:putOut()
    end
end

--Manual puff action while smokeKey is held
function Smokable:puff()
    ISTimedActionQueue.add(TakePuff:new(self.player))
end

--Passive puff action triggered by PassiveSmoking
function Smokable:idlePuff()
    local timeDiff = os.difftime(os.time(), self.puffTimeMark)

    if TrueSmoking.Config.PassiveSmoking and timeDiff >= self.timeCheck then
        local puff = TakePuff:new(self.player)
        puff.maxTime = 180
        self.puffTimeMark = os.time()
        ISTimedActionQueue.add(puff)
        self.timeCheck = ZombRand(TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime)
    end
end

