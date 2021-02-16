if player_frame_manager == nil then
    player_frame_manager = class({})
end

function player_frame_manager:CreatePlayerFrame( hero )

    --print("player in player manager ", player)

    CustomGameEventManager:Send_ServerToAllClients( "create_player_frame", { PlayerID = hero.playerId , HeroName = hero } )
end


function player_frame_manager:UpdatePlayer()
    --Player UI Frames:
    Timers:CreateTimer(function()
        if #HERO_LIST == 4 or IsInToolsMode() then

            local playerFrameData = {}

            local heroes = HERO_LIST
            for _, hero in pairs(heroes) do
                local player = {}

                player["playerId"] = hero.playerId
                player["hp"] = hero.hp
                player["maxHp"] = hero.maxHp
                player["hpPercent"] = hero:GetHealthPercentCustom()
                player["mp"] = hero.mana
                player["maxMp"] = hero.maxMp
                player["mpPercent"] = hero:GetManaPercentCustom()
                player["lives"] = hero.playerLives

                table.insert(playerFrameData,player)

            end

            CustomGameEventManager:Send_ServerToAllClients( "update_player_frame", { playerFrameData } )

        end
        return 2--0.2
    end)
end
--------------------------------------------------------------------------------------------------