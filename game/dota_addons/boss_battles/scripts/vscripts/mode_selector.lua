if ModeSelector == nil then
    ModeSelector = class({})
end

function ModeSelector:Start()
	--Listen for mode selected event
	ModeSelector.listener = CustomGameEventManager:RegisterListener( "mode_selected", ModeSelector.ModeSelected )
    
end

function ModeSelector:ModeSelected( event )

    -- print("mode selected ",event.mode)

    -- soloMode
    -- normalMode
    -- hardMode

    if event.mode == "soloMode" then
        SOLO_MODE = true
        NORMAL_MODE = false
        HARD_MODE = false
    elseif event.mode == "normalMode" then 
        SOLO_MODE = false
        NORMAL_MODE = true
        HARD_MODE = false
    elseif event.mode == "hardMode" then
        SOLO_MODE = false
        NORMAL_MODE = false
        HARD_MODE = true
    end

    ModeSelector:SendModeToClient( event.mode )

    GameSetup:FinishModeSelection()

end

function ModeSelector:SendModeToClient( event )
	CustomGameEventManager:Send_ServerToAllClients( "mode_chosen",
		{ mode = event } )
end