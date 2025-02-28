require 'TimedActions/ISEatFoodAction'

local originalActionNew = ISEatFoodAction.new
local originalActionStart = ISEatFoodAction.start
local originalActionComplete = ISEatFoodAction.complete

--Hook the ISEatFoodAction to grab smokable items and make our changes
function ISEatFoodAction:new(character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local hook = 'OnEat_Hook'
    local hasSmokableTag = item:getTags():contains('Smokable')
    local funcsToHook = {'OnEat_Cigarettes','OnEat_Cigarillo','OnEat_Cigar',
    'OnEat_WeedSmoke','OnEat_WeedJoint','OnEat_WeedPipe', hook}

    --Store the original action to return it if we don't need to hook it
    o = originalActionNew(self, character, item, percentage)

    local trueSmoking = TrueSmoking:getPlayerReference(character)
    o.trueSmoking = trueSmoking

    if isInList(onEat, funcsToHook) or hasSmokableTag then
        print('Hooking: '..onEat..' -> '..hook)
        if not trueSmoking.isSmoking then
            print('setting up smokable')
            trueSmoking.Smokable = Smokable:new(item, character)
            -- print('Made new smokable')
            item:setReplaceOnUse(nil) --nil this fields to avoid consuming the item 

            item:getModData().modOnEat = onEat
            item:setOnEat(hook)

            o.item = item
            o.maxTime = TrueSmoking.lightTime;
        end
    end

    return o
end

function ISEatFoodAction:complete()
    -- print('inside complete')
    if self.item:getOnEat() == 'OnEat_Hook' then
        -- print('complete hook')
        self.trueSmoking.Smokable.smokeLit = true
        self.trueSmoking.Smokable.puffTimeMark = os.time()
        self.trueSmoking.lightingEatSound = ''

        if self.trueSmoking.Smokable.burnRate == 0 then
            self.trueSmoking.Smokable.burnRate = ZombRandFloat(self.trueSmoking.Smokable.burnMin, self.trueSmoking.Smokable.burnMax)
        end

        -- print('call light')
        self.trueSmoking.Smokable:light()
        return true
    else
        -- print('complete non hook')
        originalActionComplete(self)
    end
	return true;
end

function ISEatFoodAction:start()
    -- print('starting original')
    originalActionStart(self)
    if self.item:getOnEat() == 'OnEat_Hook' then
        -- print('starting hook')
        local hasPrimary = self.character:getPrimaryHandItem()
        if hasPrimary then
            self:setOverrideHandModels(hasPrimary, self.item)
        else
            self:setOverrideHandModels(nil, self.item)
        end

        if getActivatedMods():contains('\\SmokingSoundsOverhaul') then
            print('eatAudio '..self.eatAudio)
            print('eatSound '..self.eatSound)
            if (self.eatAudio == 0 and (self.eatSound == '' or self.eatSound == 'm' or self.eatSound == 'f')) then
                self.eatSound = SmokingSoundsOverhaul:getLightingSound(self.character, self.item)
                self.trueSmoking.lightingEatSound = self.eatSound
                self.eatAudio = self.eatSound
            end
        end
    end
end