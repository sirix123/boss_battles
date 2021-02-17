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
    --print("userID = ", userID)
    local commandChar = "!"
    local firstChar = string.sub(text,1,1)

    if not keys.userid then return end

    --Parse Player Chat only if it's an command, only if the text starts with commandChar:
    if commandChar == firstChar then
        local hPlayer = PlayerInstanceFromIndex( keys.userid )
        if not hPlayer then return end
        --local hHero = hPlayer:GetAssignedHero()

        if NORMAL_MODE ~= true  then --or IsInToolsMode()

            if string.find(text, "reset damage") then
                _G.DamageTable = {}
            end

            if string.find(text, "dps meter") then
                --send event to hPlayer to show dps meter
                CustomGameEventManager:Send_ServerToPlayer( hPlayer, "showDpsMeterUIEvent", {} )
            end

            if string.find(text, "admin-panel") then
                print("TODO: call function to show admin-panel")
            end

            if string.find(text, "start boss") then
                print("found start boss command")
                local parts = mysplit(text)
                local bossName = parts[3]
                if bossName == "beastmaster" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 2
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(2)
                end
                if bossName == "timber" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 3
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(3)
                end
                if bossName == "techies" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 4
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(4)
                end
                if bossName == "clock" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 5
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(5)
                end
                if bossName == "gyro" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 6
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(6)
                end
                if bossName == "tinker" then
                    print("TODO: start boss ", bossName)
                    BOSS_BATTLES_ENCOUNTER_COUNTER = 7
                    --GameSetup:ReadyupCheck()
                    --self:StartBoss(7)
                end
            end

        else
            GameRules:SendCustomMessage("You're in Normal mode you cannot use this command.", 0, 0)
        end

        --quick start gyro, control which AI function is used. 
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
        end

    end --end if, commandChar == firstChar
end
-----------------------------------------------------------------------------------------------------


