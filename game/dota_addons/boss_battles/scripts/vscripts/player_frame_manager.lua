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
        if #HERO_LIST == 1 then
            local heroes = HERO_LIST
            for _, hero in pairs(heroes) do
                local playerFrameData = {}
                playerFrameData.id = hero.playerId
                playerFrameData.hp = hero.hp
                playerFrameData.maxHp = hero.maxHp
                playerFrameData.hpPercent = hero:GetHealthPercentCustom()
                playerFrameData.mp = hero.mana
                playerFrameData.maxMp = hero.maxMp
                playerFrameData.mpPercent = hero:GetManaPercentCustom()
                playerFrameData.lives = hero.playerLives

                --CustomNetTables:SetTableValue("player_frame", "key", playerFrameData )
                CustomGameEventManager:Send_ServerToAllClients( "update_player_frame", { playerFrameData} )
            end
        end
        return 0.2
    end)
end
--------------------------------------------------------------------------------------------------