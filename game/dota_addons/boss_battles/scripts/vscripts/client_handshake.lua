if client_handshake == nil then
    client_handshake = class({})
end

function client_handshake:Init()

    print("client_handshake:Init()") 
    -- start listening for clients
    CustomGameEventManager:RegisterListener('client_handshake', function(event )
        print("got event from the client event ",event)

        PLAYERS_HANDSHAKE_READY = PLAYERS_HANDSHAKE_READY + 1

    end)
end
--------------------------------------------------------------------------------------------------
