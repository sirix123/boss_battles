if EndGameScreenManager == nil then
    EndGameScreenManager = class({})
end

function EndGameScreenManager:OpenPostGameScreen( )
    print("sent message from server to open post gmae screne")
	CustomGameEventManager:Send_ServerToAllClients( "game_complete", nil )
end