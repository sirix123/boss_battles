if GameSetup == nil then
    GameSetup = class({})
end

RAID_TABLES = require('managers/raid_init_tables')

LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_grace_period", "player/generic/modifier_grace_period", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hide_hero", "player/generic/modifier_hide_hero", LUA_MODIFIER_MOTION_NONE )

function GameSetup:init()

    self.player_deaths = {}

    -- default game rules our mod needs to run
    GameRules:Init()

    -- setup commands
    Commands:Init()

    PlayerManager:SetUpMouseUpdater()
    PlayerManager:SetUpMovement()

    --listen to game state event
    -- events here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self) -- valve engine event
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self) -- npc_spawned is a valve engine event
    --ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'PlayerPickHero'), self) -- dota_player_pick_hero is a valve engine event
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self) --
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'OnEntityHurt'), self)

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then

        Filters:Activate(GameSetup, self)

        local mode = GameRules:GetGameModeEntity()
        mode:SetExecuteOrderFilter(Dynamic_Wrap(GameSetup, "ExecuteOrderFilter" ), GameSetup)

    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
        HeroSelection:Start()
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        -- register the raid wipe timer
        self:RegisterRaidWipe()

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

    if npc:GetUnitName() == "npc_dota_hero_wisp" then
        npc:AddNewModifier(npc,nil,"modifier_hide_hero",{duration = -1})
    end

    if npc:IsRealHero() and npc:GetUnitName() ~= "npc_dota_hero_wisp" and npc.bFirstSpawned == nil then
        -- npc.bFirstSpawned is set to true during initlize()

        -- create our own hero list because of the custom hero select screen
        table.insert(HERO_LIST,npc)

        npc:AddNewModifier( npc,  nil, "movement_modifier_thinker", { } )
        npc:AddNewModifier( npc,  nil, "remove_attack_modifier", { } )

        npc:Initialize()
        self:RegisterPlayer(npc)

        --print("on spanwed lives ", npc.playerLives )

        -- level up abilities for all heroes to level 1
        if npc:GetUnitName() == "npc_dota_hero_crystal_maiden"
        or npc:GetUnitName() == "npc_dota_hero_medusa"
        or npc:GetUnitName() == "npc_dota_hero_juggernaut"
        or npc:GetUnitName() == "npc_dota_hero_phantom_assassin"
        or npc:GetUnitName() == "npc_dota_hero_templar_assassin"
        or npc:GetUnitName() == "npc_dota_hero_grimstroke"
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
            local heroes = HERO_LIST--HeroList:GetAllHeroes()
            local playerData = {}
            local i = 1
            for _, hero in pairs(heroes) do
                playerData[i] = {}
                playerData[i].entityIndex = hero:GetEntityIndex()
                playerData[i].playerName = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID())
                playerData[i].className = GetClassName(hero:GetUnitName())
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

function GameSetup:RegisterRaidWipe( )
    Timers:CreateTimer(function()
        --print("GetPlayerCount ", PlayerResource:GetPlayerCount())
        if #self.player_deaths == #HERO_LIST then
            Timers:CreateTimer(5.0, function()

                -- revive and move dead heroes
                for _, killedHero in pairs(self.player_deaths) do
                    killedHero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
                    self.respawn_time = BOSS_BATTLES_RESPAWN_TIME
                    killedHero:SetTimeUntilRespawn(self.respawn_time)
                    killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES

                    -- remove items from their inventory (items used in techies fight atm)
                    for i=0,8 do
                        local item = killedHero:GetItemInSlot(i)
                        if item ~= nil then -- add item name here if we just want to remove specific items
                            item:RemoveSelf()
                        end
                    end
                end

                -- call boss cleanup function
                self:EncounterCleanUp( self.boss_spawn )

                -- reset  death counter
                self.player_deaths = {}

            end)
        end

        return 0.5
    end)
end

