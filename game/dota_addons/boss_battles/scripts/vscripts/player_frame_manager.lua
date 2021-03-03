if player_frame_manager == nil then
    player_frame_manager = class({})
end

function player_frame_manager:CreatePlayerFrame( hero )

    --print("player in player manager ", player)

    CustomGameEventManager:Send_ServerToAllClients( "create_player_frame", { PlayerID = hero.playerId , HeroData = hero } )
end


function player_frame_manager:UpdatePlayer()
    --Player UI Frames:
    Timers:CreateTimer(function()
        if #HERO_LIST == 4 or IsInToolsMode() then
            local heroes = HERO_LIST
            for _, hero in pairs(heroes) do
                CustomGameEventManager:Send_ServerToAllClients( "update_player_frame", { PlayerID = hero.playerId , HeroData = hero } )
            end
        end
        return 2--0.2
    end)
end
--------------------------------------------------------------------------------------------------