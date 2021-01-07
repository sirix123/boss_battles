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

    -- setup session manager
    SessionManager:Init()

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
        ModeSelector:Start()
        HeroSelection:Start()
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        -- register the raid wipe timer
        self:RegisterRaidWipe()

        -- spawn testing stuff
        intermission_manager:SpawnTestingStuff()

    end

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)

    if npc:IsRealHero() == true then
        -- add grace period when respawning..
        npc:AddNewModifier( npc, nil, "modifier_grace_period", { duration = 3 } )

        -- remove the death vision
        if self.death_vision ~= nil then
            RemoveFOWViewer(npc:GetTeamNumber(),self.death_vision)
        end
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
        player_frame_manager:RegisterPlayer(npc)

	    npc.class_name = GetClassName(npc:GetUnitName())

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

function GameSetup:RegisterRaidWipe( )
    Timers:CreateTimer(function()

        --print("#HERO_LIST ",#HERO_LIST)
        if #HERO_LIST > 0 then
            if #self.player_deaths == #HERO_LIST then
                --print("RegisterRaidWipe ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].name)

                if self.bSessionManager_wipe == true then
                    self.bSessionManager_wipe = false
                    self.bBossKilled = false
                    SessionManager:StopRecordingAttempt( self.bBossKilled )

                    Timers:CreateTimer(5.0, function()

                        -- revive and move dead heroes
                        for _, killedHero in pairs(self.player_deaths) do
                            killedHero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
                            self.respawn_time = BOSS_BATTLES_RESPAWN_TIME
                            killedHero:SetTimeUntilRespawn(self.respawn_time)

                            -- depending on the mode... figure out the lives players should have and what encounter they will do next
                            if STORY_MODE == true then -- infinte lives and stay on wiped encounter
                                killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES

                            elseif NORMAL_MODE == true or HARD_MODE == true then -- 3 lives, one earned for each player after a boss kill, if players all die to a boss reset back to the first boss
                                killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES
                                BOSS_BATTLES_ENCOUNTER_COUNTER = 2

                            elseif DEBUG_MODE == true then -- not sure yet

                            end

                            -- remove items from their inventory (items used in techies fight atm)
                            for i=0,8 do
                                local item = killedHero:GetItemInSlot(i)
                                if item ~= nil then -- add item name here if we just want to remove specific items
                                    item:RemoveSelf()
                                end
                            end
                        end

                        -- call boss cleanup function
                        self:EncounterCleanUp( Entities:FindByName(nil, RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena):GetAbsOrigin() )

                        -- reset death counter
                        self.player_deaths = {}

                        return false

                    end)
                end
            end

            return 0.5
        end
        return 0.5
    end)
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

            self.bBossKilled = true
            SessionManager:StopRecordingAttempt( self.bBossKilled )

            if npc:GetUnitName() == "npc_tinker" then
                SessionManager:SendSessionData()
            end

            -- repsawn deadplayers and reset lifes
            local isHeroAlive = false
            local heroes = HERO_LIST--HeroList:GetAllHeroes()
            for _, hero in pairs(heroes) do
                hero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
                self.respawn_time = 1
                self.player_deaths = {}
                hero:SetTimeUntilRespawn(self.respawn_time)

                -- depending on the mode... figure out the lives players should have and what encounter they will do next
                if STORY_MODE == true then -- infinte lives and stay on wiped encounter
                    hero.playerLives = BOSS_BATTLES_PLAYER_LIVES

                elseif NORMAL_MODE == true or HARD_MODE == true then -- 3 lives, one earned for each player after a boss kill, if players all die to a boss reset back to the first boss
                    if hero.playerLives < 3 then
                        hero.playerLives = hero.playerLives + 1
                    end
                elseif DEBUG_MODE == true then -- not sure yet

                end

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

                    -- remove items
                    for i=0,8 do
                        local item = hero:GetItemInSlot(i)
                        if item ~= nil then -- add item name here if we just want to remove specific items
                            item:RemoveSelf()
                        end
                    end

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

        if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil and keys.entindex_inflictor ~= nil then
            if EntIndexToHScript(keys.entindex_inflictor):GetTeam() == DOTA_TEAM_GOODGUYS then
                local entVictim = EntIndexToHScript(keys.entindex_killed)
                local entAttacker = EntIndexToHScript(keys.entindex_attacker)

                -- The ability/item used to damage, or nil if not damaged by an item/ability
                local damagingAbility = nil

                if keys.entindex_inflictor ~= nil then
                    damagingAbility = EntIndexToHScript(keys.entindex_inflictor)
                end

                local word_length = string.len(tostring(math.floor(keys.damage)))

                local color =  Vector(255, 255, 255)
                local effect_cast = ParticleManager:CreateParticle("particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) --particles/custom_msg_damage.vpcf particles/msg_fx/msg_damage.vpcf
                ParticleManager:SetParticleControl(effect_cast, 0, entVictim:GetAbsOrigin())
                ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, keys.damage, 0))
                ParticleManager:SetParticleControl(effect_cast, 2, Vector(0.5, word_length, 0)) --vector(math.max(1, keys.damage / 10), word_length, 0))
                ParticleManager:SetParticleControl(effect_cast, 3, color)
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end
        end
    end

end
--------------------------------------------------------------------------------------------------

-- handles tping players to the boss arena and spawning the boss
function GameSetup:ReadyupCheck() -- called from trigger lua file for activators (ready_up)
    local heroes = HERO_LIST--HeroList:GetAllHeroes()

    self.bSessionManager_wipe = true -- reest the wipe tracker flag

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

        self:HeroCheck() -- removes mana, removes dagger from rogue etc

        for _,hero in pairs(HERO_LIST) do
            FindClearSpaceForUnit(hero, self.player_spawn, true) -- spawn players in the arena
        end

        -- spawn boss
        local boss = nil
        Timers:CreateTimer(1.0, function()
            -- look at raidtables and spawn the boss depending on the encounter counter
            boss = CreateUnitByName(RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss, self.boss_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
            return false
        end)

        SessionManager:RecordAttempt()

        -- default boss frame values / init
        boss_frame_manager:SendBossName()
        boss_frame_manager:UpdateManaHealthFrame( boss )
        boss_frame_manager:ShowBossManaFrame()
        boss_frame_manager:ShowBossHpFrame()

        return false
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

            self.death_vision = AddFOWViewer( killedHero:GetTeamNumber(), killedHero:GetAbsOrigin(), 5000.0, 999, true )
        end
    end

    killedHero:SetTimeUntilRespawn(self.respawn_time)

end
--------------------------------------------------------------------------------------------------

function GameSetup:EncounterCleanUp( origin )
    if origin == nil then return end

    --print("cleaning up encounter ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].name)

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

function GameSetup:HeroCheck()

    -- fix up each hero depending on what they need
    for _,hero in pairs(HERO_LIST) do

        -- general clean (find all abilities that a hero has and end their cooldowns and set hero hp to full)
        if hero:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then
            hero:SetMana(0)
        end

        -- rogue clean
        if hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
            -- find the dagger if it exists and remove it.... ability will it get stuck? move the dagger to the player spawn?
            local units = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, hero:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
            for _,unit in pairs(units) do
                if unit:GetUnitName() == "npc_shadow" then
                    unit:SetAbsOrigin(self.player_spawn)
                end
            end
        end

        -- ice mage clean
        if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" then
            if hero:HasModifier("bonechill_modifier") then
                hero:RemoveModifierByName("bonechill_modifier")
            end
            if hero:HasModifier("shatter_modifier") then
                hero:RemoveModifierByName("shatter_modifier")
            end
        end

    end
end

