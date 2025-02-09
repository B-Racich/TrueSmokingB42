function isInList(str, list)
    if str == "" then
        return false
    end
    local listString = table.concat(list, ",")
    return string.find(listString, str) ~= nil
end

function addOnUseItem()
    local player = getPlayer()
    local type = TrueSmoking.Smokable.item:getFullType()
    local item = TrueSmoking.Smokable.replaceOnUse
    local base = type:match("^[^.]+")
    if base then
        local str = base..'.'..item
        if item and item ~= '' then
            -- print('add item')
            player:getInventory():AddItem(str)
        end
    end
end

function callModFunction(func)
    return function(item, player, percent)
        func(item, player, percent)
    end
end

function getStats()
    local o = {}

    local player = getPlayer()
    local stats, body = player:getStats(), player:getBodyDamage()

    o.stress = stats:getStress()
    o.stressFromCigarettes = stats:getStressFromCigarettes()
    o.timeSinceLastSmoke = player:getTimeSinceLastSmoke()
    o.unhappyness = body:getUnhappynessLevel()
    o.boredom = body:getBoredomLevel()
    o.foodSickness = body:getFoodSicknessLevel()

    return o
end

function setStats(o)
    local player = getPlayer()
    local stats, body = player:getStats(), player:getBodyDamage()

    stats:setStress(o.stress - stats:getStressFromCigarettes())
    stats:setStressFromCigarettes(o.stressFromCigarettes)
    player:setTimeSinceLastSmoke(o.timeSinceLastSmoke)
    body:setUnhappynessLevel(o.unhappyness)
    body:setBoredomLevel(o.boredom)
    body:setFoodSicknessLevel(o.foodSickness)
end