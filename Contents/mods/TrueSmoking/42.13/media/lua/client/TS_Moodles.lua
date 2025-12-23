require ' MF_ISMoodle'
require 'TrueSmoking'

-- local moodleID = TrueSmoking.Options.UseNewMoodle and 'TS_Smoking_New' or 'TS_Smoking_Old'
MF.createMoodle('TS_Smoking_New')
MF.createMoodle('TS_Nicotine')

local tsDebug = TrueSmoking.tsDebug

function TrueSmoking.updateSmokingMoodle(player)
    -- local moodleID = TrueSmoking.Options.UseNewMoodle and 'TS_Smoking_New' or 'TS_Smoking_Old'
    local playerNum = player:getPlayerNum()
    local moodle = MF.getMoodle('TS_Smoking_New', playerNum)
    if moodle == nil then
        -- tsDebug('TRUESMOKING::No smoking moodle found for player')
        return
    end

    local data = player:getModData().TrueSmoking
    if data == nil then
        -- print('TRUESMOKING::No mod data found for player, cannot update smoking moodle')
        moodle:setValue(0.5)
        return
    end

    local ts = TrueSmoking:getPlayerReference(playerNum)
    local item = ts.Smokable
    if not item or not item.smokeLength then
        -- print('TRUESMOKING::No item found on smokable item, cannot update moodle')
        moodle:setValue(0.5)
        return
    end
    local smokeLit = item.smokeLit
    local percent = item.smokeLength and (item.smokeLength / item.originalSmokeLength) or 0
    local percentVal = tonumber(percent) or 0
    local displayedPercentage = string.format('%.1f%%', percentVal * 100)

    local estimateLeft = {
        [0] = '< 1/8',
        [10] = '~ 1/8',
        [20] = '~ 2/8',
        [30] = '~ 3/8',
        [40] = '~ 4/8',
        [50] = '~ 5/8',
        [60] = '~ 6/8',
        [80] = '~ 7/8',
        [90] = '~ 8/8'
    }

    local estimate = '~'

    if TrueSmoking.Config.ShowSmokePercent then
        estimate = displayedPercentage
    else
        local highestEstimate = '~'
        for k, v in pairs(estimateLeft) do
            if percentVal * 100 >= k then
                highestEstimate = v
            end
        end
        estimate = highestEstimate
    end

    local smokeLitText = smokeLit and 'lit' or 'out'

    moodle:setThresholds(0.10, 0.20, 0.35, 0.4999, 0.5001, 0.65, 0.85, 0.90)

    -- Only wiggle once every minute if the smoke is not lit
    -- if not data.lastWiggleTime then
    --     data.lastWiggleTime = os.time()
    -- end

    -- local currentTime = os.time()
    -- if not smokeLit and (currentTime - data.lastWiggleTime >= 10) then
    --     moodle:doWiggle()
    --     data.lastWiggleTime = currentTime
    -- end

    -- if TrueSmoking.Config.HideMoodles then
    --     percentVal = 0.5
    -- end

    if not data.isSmoking then
        percentVal = 0.5
    end


    moodle:setValue(percentVal)

    local debugInfo = '..'
    if TrueSmoking.Config.DebugMoodles then
        debugInfo = TrueSmoking.smokingDebugInfo(item)
    end

    moodle:setDescription(
        moodle:getGoodBadNeutral(),
        moodle:getLevel(),
        getText('Moodles_smoking_Custom', smokeLitText, estimate) .. debugInfo
    )
    -- tsDebug('TRUESMOKING::Updated smoking moodle - smokeLit: ' .. tostring(smokeLit) ..
    --     ', percent: ' .. tostring(displayedPercentage) .. ', estimate: ' .. tostring(estimate))
end

function TrueSmoking.smokingDebugInfo(item)
    local debugText = '\n\n[DEBUG INFO]'

    debugText = debugText .. string.format('\nCurrent Length: %.2f', item.smokeLength)
    debugText = debugText .. string.format('\nOriginal Length: %.2f', item.originalSmokeLength)
    debugText = debugText .. string.format('\nRemaining: %.1f%%', (item.smokeLength / item.originalSmokeLength) * 100)
    debugText = debugText .. string.format('\nLit Status: %s', item.smokeLit and 'Lit' or 'Out')
    debugText = debugText .. string.format('\nPuff Percent: %.6f', item.puffPercent)

    debugText = debugText .. string.format('\n\n[Burn Parameters]')
    debugText = debugText .. string.format('\nCurrent Rate: %.8f', item.burnRate)
    debugText = debugText .. string.format('\nTarget Min: %.8f', item.burnMin)
    debugText = debugText .. string.format('\nTarget Max: %.8f', item.burnMax)
    debugText = debugText .. string.format('\nDecay Rate: %.8f', item.decayRate)
    debugText = debugText .. string.format('\nBurn Speed: %.8f', item.burnSpeed)
    debugText = debugText .. string.format('\nBurn Speed Decay: %.8f', item.burnSpeedDecay)

    debugText = debugText .. string.format('\n\n[Effect Parameters]')
    debugText = debugText .. string.format('\nEffect Multiplier: %.2f', item.effectMultiplier)
    debugText = debugText .. string.format('\nNicotine Content: %.2f', item.nicotineContent)

    debugText = debugText .. string.format('\n\n[Activity Factors]')
    debugText = debugText .. string.format('\nPuff: %.2f', item.puffFactor)
    debugText = debugText .. string.format('\nWalking: %.2f', item.walkingFactor)
    debugText = debugText .. string.format('\nRunning: %.2f', item.runningFactor)
    debugText = debugText .. string.format('\nSprinting: %.2f', item.sprintingFactor)

    debugText = debugText .. string.format('\n\n[Conditions:]')
    for condition, allowed in pairs(item.conditions) do
        debugText = debugText .. string.format('\n%s: %s', condition, allowed and 'Yes' or 'No')
    end

    if item.smokeLit and item.smokeLength > 0 and item.burnRate > 0 then
        local timeToFinish = item.smokeLength / item.burnRate
        local minutes = math.floor(timeToFinish / 60)
        local seconds = math.floor(timeToFinish % 60)
        debugText = debugText .. string.format('\n\n[Time Estimates]')
        debugText = debugText .. string.format('\nEstimated time left: ~%dm %ds', minutes, seconds)

        local gameMinutes = timeToFinish / (60 * getGameTime():getMinutesPerDay() * getGameSpeed())
        if gameMinutes > 0 then
            debugText = debugText .. string.format('\nReal time: ~%.1f minutes', gameMinutes)
        end
    end

    debugText = debugText .. string.format('\n\n[Item Info]')
    debugText = debugText .. string.format('\nItem Type: %s', item.fullType or 'Unknown')
    debugText = debugText .. string.format('\nOnEat Method: %s', item.onEat)
    debugText = debugText .. string.format('\nReplaceOnUse: %s', tostring(item.replaceOnUse))

    return debugText
