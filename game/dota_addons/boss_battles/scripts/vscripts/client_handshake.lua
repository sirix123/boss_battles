if client_handshake == nil then
    client_handshake = class({})
end

function client_handshake:Init()

    print("client_handshake:Init()")

    -- start listening for clients
    CustomGameEventManager:RegisterListener('client_handshake', function(event )
        print("got event from the client event ",event)

        PLAYERS_HANDSHAKE_READY = PLAYERS_HANDSHAKE_READY + 1

    end) -- end of MoveUnit listener

    -- start listening for clients (reconnect)
    CustomGameEventManager:RegisterListener('client_handshake_reconnect', function(event )
        print("got event from the client event (reconnect)",event)

        -- what player is sending the reconnect handshake
        RECONNECTING_PLAYER_ID = event

    end) -- end of MoveUnit listener

end
--------------------------------------------------------------------------------------------------
