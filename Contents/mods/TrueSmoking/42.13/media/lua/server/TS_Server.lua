function TrueSmoking.onClientCommand(module, command, player, args)
    if module ~= 'TrueSmoking' then return end

    if command == '' then
        -- do something
    end
end

Events.OnClientCommand.Add(TrueSmoking.onClientCommand)