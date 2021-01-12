if player_frame_manager == nil then
    player_frame_manager = class({})
end

function player_frame_manager:CreatePlayerFrame( player )

    CustomGameEventManager:Send_ServerToAllClients( "create_player_frame", { Player = player } )

end


function player_frame_manager:RegisterPlayer( hero )
    local playerID = hero:GetPlayerOwnerID()

    if playerID == -1 then
        --print("[game_setup] Error invalid player id")
        return
    else
        --Player UI Frames:
        Timers:CreateTimer(function()
            if #HERO_LIST == 1 then
                local heroes = HERO_LIST--HeroList:GetAllHeroes()
                for _, hero in pairs(heroes) do
                    CustomNetTables:SetTableValue("player_frame", "key", hero)
                end
            end
            return 0.2
        end)
    end
end
--------------------------------------------------------------------------------------------------