end

function TrueSmoking.updateNicotineMoodle(player)
    if not player or not player:getModData().nicotineSystem then return end

    local playerNum = player:getPlayerNum()
    local data = player:getModData().nicotineSystem
    local moodle = MF.getMoodle('TS_Nicotine', playerNum)
    if not moodle then return end

    local shouldShow = TrueSmoking.Config.DebugMoodles or (data.withdrawalLevel > 15 and data.nicotineLevel < 8)
    local hideMoodles = TrueSmoking.Config.HideMoodles or TrueSmoking.Config.HideAddictionMoodle

    local moodleValue = 0.5 -- default = hidden/neutral

    if shouldShow and not hideMoodles then
        local withdrawalNorm = math.min(data.withdrawalLevel / 100.0, 1.0)
        moodleValue = 1.0 - withdrawalNorm -- 1.0 = no withdrawal (green), 0.0 = max (red)
    end

    moodle:setThresholds(0.10, 0.20, 0.35, 0.4999, 0.5001, 0.65, 0.85, 0.90)
    moodle:setValue(moodleValue)

    if shouldShow and not hideMoodles then
        local addiction = data.addictionLevel
        local titleText = ''

        if addiction >= 87.5 then
            titleText = getText('Moodles_nicotine_Bad_lvl4')  -- Extremely
        elseif addiction >= 75 then
            titleText = getText('Moodles_nicotine_Bad_lvl3')  -- Severely
        elseif addiction >= 62.5 then
            titleText = getText('Moodles_nicotine_Bad_lvl2')  -- Heavily
        elseif addiction >= 50 then
            titleText = getText('Moodles_nicotine_Bad_lvl1')  -- Strongly
        elseif addiction >= 37.5 then
            titleText = getText('Moodles_nicotine_Good_lvl1') -- Moderately
        elseif addiction >= 25 then
            titleText = getText('Moodles_nicotine_Good_lvl2') -- Mild
        elseif addiction >= 12.5 then
            titleText = getText('Moodles_nicotine_Good_lvl3') -- Slightly
        else
            titleText = getText('Moodles_nicotine_Good_lvl4') -- No Addiction
        end

        local level = moodle:getLevel()
        local gbn = moodle:getGoodBadNeutral()
        if level > 0 and gbn ~= 0 then
            moodle:setTitle(gbn, level, titleText)
        end

        local descText = ''
        if data.withdrawalLevel >= 80 then
            descText = getText('Moodles_nicotine_withdrawal_4')
        elseif data.withdrawalLevel >= 60 then
            descText = getText('Moodles_nicotine_withdrawal_3')
        elseif data.withdrawalLevel >= 40 then
            descText = getText('Moodles_nicotine_withdrawal_2')
        elseif data.withdrawalLevel >= 20 then
            descText = getText('Moodles_nicotine_withdrawal_1')
        else
            descText = getText('Moodles_nicotine_withdrawal_0')
        end

        local debugInfo = ''
        if TrueSmoking.Config.DebugMoodles then
            debugInfo = TrueSmoking.nicotineDebugInfo(data)
        end

        moodle:setDescription(gbn, level, descText .. debugInfo)
    end
end

function TrueSmoking.nicotineDebugInfo(data)
    local debugText = '\n\n[DEBUG INFO]'

    debugText = debugText .. '\n[Nicotine]'
    debugText = debugText .. string.format('\nLevel: %.2f%%', data.nicotineLevel)
    debugText = debugText .. string.format('\nNicotine Time: %.1f hours', data.nicotineTime)
    debugText = debugText .. string.format('\nNicotine Overflow: %.2f%%', data.nicotineOverflow)
    debugText = debugText .. '\n\n[Addiction]'
    debugText = debugText .. string.format('\nLevel: %.3f', data.addictionLevel)
    debugText = debugText .. string.format('\nAddiction Time: %.1f days', data.AddictionTime)

    debugText = debugText .. '\n\n[Withdrawal]'
    debugText = debugText .. string.format('\nWithdrawal Level: %.1f%%', data.withdrawalLevel)

    debugText = debugText .. '\n\n[Stats]'
    debugText = debugText .. string.format('\nUnhappiness Cap: %.2f', data.unhappinessCap)
    debugText = debugText .. string.format('\nBoredom Cap: %.2f', data.boredomCap)

    return debugText
end

Events.OnPlayerUpdate.Add(function(player)
    TrueSmoking.updateSmokingMoodle(player)
    TrueSmoking.updateNicotineMoodle(player)
end)
