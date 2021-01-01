if player_frame_manager == nil then
    player_frame_manager = class({})
end

function player_frame_manager:RegisterPlayer( hero )
    local playerID = hero:GetPlayerOwnerID()

    if playerID == -1 then
        --print("[game_setup] Error invalid player id")
        return
    else

        --Player UI Frames:
        Timers:CreateTimer(function()
            local heroes = HERO_LIST--HeroList:GetAllHeroes()
            local playerData = {}
            local i = 1
            for _, hero in pairs(heroes) do
                playerData[i] = {}
                playerData[i].entityIndex = hero:GetEntityIndex()
                playerData[i].playerName = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID())
                playerData[i].className = hero:GetUnitName() --GetClassName(hero:GetUnitName())
                playerData[i].hp = hero:GetHealth()
                playerData[i].maxHp = hero:GetMaxHealth()
                playerData[i].hpPercent = hero:GetHealthPercent()
                playerData[i].mp = hero:GetMana()
                playerData[i].maxMp = hero:GetMaxMana()
                playerData[i].mpPercent = hero:GetManaPercent()
                playerData[i].lives = hero.playerLives
                i = i +1
            end

            --Make some fake data for testing, keep this code to test playerFrame while solo.
            -- playerData[2] = {}
            -- playerData[2].entityIndex = hero:GetEntityIndex()
            -- playerData[2].playerName = "fake player2"
            -- playerData[2].className = GetClassName(hero:GetUnitName())
            -- playerData[2].hp = hero:GetHealth()
            -- playerData[2].maxHp = hero:GetMaxHealth()
            -- playerData[2].hpPercent = hero:GetHealthPercent()
            -- playerData[2].mp = hero:GetMana()
            -- playerData[2].maxMp = hero:GetMaxMana()
            -- playerData[2].mpPercent = hero:GetManaPercent()
            -- playerData[2].lives = hero.playerLives

            -- playerData[3] = {}
            -- playerData[3].entityIndex = hero:GetEntityIndex()
            -- playerData[3].playerName = "fake player3"
            -- playerData[3].className = GetClassName(hero:GetUnitName())
            -- playerData[3].hp = hero:GetHealth()
            -- playerData[3].maxHp = hero:GetMaxHealth()
            -- playerData[3].hpPercent = hero:GetHealthPercent()
            -- playerData[3].mp = hero:GetMana()
            -- playerData[3].maxMp = hero:GetMaxMana()
            -- playerData[3].mpPercent = hero:GetManaPercent()
            -- playerData[3].lives = hero.playerLives

            -- playerData[4] = {}
            -- playerData[4].entityIndex = hero:GetEntityIndex()
            -- playerData[4].playerName = "fake player4"
            -- playerData[4].className = GetClassName(hero:GetUnitName())
            -- playerData[4].hp = hero:GetHealth()
            -- playerData[4].maxHp = hero:GetMaxHealth()
            -- playerData[4].hpPercent = hero:GetHealthPercent()
            -- playerData[4].mp = hero:GetMana()
            -- playerData[4].maxMp = hero:GetMaxMana()
            -- playerData[4].mpPercent = hero:GetManaPercent()
            -- playerData[4].lives = hero.playerLives

            CustomNetTables:SetTableValue("player_frame", "key", playerData)
            return 0.2
        end)
        

    end
end
--------------------------------------------------------------------------------------------------