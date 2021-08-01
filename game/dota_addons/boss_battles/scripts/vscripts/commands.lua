if Commands == nil then
    Commands = class({})
end

function Commands:Init()
    print("Commands:Init()")

    ListenToGameEvent('player_chat', Dynamic_Wrap(self, 'OnPlayerChat'), self)

    -- reg console commands
    self:InitCommands()

end
-----------------------------------------------------------------------------------------------------

function Commands:InitCommands()

    Convars:RegisterCommand("set_trigger_boss", function(a, boss_index)
        a = tonumber(boss_index)

        BOSS_BATTLES_ENCOUNTER_COUNTER = a

        print("set_trigger_boss ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].spawnLocation)
        print("set_trigger_boss ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena)
        print("set_trigger_boss ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss)

        GameSetup:ReadyupCheck()

    end, "  ", FCVAR_CHEAT)

end

-----------------------------------------------------------------------------------------------------
function Commands:OnPlayerChat(keys)
    local userID = keys.userid
    local text = keys.text
    local playerID = keys.playerid
    --print("userID = ", userID)
    local commandChar = "!"
    local firstChar = string.sub(text,1,1)
    --PrintTable(keys)

    if not keys.userid then return end

    --Parse Player Chat only if it's an command, only if the text starts with commandChar:
    if commandChar == firstChar then
        local hPlayer = PlayerResource:GetPlayer(keys.playerid)

        if not hPlayer then return end

        if string.find(text, "cheekybeeky") then
            if tostring(PlayerResource:GetSteamID(keys.playerid)) == "76561197972850274" then
                local key = GetDedicatedServerKeyV2("123")
                GameRules:SendCustomMessage("GetDedicatedServerKeyV2:" .. key, 0, 0)

                for _, hero in pairs(HERO_LIST) do
                    hero.playerLives = BOSS_BATTLES_PLAYER_LIVES
                end

                return
            end
        end

        if PLAYERS_FIGHTING_BOSS == true then
            GameRules:SendCustomMessage("Commands cannot be used if you're in a boss fight.", 0, 0)
            return
        end

        local hHero = hPlayer:GetAssignedHero()

            if string.find(text, "intermission") then
                FindClearSpaceForUnit(hHero, BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION, true)
                return
            end

            if string.find(text, "reset damage") then
                _G.DamageTable = {}
                return
            end

            if string.find(text, "gameid") then
                local gameid = SessionManager:GetGameID()
                CustomGameEventManager:Send_ServerToPlayer( hPlayer, "send_game_id", { gameid } )
                return
            end

            if string.find(text, "stop track data") then
                TRACK_DATA = false
                for _,hero in pairs(HERO_LIST) do
                    hero.dmgDoneAttempt = 0  -- reset damage done
                    hero.dmgTakenAttempt = 0  -- reset dmg taken
                    hero.dmgDetails = {}
                    hero.dmgTakenDetails = {}
                    hero.deathsDetails = {}
                end

                GameRules:SendCustomMessage("Stopping data track.", 0, 0)
                --print("stopping data track")
                return
            end

            if string.find(text, "start track data") then
                TRACK_DATA = true
                for _,hero in pairs(HERO_LIST) do
                    hero.dmgDoneAttempt = 0  -- reset damage done
                    hero.dmgTakenAttempt = 0  -- reset dmg taken
                    hero.dmgDetails = {}
                    hero.dmgTakenDetails = {}
                    hero.deathsDetails = {}
                end

                GameRules:SendCustomMessage("Starting data track.", 0, 0)
                --print("starting data track")
                return
            end

            if string.find(text, "dps meter") then
                --send event to hPlayer to show dps meter
                CustomGameEventManager:Send_ServerToPlayer( hPlayer, "showDpsMeterUIEvent", {} )
                return
            end

            if string.find(text, "reset") then
                print("playerID = ", playerID)
                if playerID then
                    local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
                    print("hero ",hero:GetUnitName() )
                    if hero then
                        hero.direction.x = 0
                        hero.direction.y = 0
                        hero.direction.z = 0
                    end
                end
                return
            end

            if string.find(text, "admin-panel") then
                print("TODO: call function to show admin-panel")
                return
            end

        if bGAME_COMPLETE == false then --or IsInToolsMode()

            if NORMAL_MODE == true then
                GameRules:SendCustomMessage("Start boss command cannot be used if you're in Hardmode", 0, 0)
                return
            end

            if string.find(text, "start boss") then
                print("found start boss command")
                local parts = mysplit(text)
                local bossName = parts[3]

                -- reset the attempt tracker
                nATTEMPT_TRACKER = 0

                if bossName == "Beastmaster" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 4
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(2)
                    GameRules:SendCustomMessage("Boss set to: " .. bossName, 0, 0)
                end
                if bossName == "Timbersaw" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 3
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(3)
                    GameRules:SendCustomMessage("Boss set to: " .. bossName, 0, 0)
                end
                if bossName == "Techies" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 5
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(4)
                    GameRules:SendCustomMessage("Boss set to: " .. bossName, 0, 0)
                end
                if bossName == "Clockwerk" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 6
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(5)
                    GameRules:SendCustomMessage("Boss set to: " .. bossName, 0, 0)
                end
                if bossName == "Gyrocopter" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 2
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(6)
                    GameRules:SendCustomMessage("Boss set to: " .. bossName, 0, 0)
                end
                if bossName == "Tinker" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 7
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(7)
                    GameRules:SendCustomMessage("Boss set to: " .. bossName, 0, 0)
                end

            end

        elseif bGAME_COMPLETE == true then
            GameRules:SendCustomMessage("Commands cannot be used if you've killed the last boss.", 0, 0)
        end

        --[[quick start gyro, control which AI function is used.
        if string.find(text, "sbg") then
            BOSS_BATTLES_ENCOUNTER_COUNTER = 6
            _G.GyroAI = "Main"
            if string.find(text, "sbg%-swoop") then -- %- will escape the hyphen key. command is sbg-test
                _G.GyroAI = "Swoop"
            end
            if string.find(text, "sbg%-test") then -- %- will escape the hyphen key. command is sbg-test
                _G.GyroAI = "Test"
            end
            GameSetup:ReadyupCheck()
        end]]

    end --end if, commandChar == firstChar
end
-----------------------------------------------------------------------------------------------------


