if GameSetup == nil then
    GameSetup = class({})
end

RAID_TABLES = require('managers/raid_init_tables')

LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_grace_period", "player/generic/modifier_grace_period", LUA_MODIFIER_MOTION_NONE )

function GameSetup:init()

    self.player_deaths = {}

    -- doesn't work :(
    -- spectator teamID
    --DOTA_TEAM_SPECTATORS = 1
    --DOTA_MAX_SPECTATOR_TEAM_SIZE = 2
    --GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_SPECTATORS, 2)

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 0)

    GameRules:EnableCustomGameSetupAutoLaunch(false)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetHeroSelectionTime(30)
    GameRules:SetStrategyTime(0)
    GameRules:SetPreGameTime(1)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPostGameTime(5)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetHeroRespawnEnabled(true)
    GameRules:SetStartingGold( 0 )
	GameRules:SetGoldTickTime( 999999.0 )
    GameRules:SetGoldPerTick( 0 )

    GameRules:GetGameModeEntity():SetFixedRespawnTime( 3 )
    GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1800 )
    GameRules:GetGameModeEntity():SetBuybackEnabled( false )
    --GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride( "" )

    -- reg console commands
    self:InitCommands()

    -- setup listeners, these also store critical player information in core_functions override for base_npc
    PlayerManager:SetUpMouseUpdater()
    PlayerManager:SetUpMovement()

    --listen to game state event
    -- events here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self) -- valve engine event
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self) -- npc_spawned is a valve engine event
    --ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'PlayerPickHero'), self) -- dota_player_pick_hero is a valve engine event
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self) --
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'OnEntityHurt'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(self, 'OnPlayerChat'), self)

end






--------------------------------------------------------------------------------------------------

function GameSetup:OnStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then

        Filters:Activate(GameSetup, self)

        local mode = GameRules:GetGameModeEntity()
        mode:SetExecuteOrderFilter(Dynamic_Wrap(GameSetup, "ExecuteOrderFilter" ), GameSetup)

    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        -- spawn testing stuff
        self:SpawnTestingStuff()

    end

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)

    if npc:IsRealHero() == true then
        -- add grace period when respawning..
        npc:AddNewModifier( npc, nil, "modifier_grace_period", { duration = 3 } )
    end

    if npc:IsRealHero() and npc.bFirstSpawned == nil then
        npc.bFirstSpawned = true

        npc:AddNewModifier( npc,  nil, "movement_modifier_thinker", { } )
        npc:AddNewModifier( npc,  nil, "remove_attack_modifier", { } )

        npc:Initialize(keys)
        self:RegisterPlayer(npc)
        self:RegisterRaidWipe()

        -- if warlord give the stance modifier
        if npc:GetUnitName() == "npc_dota_hero_juggernaut" then
            npc:AddNewModifier(
                npc, -- player source
                nil, -- ability source
                "q_warlord_dps_stance_modifier", -- modifier name
                {} -- kv
            )
        end

        -- level up abilities for all heroes to level 1
        if npc:GetUnitName() == "npc_dota_hero_crystal_maiden"
        or npc:GetUnitName() == "npc_dota_hero_medusa"
        or npc:GetUnitName() == "npc_dota_hero_juggernaut"
        or npc:GetUnitName() == "npc_dota_hero_phantom_assassin"
        or npc:GetUnitName() == "npc_dota_hero_templar_assassin"
        then

            local index = 0

            while (npc:GetAbilityByIndex(index) ~= nil) do
                npc:GetAbilityByIndex(index):SetLevel(1)
                index = index +1
            end
        end
    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:RegisterPlayer( hero )
    local playerID = hero:GetPlayerOwnerID()

    if playerID == -1 then
        --print("[game_setup] Error invalid player id")
        return
    else

        --Player UI Frames:
        Timers:CreateTimer(function()
            local heroes = HeroList:GetAllHeroes()
            local playerData = {}
            local i = 1
            for _, hero in pairs(heroes) do
                playerData[i] = {}
                playerData[i].entityIndex = hero:GetEntityIndex()
                playerData[i].hp = hero:GetHealth()
                playerData[i].maxHp = hero:GetMaxHealth()
                playerData[i].hpPercent = hero:GetHealthPercent()
                playerData[i].mp = hero:GetMana()
                playerData[i].maxMp = hero:GetMaxMana()
                playerData[i].mpPercent = hero:GetManaPercent()
                playerData[i].lives = hero.playerLives
                i = i +1
            end
            return 0.2
        end)
        CustomNetTables:SetTableValue("heroes", "key", playerData)

    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:RegisterRaidWipe( )

    Timers:CreateTimer(function()

        if #self.player_deaths == HeroList:GetHeroCount() then
            Timers:CreateTimer(5.0, function()

                -- revive and move dead heroes
                for _, killedHero in pairs(self.player_deaths) do
                    killedHero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
                    self.respawn_time = BOSS_BATTLES_RESPAWN_TIME
                    killedHero:SetTimeUntilRespawn(self.respawn_time)
                    killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES
                end

                --[[ edge case that a player is dead then boss dies
                local heroes = HeroList:GetAllHeroes()
                for _, hero in pairs(heroes) do
                    if hero:IsAlive() then
                        FindClearSpaceForUnit(hero, BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION, true)
                    end
                end]]

                -- call boss cleanup function
                self:EncounterCleanUp( self.boss_spawn )

                -- reset  death counter
                self.player_deaths = {}

                -- wipe flag / -- register a wipe for current boss
                --self.wipe_flag = true

            end)
        end

        return 0.5
    end)
