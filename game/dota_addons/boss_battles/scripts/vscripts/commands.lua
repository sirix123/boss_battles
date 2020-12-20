if Commands == nil then
    Commands = class({})
end

function Commands:Init()

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

function Commands:StartBoss( a )
        print("set_trigger_boss ", RAID_TABLES[a].spawnLocation)
        print("set_trigger_boss ", RAID_TABLES[a].arena)
        print("set_trigger_boss ", RAID_TABLES[a].boss)

        local heroes = HERO_LIST--HeroList:GetAllHeroes()

        self.boss_arena_name     = RAID_TABLES[a].spawnLocation
        self.player_arena_name   = RAID_TABLES[a].arena

        self.boss_spawn = Entities:FindByName(nil, self.boss_arena_name):GetAbsOrigin()
        self.player_spawn = Entities:FindByName(nil, self.player_arena_name):GetAbsOrigin()

        for _,hero in pairs(heroes) do
            if hero:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then
                hero:SetMana(0)
            end
            FindClearSpaceForUnit(hero, self.player_spawn, true)
        end

        -- spawn boss
        boss = nil
        Timers:CreateTimer(1.0, function()
            -- look at raidtables and spawn the boss depending on the encounter counter
            boss = CreateUnitByName(RAID_TABLES[a].boss, self.boss_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
        end)

    --Update the bosses hp and mp UI every tick
    Timers:CreateTimer(function()
        if boss ~= nil then
            if boss:GetHealthPercent() == 0 then
                CustomNetTables:SetTableValue("boss_frame", "hide", {})
                return false
            end
            local hp = boss:GetHealth()
            local maxHp = boss:GetMaxHealth()
            local hpPercent = boss:GetHealthPercent()
            local mpPercent = boss:GetManaPercent()

            local bossFrameData = {}
            bossFrameData.hp = boss:GetHealth()
            bossFrameData.maxHp = boss:GetMaxHealth()
            bossFrameData.hpPercent = boss:GetHealthPercent()

            bossFrameData.mp = boss:GetMana()
            bossFrameData.maxMp = boss:GetMaxMana()
            bossFrameData.mpPercent = boss:GetManaPercent()

            CustomNetTables:SetTableValue("boss_frame", "key", bossFrameData)
        else
            CustomNetTables:SetTableValue("boss_frame", "hide", {})
            --wait for the boss to spawn...
        end
        return 1;
    end)
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
                GameSetup:ReadyupCheck()
                --self:StartBoss(2)
            end
            if bossName == "timber" then
                print("TODO: start boss ", bossName)
                BOSS_BATTLES_ENCOUNTER_COUNTER = 3
                GameSetup:ReadyupCheck()
                --self:StartBoss(3)
            end
            if bossName == "techies" then
                print("TODO: start boss ", bossName)
                BOSS_BATTLES_ENCOUNTER_COUNTER = 4
                GameSetup:ReadyupCheck()
                --self:StartBoss(4)
            end
            if bossName == "clock" then
                print("TODO: start boss ", bossName)
                BOSS_BATTLES_ENCOUNTER_COUNTER = 5
                GameSetup:ReadyupCheck()
                --self:StartBoss(5)
            end
            if bossName == "gyro" then
                print("TODO: start boss ", bossName)
                BOSS_BATTLES_ENCOUNTER_COUNTER = 6
                GameSetup:ReadyupCheck()
                --self:StartBoss(6)
            end
            if bossName == "tinker" then
                print("TODO: start boss ", bossName)
                BOSS_BATTLES_ENCOUNTER_COUNTER = 7
                GameSetup:ReadyupCheck()
                --self:StartBoss(7)
            end
        end

    end --end if, commandChar == firstChar
end
-----------------------------------------------------------------------------------------------------
