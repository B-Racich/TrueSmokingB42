--[[
    Too add your own support for modded items create an OnCreatePlayer event like below
    and call the TrueSmoking functions to set the tables
]]

Events.OnCreatePlayer.Add(function()
    local TRUE_SMOKING_DEFAULT_SMOKE_LENGTHS = {
        ['Base.CigaretteSingle'] = TrueSmoking.Options.CigaretteLength,
        ['Base.CigaretteRolled'] = TrueSmoking.Options.CigaretteLength,
        ['Base.Cigarillo'] = TrueSmoking.Options.CigarilloLength,
        ['Base.Cigar'] = TrueSmoking.Options.CigarLength,
        ['Base.SmokingPipe_Tobacco'] = TrueSmoking.Options.PipeLength,
        ['Base.CanPipe_Tobacco'] = TrueSmoking.Options.CanLength,

        --Hemp&Tobacco
        ['Base.HempCigarette'] = TrueSmoking.Options.CigaretteLength,
        ['Base.HempCigar'] = TrueSmoking.Options.CigarLength,
        ['Base.HempCigarillo'] = TrueSmoking.Options.CigarilloLength,
        ['Base.SmokingPipe_Hemp'] = TrueSmoking.Options.PipeLength,
        ['Base.CanPipe_Hemp'] = TrueSmoking.Options.CanLength,
        ['Base.GlassSmokingPipe_Hemp'] = TrueSmoking.Options.PipeLength,
        ['Base.GlassSmokingPipe_Tobacco'] = TrueSmoking.Options.PipeLength,

        --ReeferMadness
        ['ReeferMadness.SmokingPipe_marijuana'] = TrueSmoking.Options.PipeLength,
        ['ReeferMadness.CanPipe_marijuana'] = TrueSmoking.Options.CanLength,
        ['ReeferMadness.WeedCigarette'] = TrueSmoking.Options.CigaretteLength,
        ['ReeferMadness.Joint'] = TrueSmoking.Options.CigaretteLength,
        ['ReeferMadness.blunt'] = TrueSmoking.Options.CigarilloLength,
        ['ReeferMadness.WeedCigarette2'] = TrueSmoking.Options.CigaretteLength,
        ['ReeferMadness.SmokingPipe_hash'] = TrueSmoking.Options.PipeLength,
        ['ReeferMadness.CanPipe_hash'] = TrueSmoking.Options.CanLength,
        ['ReeferMadness.WeedCigarette2Kief'] = TrueSmoking.Options.CigaretteLength,
        ['ReeferMadness.bluntKief'] = TrueSmoking.Options.CigarilloLength,
        ['ReeferMadness.jointKief'] = TrueSmoking.Options.CigaretteLength,
        ['ReeferMadness.SmokingPipe_marijuanaKief'] = TrueSmoking.Options.PipeLength,
        ['ReeferMadness.CanPipe_marijuanaKief'] = TrueSmoking.Options.CanLength,
        ['ReeferMadness.WeedCigaretteKief'] = TrueSmoking.Options.CigaretteLength,
        --N&C
        ['Nnc.BluntAK'] = TrueSmoking.Options.CigarilloLength,
        ['Nnc.JointAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1GreenAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1PurpleAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1RedAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2PinkAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RainbowAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RedAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.BongPokeAK'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Pipe1GreenAK'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1OrangeAK'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1YellowAK'] = TrueSmoking.Options.PipeLength,
        ['Nnc.CanPipeAK'] = TrueSmoking.Options.CanLength,
        ['Nnc.SmokingPipeAK'] = TrueSmoking.Options.PipeLength,

        ['Nnc.BluntNorthernLights'] = TrueSmoking.Options.CigarilloLength,
        ['Nnc.JointNorthernLights'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1GreenNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1PurpleNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1RedNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2PinkNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RainbowNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RedNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.BongPokeNL'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Pipe1GreenNL'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1OrangeNL'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1YellowNL'] = TrueSmoking.Options.PipeLength,
        ['Nnc.CanPipeNorthernLights'] = TrueSmoking.Options.CanLength,
        ['Nnc.SmokingPipeNorthernLights'] = TrueSmoking.Options.PipeLength,

        ['Nnc.BluntSourDiesel'] = TrueSmoking.Options.CigarilloLength,
        ['Nnc.JointSourDiesel'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1GreenSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1PurpleSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1RedSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2PinkSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RainbowSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RedSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.BongPokeSD'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Pipe1GreenSD'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1OrangeSD'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1YellowSD'] = TrueSmoking.Options.PipeLength,
        ['Nnc.CanPipeSourDiesel'] = TrueSmoking.Options.CanLength,
        ['Nnc.SmokingPipeSourDiesel'] = TrueSmoking.Options.PipeLength,

        ['Nnc.BluntKief'] = TrueSmoking.Options.CigarilloLength,
        ['Nnc.JointKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1GreenKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1PurpleKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong1RedKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2PinkKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RainbowKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Bong2RedKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.BongPokeKief'] = TrueSmoking.Options.CigaretteLength,
        ['Nnc.Pipe1GreenKief'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1OrangeKief'] = TrueSmoking.Options.PipeLength,
        ['Nnc.Pipe1YellowKief'] = TrueSmoking.Options.PipeLength,
        ['Nnc.CanPipeKief'] = TrueSmoking.Options.CanLength,
        ['Nnc.SmokingPipeKief'] = TrueSmoking.Options.PipeLength,
    }

    local TRUE_SMOKING_DEFAULT_VISUAL_ITEMS = {
        ['Base.CigaretteSingle'] = 'Mask_Cigarette',
        ['Base.Cigarillo'] = 'Mask_Cigarillo',
        ['Base.Cigar'] = 'Mask_Cigar',
        ['Base.SmokingPipe_Tobacco'] = 'Mask_Pipe',
    }

    local TRUE_SMOKING_DEFAULT_HOTKEY_SMOKES = {
        'Base.CigaretteSingle',
    }

    local TRUE_SMOKING_DEFAULT_HOTKEY_PACKS = {
        ['Base.CigarettePack'] = 'TakeACigarette',
    }

    TrueSmoking:setSmokeLengths(TRUE_SMOKING_DEFAULT_SMOKE_LENGTHS)
    TrueSmoking:setVisualItems(TRUE_SMOKING_DEFAULT_VISUAL_ITEMS)
    TrueSmoking:setHotkeySmokes(TRUE_SMOKING_DEFAULT_HOTKEY_SMOKES)
    TrueSmoking:setHotkeyPacks(TRUE_SMOKING_DEFAULT_HOTKEY_PACKS)

    -- TrueSmoking:setCallback(
    --     function()
    --         print('Callback inside smokable update')
    --     end
    -- )
end)


--Kalilynx
local function appendSample()
    if not ScriptManager.instance then return end  -- Ensure ScriptManager exists  

    local item = ScriptManager.instance:getItem("Base.Item")
    if not item then return end  

    local currentTags = item:getTags()
    local newTagsList = {"Tag1", "Tag2"}
    local tagsSet = {}  -- use  set to avoid dup tags  

    -- here we add existing tags to the set  
    if currentTags and not currentTags:isEmpty() then
        for i = 0, currentTags:size() - 1 do
            tagsSet[currentTags:get(i)] = true
        end
    end
    -- add new tags  
    for _, tag in ipairs(newTagsList) do
        tagsSet[tag] = true
    end
    -- convert the set back to a list and update it
    local mergedTags = {}
    for tag in pairs(tagsSet) do
        table.insert(mergedTags, tag)
    end
    item:DoParam("Tags = " .. table.concat(mergedTags, ";"))
end

-- Events.OnGameBoot.Add(appendSample)