end

--------------------------------------------------------------------------------------------------
function GameSetup:SpawnTestingStuff(keys)

    -- flame turrets for right side of the map, need to change facing vector
    local flame_turret_1 = CreateUnitByName("npc_flame_turret", Vector(-10154,-8652,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_1:SetForwardVector(Vector(0,-1, flame_turret_1.z ))

    local flame_turret_2 = CreateUnitByName("npc_flame_turret", Vector(-9511,-8652,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_2:SetForwardVector(Vector(0,-1, flame_turret_2.z ))

    local flame_turret_3 = CreateUnitByName("npc_flame_turret", Vector(-9744,-11704,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_3:SetForwardVector(Vector(0,1, flame_turret_3.z ))

    -- target dummy (1 by itself)(immortal)
    CreateUnitByName("npc_dota_creature_dummy_target_boss_immortal", Vector(-11571,-8864,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy (1 by itself)
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11744,-9369,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy (3)
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11757,-9989,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11757,-9989,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11757,-9989,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy (1 moving)
    CreateUnitByName("npc_dota_creature_gnoll_assassin_moving", Vector(-11077,-8747,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy friendly
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-12757,-9789,256), true, nil, nil, DOTA_TEAM_GOODGUYS)

    --test
    --PrintTable(RAID_TABLES, indent, done)

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnEntityKilled(keys)
    local npc = EntIndexToHScript(keys.entindex_killed)

    if npc:GetUnitName() == "npc_dota_creature_dummy_target_boss" then
        CreateUnitByName("npc_dota_creature_dummy_target_boss", npc:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    end

    if npc:GetUnitName() == "npc_dota_creature_gnoll_assassin_moving" then
        CreateUnitByName("npc_dota_creature_gnoll_assassin_moving", npc:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    end

    -- handles heroes dying
    if npc:IsRealHero() then
        self:HeroKilled( keys )
        return
    end

    -- handles encounter/boss dying
    if npc:GetUnitName() == RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss then
        -- increase encounter counter

        -- repsawn deadplayers and reset lifes
        local isHeroAlive = false
        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs(heroes) do
            hero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
            self.respawn_time = 1
            self.player_deaths = {}
            hero:SetTimeUntilRespawn(self.respawn_time)
            hero.playerLives = BOSS_BATTLES_PLAYER_LIVES

            if hero:IsAlive() == true then
                isHeroAlive = true
            end
        end

        if isHeroAlive == true then
            BOSS_BATTLES_ENCOUNTER_COUNTER = BOSS_BATTLES_ENCOUNTER_COUNTER + 1
        end

        -- move alive players to intermission area
        Timers:CreateTimer(1.0, function()
            local heroes = HeroList:GetAllHeroes()
            for _,hero in pairs(heroes) do
                FindClearSpaceForUnit(hero, BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION, true)
            end
        end)

        Timers:CreateTimer(2.0, function()
            -- clean up enounter
            self:EncounterCleanUp( self.beastmasterBossSpawn )
        end)

    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:OnEntityHurt(keys)
    -- print("GameSetup:OnEntityHurt(keys). Printing keys: ")
    -- PrintTable(keys, indent, done)

    -- Store the dmg done in a table to maintain history. 
    -- StoreDamageDone(keys)


    --DEBUG:    
    local inflictor = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor):GetName()
    if inflictor == nil then inflictor = "unknown_ability" end
    --print("" ..EntIndexToHScript(keys.entindex_attacker):GetUnitName().. " attacked " ..EntIndexToHScript(keys.entindex_killed):GetUnitName().. " with " ..inflictor.. " dealing " ..keys.damage)

    -- Only process dmg if from or too a player Hero.
    local heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        -- Store damage done or received to hero
        if (hero:GetEntityIndex() == keys.entindex_killed) or (hero:GetEntityIndex() == keys.entindex_attacker) then
            StoreDamageDone(keys)
            break
        end
    end

    --DPS METER:
    UpdateDamageMeter()

    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        local entVictim = EntIndexToHScript(keys.entindex_killed)
        local entAttacker = EntIndexToHScript(keys.entindex_attacker)

        -- The ability/item used to damage, or nil if not damaged by an item/ability
        local damagingAbility = nil

        if keys.entindex_inflictor ~= nil then
            damagingAbility = EntIndexToHScript(keys.entindex_inflictor)

        end

        local word_length = string.len(tostring(math.floor(keys.damage)))

        local color =  Vector(250, 70, 70)
        local effect_cast = ParticleManager:CreateParticle("particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) --particles/custom_msg_damage.vpcf particles/msg_fx/msg_damage.vpcf
        ParticleManager:SetParticleControl(effect_cast, 0, entVictim:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, keys.damage, 0))
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(0.5, word_length, 0)) --vector(math.max(1, keys.damage / 10), word_length, 0))
        ParticleManager:SetParticleControl(effect_cast, 3, color)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

end
--------------------------------------------------------------------------------------------------

-- handles tping players to the boss arena and spawning the boss
function GameSetup:ReadyupCheck() -- called from trigger lua file for activators (ready_up)
    local heroes = HeroList:GetAllHeroes()

    -- look at raid tables and move players to boss encounter based on counter
    print("game_setup: Start boss counter: ", BOSS_BATTLES_ENCOUNTER_COUNTER," ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss )

    -- reset damage done
    DamageTable = {}

    self.boss_arena_name     = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].spawnLocation
    self.player_arena_name   = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena

    --print("game_setup: boss_arena: ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].spawnLocation," player_arena:", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena )

    -- find enity using the above values from the table
    self.boss_spawn = Entities:FindByName(nil, self.boss_arena_name):GetAbsOrigin()
    self.player_spawn = Entities:FindByName(nil, self.player_arena_name):GetAbsOrigin()

    for _,hero in pairs(heroes) do
        if hero:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then
            hero:SetMana(0)
        end
        FindClearSpaceForUnit(hero, self.player_spawn, true)
    end

    -- count down message
    -- message duration = timer below in spawn boss

    -- spawn boss
    boss = nil
    Timers:CreateTimer(1.0, function()
        -- look at raidtables and spawn the boss depending on the encounter counter
        boss = CreateUnitByName(RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss, self.boss_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
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

    -- reset wipe flag
    --self.wipe_flag = nil

end
--------------------------------------------------------------------------------------------------

function GameSetup:HeroKilled( keys )
    local killedHero = EntIndexToHScript( keys.entindex_killed )
    local killedHeroOrigin = killedHero:GetAbsOrigin()
    local killedPlayerID = killedHero:GetPlayerOwnerID()
	if killedHero == nil or killedHero:IsRealHero() == false then
		return
    end

    killedHero.playerLives = killedHero.playerLives - 1

    if killedHero.playerLives <= 0 then
        table.insert(self.player_deaths, killedHero)
        self.respawn_time = 999
    else
        self.respawn_time = BOSS_BATTLES_RESPAWN_TIME
        killedHero:SetRespawnPosition( killedHeroOrigin )

        if killedHero:GetRespawnsDisabled() == false then
            killedHero.nRespawnFX = ParticleManager:CreateParticle( "particles/items_fx/aegis_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, killedHero )
            ParticleManager:SetParticleControl( killedHero.nRespawnFX, 1, Vector( BOSS_BATTLES_RESPAWN_TIME, 0, 0 ) )

            AddFOWViewer( killedHero:GetTeamNumber(), killedHero:GetAbsOrigin(), 800.0, 5, false )
        end
    end

    killedHero:SetTimeUntilRespawn(self.respawn_time)

end
--------------------------------------------------------------------------------------------------

function GameSetup:EncounterCleanUp( origin )
    if origin == nil then return end

    --set boss nil and disable the bossFrame
    if boss ~= nil then
        boss = nil
        CustomNetTables:SetTableValue("hide_boss_frame", "hide", {})
    end

    -- reset cd of all players abilties
    -- destroy thinkers.. -- gotta handle in the thinkers

    -- find all units, kill them
    local units = FindUnitsInRadius(
        DOTA_TEAM_BADGUYS,
        origin,
        nil,
        5000,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false)

    if units ~= nil then
        for _, unit in pairs(units) do

            --[[if unit:GetUnitName() ~= RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss then
                BOSS_BATTLES_ENCOUNTER_COUNTER = BOSS_BATTLES_ENCOUNTER_COUNTER + 1
            end]]

            unit:ForceKill(false)
        end
    end

    return 0.5
end
-----------------------------------------------------------------------------------------------------

function GameSetup:InitCommands()

    Convars:RegisterCommand("set_trigger_boss", function(a, boss_index)
        a = tonumber(boss_index)

        print("set_trigger_boss ", RAID_TABLES[a].spawnLocation)
        print("set_trigger_boss ", RAID_TABLES[a].arena)
        print("set_trigger_boss ", RAID_TABLES[a].boss)

        local heroes = HeroList:GetAllHeroes()

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

        -- reset wipe flag
        --self.wipe_flag = nil


        --Update the bosses hp and mp UI every tick
        Timers:CreateTimer(function()
            if boss ~= nil then
                if boss:GetHealthPercent() == 0 then
                    CustomNetTables:SetTableValue("boss_frame", "hide", {})
                    return 1
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

    end, "  ", FCVAR_CHEAT)

end
-----------------------------------------------------------------------------------------------------

function GameSetup:StartBoss( a )
        print("set_trigger_boss ", RAID_TABLES[a].spawnLocation)
        print("set_trigger_boss ", RAID_TABLES[a].arena)
        print("set_trigger_boss ", RAID_TABLES[a].boss)

        local heroes = HeroList:GetAllHeroes()

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

        -- reset wipe flag
        --self.wipe_flag = nil



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
function GameSetup:OnPlayerChat(keys)
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
                self:StartBoss(2)
            end
            if bossName == "timber" then
                print("TODO: start boss ", bossName)
                self:StartBoss(3)
            end
            if bossName == "techies" then
                print("TODO: start boss ", bossName)
                self:StartBoss(4)
            end
            if bossName == "clock" then
                print("TODO: start boss ", bossName)
                self:StartBoss(5)
            end
            if bossName == "gyro" then
                print("TODO: start boss ", bossName)
                self:StartBoss(6)
            end
        end

    end --end if, commandChar == firstChar
end

--STRING SPLIT FUNCTION FROM: https://stackoverflow.com/questions/42650340/how-to-get-first-character-of-string-in-lua
function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