--------------------------------------------------------------------------------------------------
function GameSetup:SpawnTestingStuff(keys)

    --[[ flame turrets for right side of the map, need to change facing vector
    local flame_turret_1 = CreateUnitByName("npc_flame_turret", Vector(-10154,-8652,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_1:SetForwardVector(Vector(0,-1, flame_turret_1.z ))

    local flame_turret_2 = CreateUnitByName("npc_flame_turret", Vector(-9511,-8652,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_2:SetForwardVector(Vector(0,-1, flame_turret_2.z ))

    local flame_turret_3 = CreateUnitByName("npc_flame_turret", Vector(-9744,-11704,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_3:SetForwardVector(Vector(0,1, flame_turret_3.z ))]]

    -- create test item
    --local newItem = CreateItem("item_tango", nil, nil)
    --CreateItemOnPositionForLaunch( Vector(-10000,-10000,256), newItem )

    -- target dummy (1 by itself)(immortal)
    local dummy_1 = CreateUnitByName("npc_dota_creature_dummy_target_boss_immortal", Vector(-12276,-10346,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_1:SetForwardVector(Vector(0,-1, dummy_1.z ))

    -- target dummy (1 by itself)
    --CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11744,-9369,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy (3)
    local dummy_2 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11776,-10352,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_2:SetForwardVector(Vector(0,-1, dummy_2.z ))

    local dummy_3 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11776,-10352,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_3:SetForwardVector(Vector(0,-1, dummy_3.z ))

    local dummy_4 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11776,-10352,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_4:SetForwardVector(Vector(0,-1, dummy_4.z ))

    -- target dummy (1 moving)
    --CreateUnitByName("npc_dota_creature_gnoll_assassin_moving", Vector(-11077,-8747,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy friendly
    local dummy_5 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-12663,-10344,256), true, nil, nil, DOTA_TEAM_GOODGUYS)
    dummy_5:SetForwardVector(Vector(0,-1, dummy_5.z ))

    --test
    --PrintTable(RAID_TABLES, indent, done)

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnEntityKilled(keys)
    local npc = EntIndexToHScript(keys.entindex_killed)

    if PICKING_DONE == true then

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
            -- repsawn deadplayers and reset lifes
            local isHeroAlive = false
            local heroes = HERO_LIST--HeroList:GetAllHeroes()
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
                local heroes = HERO_LIST --HeroList:GetAllHeroes()
                for _,hero in pairs(heroes) do
                    FindClearSpaceForUnit(hero, BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION, true)
                end
            end)

            Timers:CreateTimer(2.0, function()
                -- clean up enounter
                self:EncounterCleanUp( self.boss_spawn )
            end)

        end
    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:OnEntityHurt(keys)
    -- print("GameSetup:OnEntityHurt(keys). Printing keys: ")
    -- PrintTable(keys, indent, done)

    -- Store the dmg done in a table to maintain history. 
    -- StoreDamageDone(keys)
    if PICKING_DONE == true then

        --DEBUG:    
        local inflictor = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor):GetName()
        if inflictor == nil then inflictor = "unknown_ability" end
        --print("" ..EntIndexToHScript(keys.entindex_attacker):GetUnitName().. " attacked " ..EntIndexToHScript(keys.entindex_killed):GetUnitName().. " with " ..inflictor.. " dealing " ..keys.damage)

        -- Only process dmg if from or too a player Hero.
        local heroes = HERO_LIST--HeroList:GetAllHeroes()
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

end
--------------------------------------------------------------------------------------------------

-- handles tping players to the boss arena and spawning the boss
function GameSetup:ReadyupCheck() -- called from trigger lua file for activators (ready_up)
    local heroes = HERO_LIST--HeroList:GetAllHeroes()

    -- look at raid tables and move players to boss encounter based on counter
    print("game_setup: Start boss counter: ", BOSS_BATTLES_ENCOUNTER_COUNTER," ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss )

    -- reset damage done
    DamageTable = {}

    self.boss_arena_name     = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].spawnLocation
    self.player_arena_name   = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena

    self:EncounterCleanUp( Entities:FindByName(nil, self.boss_arena_name):GetAbsOrigin() )

    Timers:CreateTimer(1.0, function()

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
        local boss = nil
        Timers:CreateTimer(1.0, function()
            -- look at raidtables and spawn the boss depending on the encounter counter
            boss = CreateUnitByName(RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss, self.boss_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
            return false
        end)

        -- default boss frame values / init
        boss_frame_manager:SendBossName()
        boss_frame_manager:UpdateManaHealthFrame( boss )
        boss_frame_manager:ShowBossManaFrame()
        boss_frame_manager:ShowBossHpFrame()

        return false
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

    --PrintTable(keys, indent, done)
    --print("entindex_inflictor ",EntIndexToHScript( keys.entindex_inflictor ):GetUnitName())
    --print("entindex_attacker ",EntIndexToHScript( keys.entindex_attacker ):GetUnitName())

    killedHero.playerLives = killedHero.playerLives - 1
    --print("OnEntityKilled lives ", killedHero.playerLives )

    if killedHero.playerLives <= 0 then
        table.insert(self.player_deaths, killedHero)
        self.respawn_time = 999
    else
        self.respawn_time = BOSS_BATTLES_RESPAWN_TIME

        -- if in the beastmaster fight and the player dies to the bird (being dragged into the water) spawn them in the centre of the map
        if BOSS_BATTLES_ENCOUNTER_COUNTER == 2 then
            --and EntIndexToHScript( keys.entindex_inflictor ):GetUnitName() == "fish_trigger"
            killedHero:SetRespawnPosition( Entities:FindByName(nil, RAID_TABLES[2].spawnLocation):GetAbsOrigin() )
        else
            killedHero:SetRespawnPosition( killedHeroOrigin )
        end

        if killedHero:GetRespawnsDisabled() == false then
            killedHero.nRespawnFX = ParticleManager:CreateParticle( "particles/items_fx/aegis_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, killedHero )
            ParticleManager:SetParticleControl( killedHero.nRespawnFX, 1, Vector( BOSS_BATTLES_RESPAWN_TIME, 0, 0 ) )

            AddFOWViewer( killedHero:GetTeamNumber(), killedHero:GetAbsOrigin(), 5000.0, 5, false )
        end
    end

    killedHero:SetTimeUntilRespawn(self.respawn_time)

end
--------------------------------------------------------------------------------------------------

function GameSetup:EncounterCleanUp( origin )
    if origin == nil then return end

    --GameRules:SetTreeRegrowTime( 1.0 )

    GridNav:RegrowAllTrees()

    --[[local trees = GridNav:GetAllTreesAroundPoint( origin, 9000, false )
    for _,tree in pairs(trees) do
        if tree:IsStanding() == false then
            tree:GrowBack()
        end
    end]]

    --set boss nil and disable the bossFrame
    if boss ~= nil then
        boss = nil
        CustomNetTables:SetTableValue("hide_boss_frame", "hide", {})
    end

    -- find all units, kill them
    local units = FindUnitsInRadius(
        DOTA_TEAM_BADGUYS,
        origin,
        nil,
        5000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false)

    if units ~= nil then
        for _, unit in pairs(units) do
            --unit:ForceKill(false)
            unit:RemoveSelf()
        end
    end
end
-----------------------------------------------------------------------------------------------------

