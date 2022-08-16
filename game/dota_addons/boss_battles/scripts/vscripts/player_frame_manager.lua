if player_frame_manager == nil then
    player_frame_manager = class({})
end

function player_frame_manager:CreatePlayerFrame( hero, player )
    CustomGameEventManager:Send_ServerToAllClients( "create_player_frame", { PlayerID = hero.playerId , HeroData = hero } )
end

function player_frame_manager:CreatePlayerFrameReconnect( hero, player )
    CustomGameEventManager:Send_ServerToPlayer( player, "create_player_frame", { PlayerID = hero.playerId , HeroData = hero } )
end


function player_frame_manager:UpdatePlayer()
    --Player UI Frames:
    Timers:CreateTimer(function()
        local heroes = HERO_LIST
        for _, hero in pairs(heroes) do
            CustomGameEventManager:Send_ServerToAllClients( "update_player_frame", { PlayerID = hero.playerId , HeroData = hero } )
        end
        return 0.2
    end)
end
--------------------------------------------------------------------------------------------------
