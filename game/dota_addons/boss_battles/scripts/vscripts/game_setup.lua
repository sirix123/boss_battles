if GameSetup == nil then
    GameSetup = class({})
end

LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_respawn", "core/modifier_respawn", LUA_MODIFIER_MOTION_NONE )

function GameSetup:init()

    self.player_deaths = {}

    GameRules:EnableCustomGameSetupAutoLaunch(false)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetHeroSelectionTime(30)
    GameRules:SetStrategyTime(0)
    GameRules:SetPreGameTime(1)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPostGameTime(5)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 0)
    GameRules:SetHeroRespawnEnabled(true)
    GameRules:SetStartingGold( 0 )
	GameRules:SetGoldTickTime( 999999.0 )
    GameRules:SetGoldPerTick( 0 )

    GameRules:GetGameModeEntity():SetFixedRespawnTime( 5 )
    GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1800 )
    GameRules:GetGameModeEntity():SetBuybackEnabled( false )
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride( "" )

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

    if npc:IsRealHero() and npc.bFirstSpawned == nil then
        npc.bFirstSpawned = true

        npc:AddNewModifier( npc,  nil, "movement_modifier_thinker", { } )
        npc:AddNewModifier( npc,  nil, "remove_attack_modifier", { } )

        npc:Initialize(keys)
        self:RegisterPlayer(npc)

        -- level up abilities for all heroes to level 1
        if npc:GetUnitName() == "npc_dota_hero_crystal_maiden"
        or npc:GetUnitName() == "npc_dota_hero_windrunner"
        or npc:GetUnitName() == "npc_dota_hero_juggernaut"
        or npc:GetUnitName() == "npc_dota_hero_phantom_assassin"
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
        --print("[game_setup] payload ....")
        -- TODO need to add boss energy, hp, castbar, here?
        Timers:CreateTimer(function()
            local data = {
                entity_index = hero:GetEntityIndex(),
                teamID = hero:GetTeam(),
                playerID = hero:GetPlayerOwnerID(),
                health = hero:GetHealth(),
                max_health = hero:GetMaxHealth(),
                mana = hero:GetMana(),
                max_mana = hero:GetMaxMana(),
                current_lives = hero.playerLives,
            }
            CustomNetTables:SetTableValue("heroes", "index_" .. data.entity_index, data)

            return 0.1
        end)
    end
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
    -- find all units and thinkers from centre of the arena map with xyz radius and forcekill, utilremove, destroy them?
    -- origin could be the boss spawn point
    -- when boss dies, revive all players in their current locations then move to intermission area

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnEntityHurt(keys)
    local damagebits = keys.damagebits

    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        local entVictim = EntIndexToHScript(keys.entindex_killed)

        -- The ability/item used to damage, or nil if not damaged by an item/ability
        local damagingAbility = nil

        if keys.entindex_inflictor ~= nil then
            damagingAbility = EntIndexToHScript(keys.entindex_inflictor)
        end

        local word_length = string.len(tostring(math.floor(keys.damage)))

        local color =  Vector(250, 70, 70)
        local effect_cast = ParticleManager:CreateParticle("particles/msg_fx/msg_damage.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, entVictim:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, keys.damage, 0))
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(math.max(1, keys.damage / 10), word_length, 0))
        ParticleManager:SetParticleControl(effect_cast, 3, color)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

end
--------------------------------------------------------------------------------------------------

-- handles tping players to the boss arena and spawning the boss
function GameSetup:ReadyupCheck() -- called from trigger lua file for activators (ready_up)

    --beastmaster_playerspawn
    --beastmaster_bossspawn
    local heroes = HeroList:GetAllHeroes()
    local beastmasterPlaySpawn = Entities:FindByName(nil, "beastmaster_playerspawn"):GetAbsOrigin()
    self.beastmasterBossSpawn = Entities:FindByName(nil, "beastmaster_bossspawn"):GetAbsOrigin()

    for _,hero in pairs(heroes) do
        if hero:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then
            hero:SetMana(0)
        end
        FindClearSpaceForUnit(hero, beastmasterPlaySpawn, true)
    end

    -- count down message


    -- spawn boss
    Timers:CreateTimer(1.0, function()
        CreateUnitByName("npc_beastmaster", self.beastmasterBossSpawn, true, nil, nil, DOTA_TEAM_BADGUYS)
    end)

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
        table.insert(self.player_deaths, killedPlayerID)
        killedHero:SetRespawnsDisabled( true )

        if #self.player_deaths == HeroList:GetHeroCount() then
            killedHero:SetRespawnsDisabled( false )
            killedHero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
            self.player_deaths = {}
            killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES

            -- register a wipe for current boss

            -- call boss cleanup function
            self:EncounterCleanUp( self.beastmasterBossSpawn )

        end
    else
        killedHero:SetRespawnsDisabled( false )
        killedHero:SetRespawnPosition( killedHeroOrigin )

        if killedHero:GetRespawnsDisabled() == false then
            killedHero.nRespawnFX = ParticleManager:CreateParticle( "particles/items_fx/aegis_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, killedHero )
            ParticleManager:SetParticleControl( killedHero.nRespawnFX, 1, Vector( 5, 0, 0 ) )

            AddFOWViewer( killedHero:GetTeamNumber(), killedHero:GetAbsOrigin(), 800.0, 5, false )
        end
    end

end
--------------------------------------------------------------------------------------------------

function GameSetup:EncounterCleanUp( origin )

    -- reset cd of all players abilties

    -- destroy thinkers..

    -- find all units, kill them
    local units = FindUnitsInRadius(
        DOTA_TEAM_BADGUYS,
        origin,
        nil,
        2500,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    if units ~= nil then
        for _, unit in pairs(units) do
            unit:ForceKill(false)
        end
    end
end
