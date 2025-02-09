require 'TimedActions/ISBaseTimedAction'
require 'Utils'

Smokable = Smokable or {}
Smokable.__index = Smokable

--Smokable class creates an object from any smokable items. It tracks the burn rate and smoke length as its
--smoked, and triggers the SmokingMoodle to start and stop smoking

--Create a new Smokable object from consumed item (ISEatFoodAction)
function Smokable:new(item, TrueSmoking)
    local obj = {}
    setmetatable(obj, self)

    local puffMin, puffMax = TrueSmoking.Config.PassiveMinTime, TrueSmoking.Config.PassiveMaxTime
    obj.burnMin, obj.burnMax = 0.000135, 0.000365

    obj.TrueSmoking = TrueSmoking
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

    obj.smokeLength = self:getSmokeLength(item, TrueSmoking)

    obj.originalSmokeLength = obj.smokeLength
    obj.smokePercent = 1.0
    obj.smokeLit = false
    obj.burnRate = ZombRandFloat(obj.burnMin,obj.burnMax)
    obj.timeCheck = ZombRand(puffMin,puffMax)

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
function Smokable:getSmokeLength(item, TrueSmoking)
    local list = {
        ["Cigarette"] = TrueSmoking.Options.CigaretteLength or 1.0,
        ["Cigar"] = TrueSmoking.Options.CigarLength or 3.0,
        ["Cigarillo"] = TrueSmoking.Options.CigarilloLength or 1.5,
        ["Smoking Pipe with Tobacco"] = TrueSmoking.Options.PipeLength or 1.75,
        ["Can Pipe with Tobacco"] = TrueSmoking.Options.CanLength or 2.5,
        --Hemp&Tabacco
        ["Hemp Cigarette"] = TrueSmoking.Options.CigaretteLength or 1.0,
        ["Cigar (Hemp)"] = TrueSmoking.Options.CigarLength or 3.0,
        ["Cheroot (Hemp)"] = TrueSmoking.Options.CigarilloLength or 1.5,
        ["Smoking Pipe with Hemp"] = TrueSmoking.Options.PipeLength or 1.75,
        ["Glass Smoking Pipe with Hemp"] = 1.5,
        ["Glass Smoking Pipe with Tobacco"] = 1.5,
    }

    -- 1. if our override is set, return that
    if TrueSmoking.Options.OverrideSmokeLength then return TrueSmoking.Options.SmokeLength end

    -- 2. if an item has smokeLength set use that
    if item:getModData().smokeLength and item:getModData().smokeLength > 0 then
        return item:getModData().smokeLength
    end

    local listReeferMadness = {
        ['OnEat_WeedPipe'] = 1.5,
        ['OnEat_WeedJoint'] = 1.0
    }

    -- 3. check our lists for predefined values (sandbox/hard coded)
    for name, length in pairs(listReeferMadness) do
        if item:getOnEat() == name then
            return length
        end
    end

    for name, length in pairs(list) do
        if item:getDisplayName() == name then
            return length
        end
    end

    -- 4. safety return for default value
    return TrueSmoking.Options.SmokeLength -- default smoke length
end

--Start smoking and light the smokable
function Smokable:light()
    if not self.TrueSmoking.isSmoking then
        self.TrueSmoking.isSmoking = true
        self.TrueSmoking.Moodle:start()

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
            ISTimedActionQueue.add(LightSmoke:new(getPlayer()))
        end

        self.smokeLit = true
        self.puffTimeMark = os.time() --Record the light as a puff

        if self.burnRate == 0 then
            self.burnRate = ZombRandFloat(self.burnMin, self.burnMax)
        end

        -- getPlayer():setWornItem("Mask", self.item)
        -- getPlayer():setWornItem("MakeUp_Lips", self.item)
    end
end

--Stop smoking and remove the update event
function Smokable:putOut()
    -- if self.TrueSmoking.isSmoking then
    --     ISTimedActionQueue.add(PutOut:new(getPlayer()))
    -- end

    self.TrueSmoking.isSmoking = false
    self.TrueSmoking.takingPuff = false
    self.smokeLit = false

    self.TrueSmoking.Moodle:stop()

    if self.updateWrapper then
        Events.OnTick.Remove(self.updateWrapper)
        self.updateWrapper = nil
    end

    local onUse = self.replaceOnUse
    if onUse and onUse ~= '' then
        -- print("Calling on use")
        addOnUseItem()
    end

    self.item = {}  --clear item for safety.
end

--Updates the burnRate and smokeLength on game tick, tracks when the smoke is out or finished
function Smokable:update()
    --If smoke is lit update burnRate
    if self.smokeLit then
        --Try to take idle puff before calculate burn changes
        self:idlePuff()
        -- print(string.format('Smokable is lit - Burn Rate: %.6f', self.burnRate))
        if self.TrueSmoking.takingPuff then
            --change burn rate with puffFactor
            if self.burnRate < self.burnMin then
                self.burnRate = self.burnRate + self.burnRate * 0.01 * self.TrueSmoking.Options.PuffFactor
            elseif self.burnRate < self.burnMax then
                self.burnRate = self.burnRate + self.burnRate * 0.001 * self.TrueSmoking.Options.PuffFactor
            else
                self.burnRate = self.burnRate + self.burnRate * 0.00001 * self.TrueSmoking.Options.PuffFactor
            end
        elseif getPlayer():isRunning() or getPlayer():isSprinting() then
            --change burn rate with runningFactor
            self.burnRate = self.burnRate - self.burnRate * 0.001 * self.TrueSmoking.Options.RunningFactor
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
    if self.TrueSmoking.Options.SmokeRelighting and self.burnRate < 0.000002 then
        self.burnRate = 0
        self.smokeLit = false
    elseif not self.TrueSmoking.Options.SmokeRelighting and self.burnRate < self.burnMin then
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
    if self.smokeLength-self.burnRate > 0 then
        ISTimedActionQueue.add(TakePuff:new(getPlayer()))
    end
end

--Passive puff action triggered by PassiveSmoking
function Smokable:idlePuff()
    local timeDiff = os.difftime(os.time(), self.puffTimeMark)

    if self.TrueSmoking.Config.PassiveSmoking and timeDiff >= self.timeCheck then
        local puff = TakePuff:new(getPlayer())
        puff.maxTime = 80
        TrueSmoking.Smokable.puffTimeMark = os.time()
        ISTimedActionQueue.add(puff)
        self.timeCheck = ZombRand(self.TrueSmoking.Config.PassiveMinTime, self.TrueSmoking.Config.PassiveMaxTime)
    end
end

