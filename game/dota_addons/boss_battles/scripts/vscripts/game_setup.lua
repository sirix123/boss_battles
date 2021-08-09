if GameSetup == nil then
    GameSetup = class({})
end

RAID_TABLES = require('managers/raid_init_tables')

LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_grace_period", "player/generic/modifier_grace_period", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hide_hero", "player/generic/modifier_hide_hero", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "admin_god_mode", "player/generic/admin_god_mode", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "blademaster_death_enable_spells", "player/warlord/modifiers/blademaster_death_enable_spells", LUA_MODIFIER_MOTION_NONE )

function GameSetup:init()

    self.player_deaths = {}

    -- init client handshake
    client_handshake:Init()

    -- default game rules our mod needs to run
    GameRules:Init()

    -- setup commands
    Commands:Init()

    -- setup session manager
    SessionManager:Init()

    -- setup scoreboard
    Scoreboard:Init()

    -- setup movement
    PlayerManager:SetUpMouseUpdater()
    PlayerManager:SetUpMovement()

    -- timer for updating player frames
    player_frame_manager:UpdatePlayer()

    -- init dc manager
    disconnect_manager:Init()

    --listen to game state event
    -- events here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self) -- valve engine event
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self) -- npc_spawned is a valve engine event
    --ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'PlayerPickHero'), self) -- dota_player_pick_hero is a valve engine event
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self) --
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'OnEntityHurt'), self)
    ListenToGameEvent('player_reconnected', Dynamic_Wrap(self, 'OnPlayerReconnected'), self)
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(self, 'OnPlayerDisconnected'), self)

    --ListenToGameEvent('player_team', Dynamic_Wrap(self, 'OnPlayerTeamChange'), self)

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        loading_screen_data:SendLeaderBoardData()

        -- stripe init
        CosmeticManager:Init()
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        Filters:Activate(GameSetup, self)

        local mode = GameRules:GetGameModeEntity()
        mode:SetExecuteOrderFilter(Dynamic_Wrap(GameSetup, "ExecuteOrderFilter" ), GameSetup)

    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then

    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        print("does this run on reconnect? (GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) ")

        -- might to need check all clients are ready with a timer ehre and dont move past until theyre
        Timers:CreateTimer(1.0, function()
            if PLAYERS_HANDSHAKE_READY == PlayerResource:GetPlayerCount() then
                ModeSelector:Start()
                HeroSelection:Start()

                -- register the raid wipe timer
                self:RegisterRaidWipe()

                -- spawn testing stuff
                intermission_manager:SpawnTestingStuff()

                return false
            end
            return 1.0
        end)
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME or GameRules:State_Get() == DOTA_GAMERULES_STATE_DISCONNECT then
    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:OnPlayerDisconnected(keys)
    print("GameSetup:OnPlayerDisconnected(keys) ",keys)

    --[[
        for key, v in pairs(keys) do
            print("key, ",key,"v, ",v)
        end

        key, 	PlayerID	v, 	1
        key, 	xuid	v, 	STEAM ID
        key, 	game_event_name	v, 	player_disconnect
        key, 	game_event_listener	v, 	100663304
        key, 	splitscreenplayer	v, 	-1
        key, 	name	v, 	PLAYER NAME
        key, 	networkid	v, 	NET WORK ID
        key, 	userid	v, 	4 -- this increases per disconnect
        key, 	reason	v, 	2
    ]]

    -- i think based on this information above we can add a flag to each player if they're disconnected
    -- if they reconnect we can change the flag...
    -- create a timer at game start that polls/checks each player for the flag and if all players are DC
    -- we can send the session data

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and PICKING_DONE == true then

        --local pID = keys.PlayerID
        --local hPlayer = PlayerResource:GetPlayer(pID)
        --local hPlayerHero = hPlayer:GetAssignedHero()

        disconnect_manager:PlayerDisconnect( )

        --print("disconnecting hero name, ",hPlayerHero:GetUnitName())

        --hPlayerHero.isConnected = false
    end

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnPlayerReconnected(keys)
    --print("GameSetup:OnPlayerReconnected(keys) ",keys)

    --CustomGameEventManager:Send_ServerToPlayer( player, "display_scoreboard", data )

    -- send event to the client that reconnected most likely... we can send the picking done command as they're setup for that listener.

    -- not sure if we need to makesure the client is ready before we sent this event..

    --[[for key, v in pairs(keys) do
        print("key, ",key,"v, ",v)
    end]]

    --[[
        key, 	game_event_listener	v, 	1602224135
        key, 	game_event_name	v, 	player_reconnected
        key, 	PlayerID	v, 	1
        key, 	splitscreenplayer	v, 	-1
    ]]

    -- adding comment anotheirn one

    --print("running reconnect code")

    disconnect_manager:PlayerReconnect()

    local pID = keys.PlayerID
    local hPlayer = PlayerResource:GetPlayer(pID)
    local hPlayerHero = hPlayer:GetAssignedHero()

    Timers:CreateTimer(3, function()
        CustomGameEventManager:Send_ServerToPlayer( hPlayer, "player_reconnect", {} )

        -- redraw the player frames
        for _, hero in pairs(HERO_LIST) do
            player_frame_manager:CreatePlayerFrameReconnect( hero, hPlayer )
        end

        -- if players are in a boss fight (fighting a boss move the reconnected hero to the arena)
        if PLAYERS_FIGHTING_BOSS == true then
            self.player_spawn = Entities:FindByName(nil, RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena):GetAbsOrigin()
            FindClearSpaceForUnit(hPlayerHero, self.player_spawn, true)
        end

        return false
    end)
end
--------------------------------------------------------------------------------------------------

function GameSetup:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)

    -- runs when the player respawns after a death
    if npc:IsRealHero() == true then
        -- add grace period when respawning..
        npc:AddNewModifier( npc, nil, "modifier_grace_period", { duration = 3 } )

        -- remove the death vision
        if self.death_vision ~= nil then
            RemoveFOWViewer(npc:GetTeamNumber(),self.death_vision)
        end

        -- if remove is suppose to spawn with 0 mana, spawn them with 0 mana
        Timers:CreateTimer(0.02, function()
            if npc:GetUnitName() == "npc_dota_hero_crystal_maiden" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_windrunner" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_lina" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_juggernaut" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_grimstroke" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_queenofpain" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_hoodwink" then npc:SetMana(0) end
            if npc:GetUnitName() == "npc_dota_hero_pugna" then npc:SetMana(0) end
            return false
        end)

        -- enable camera control
        PlayerManager:CameraControl( npc:GetPlayerID(), 1 ) -- 0 = disable camera, 1 = enable camera

        npc:GetPlayerOwner():SetMusicStatus(2,1) -- battle music

        -- remove wearables
        if npc:HasModifier("modifier_arcana_cosmetics") then
            Wearables:HideWearables(npc)
        end

    end

    -- runs when the player loads in as wisp automatically
    if npc:GetUnitName() == "npc_dota_hero_wisp" then
        npc:AddNewModifier(npc,nil,"modifier_hide_hero",{duration = -1})
    end

    -- this runs on intial spawn
    if npc:IsRealHero() and npc:GetUnitName() ~= "npc_dota_hero_wisp" and npc.bFirstSpawned == nil then
        -- npc.bFirstSpawned is set to true during initlize()

        Timers:CreateTimer(2, function()
            local playerID = npc:GetPlayerID()
            local hPlayer = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( hPlayer, "player_hero_spawned", {} )
            return false
        end)

        -- create our own hero list because of the custom hero select screen
        table.insert(HERO_LIST,npc)

        npc:AddNewModifier( npc,  nil, "movement_modifier_thinker", { } )
        npc:AddNewModifier( npc,  nil, "remove_attack_modifier", { } )

        npc:Initialize()
        npc.class_name = GetClassName(npc:GetUnitName())

        npc:GetPlayerOwner():SetMusicStatus(1,1)

        player_frame_manager:CreatePlayerFrame( npc )
        --print("on spanwed lives ", npc.playerLives )

        if IsInToolsMode() == true then
            npc:AddNewModifier( npc,  nil, "admin_god_mode", { } )
        end

        -- level up abilities for all heroes to level 1
        for i = 0, 23 do
            local ability = npc:GetAbilityByIndex(i)
            if ability then
                if ability:GetAbilityType() ~= 2 and ability:GetName() ~= "special_bonus_attributes" then -- To not level up the talents
                    ability:SetLevel(1)
                end
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
                    nBOSS_HP_ATTEMPT = self.boss:GetHealthPercent()
                    SessionManager:StopRecordingAttempt( self.bBossKilled )

                    nATTEMPT_TRACKER = nATTEMPT_TRACKER + 1

                    Timers:CreateTimer(8.0, function()

                        -- revive and move dead heroes
                        for _, killedHero in pairs(self.player_deaths) do
                            killedHero:SetRespawnPosition( BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION )
                            self.respawn_time = BOSS_BATTLES_RESPAWN_TIME
                            killedHero:SetTimeUntilRespawn(self.respawn_time)

                            -- depending on the mode... figure out the lives players should have and what encounter they will do next
                            if STORY_MODE == true then -- infinte lives and stay on wiped encounter
                                killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES

                            elseif NORMAL_MODE == true or HARD_MODE == true then -- 3 lives total
                                killedHero.playerLives = BOSS_BATTLES_PLAYER_LIVES
                                self.previous_encounter = BOSS_BATTLES_ENCOUNTER_COUNTER
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
                        if STORY_MODE == true then
                            self:EncounterCleanUp( Entities:FindByName(nil, RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena):GetAbsOrigin() )
                        elseif NORMAL_MODE == true or HARD_MODE == true then
                            self:EncounterCleanUp( Entities:FindByName(nil, RAID_TABLES[self.previous_encounter].arena):GetAbsOrigin() )
                        end

                        -- reset death counter
                        self.player_deaths = {}

                        -- dispaly scoreboard
                        --Scoreboard:DisplayScoreBoard(true)
                        local data = SessionManager:GetAttemptData()
                        CustomGameEventManager:Send_ServerToAllClients( "sendScoreboardData", data )

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
        --print("BOSS_BATTLES_ENCOUNTER_COUNTER ",BOSS_BATTLES_ENCOUNTER_COUNTER)
        if npc:GetUnitName() == RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss then

            self.bBossKilled = true
            RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].bossKilled = true
            nBOSS_HP_ATTEMPT = 0.0
            SessionManager:StopRecordingAttempt( self.bBossKilled )

            -- reset the attempt tracker
            nATTEMPT_TRACKER = 0

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

                elseif NORMAL_MODE == true or HARD_MODE == true then -- 3 lives total
                    -- add code to give dead players 1 life (0 lives)
                    if hero.playerLives == 0 then
                        hero.playerLives = 1
                    end
                end

                if hero:IsAlive() == true then
                    isHeroAlive = true
                end
            end

            -- if the 6 bosses are killed send session data
            for _, boss in pairs(RAID_TABLES) do
                if boss.bossKilled == true then
                    nBOSSES_KILLED = nBOSSES_KILLED + 1
                end
            end

            if nBOSSES_KILLED == 7 then --7
                bGAME_COMPLETE = true
                SessionManager:SendSessionData()
                EndGameScreenManager:OpenPostGameScreen()
            else
                nBOSSES_KILLED = 0
            end

            if isHeroAlive == true and bGAME_COMPLETE == false and BOSS_BATTLES_ENCOUNTER_COUNTER < 7 then
                BOSS_BATTLES_ENCOUNTER_COUNTER = BOSS_BATTLES_ENCOUNTER_COUNTER + 1
            end

            -- move alive players to intermission area
            Timers:CreateTimer(4.5, function()
                heroes = HERO_LIST --HeroList:GetAllHeroes()
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

            Timers:CreateTimer(6.5, function()
                -- clean up enounter
                self:EncounterCleanUp( self.boss_spawn )
            end)

            -- dispaly scoreboard and send attempt data to UI
            --local forceOpen = true
            --Scoreboard:DisplayScoreBoard(forceOpen)
            local data = SessionManager:GetAttemptData()
            CustomGameEventManager:Send_ServerToAllClients( "sendScoreboardData", data )

        end
    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:OnEntityHurt(keys)
    -- print("GameSetup:OnEntityHurt(keys). Printing keys: ")
    --PrintTable(keys, indent, done)

    -- Store the dmg done in a table to maintain history. 
    -- StoreDamageDone(keys)
    if PICKING_DONE == true then

        --DEBUG:
        local inflictor = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor):GetName()
        if inflictor == nil then inflictor = "unknown_ability" end
        --print("" ..EntIndexToHScript(keys.entindex_attacker):GetUnitName().. " attacked " ..EntIndexToHScript(keys.entindex_killed):GetUnitName().. " with " ..inflictor.. " dealing " ..keys.damage)

        -- Only process dmg if from or too a player Hero.
        --local heroes = HERO_LIST--HeroList:GetAllHeroes()
        --for _, hero in pairs(heroes) do
            -- Store damage done or received to hero
            --if (hero:GetEntityIndex() == keys.entindex_killed) or (hero:GetEntityIndex() == keys.entindex_attacker) then
                --Scoreboard:StoreDamageDone(keys)
                --break
            --end
        --end

        Scoreboard:StoreDamageDone(keys)

        --DPS METER:
        Scoreboard:UpdateDamageMeter()

        -- damage numbers on victim from player
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
                --local effect_cast = ParticleManager:CreateParticle("particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) --particles/custom_msg_damage.vpcf particles/msg_fx/msg_damage.vpcf
                local effect_cast = ParticleManager:CreateParticleForPlayer( "particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN , entAttacker, entAttacker:GetPlayerOwner() )
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
    self.bSessionManager_wipe = true -- reest the wipe tracker flag
    self.playerDeaths = 0

    -- look at raid tables and move players to boss encounter based on counter
    --print("game_setup: Start boss counter: ", BOSS_BATTLES_ENCOUNTER_COUNTER," ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss )

    for _,hero in pairs(HERO_LIST) do
        hero.dmgDoneAttempt = 0  -- reset damage done
        hero.dmgTakenAttempt = 0  -- reset dmg taken
        hero.dmgDetails = {}
        hero.dmgTakenDetails = {}
        hero.deathsDetails = {}
    end

    self.boss_arena_name     = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].spawnLocation
    self.player_arena_name   = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena

    self:EncounterCleanUp( Entities:FindByName(nil, self.boss_arena_name):GetAbsOrigin() )

    PLAYERS_FIGHTING_BOSS = true

    Timers:CreateTimer(1.0, function()

        --print("game_setup: boss_arena: ", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].spawnLocation," player_arena:", RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].arena )

        -- find enity using the above values from the table
        self.boss_spawn = Entities:FindByName(nil, self.boss_arena_name):GetAbsOrigin()
        self.player_spawn = Entities:FindByName(nil, self.player_arena_name):GetAbsOrigin()

        self:HeroCheck() -- removes mana, removes dagger from rogue etc, resets abiliti cds

        for _,hero in pairs(HERO_LIST) do
            FindClearSpaceForUnit(hero, self.player_spawn, true) -- spawn players in the arena
        end

        -- spawn boss
        self.boss = nil
        Timers:CreateTimer(1.0, function()
            -- look at raidtables and spawn the boss depending on the encounter counter
            self.boss = CreateUnitByName(RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].boss, self.boss_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
            return false
        end)

        SessionManager:RecordAttempt()

        return false
    end)

end
--------------------------------------------------------------------------------------------------

function GameSetup:HeroKilled( keys )

    if keys.entindex_killed == nil then
        return
    end

    local killedHero = EntIndexToHScript( keys.entindex_killed )
    local killedHeroOrigin = killedHero:GetAbsOrigin()
    local killedPlayerID = killedHero:GetPlayerOwnerID()
	if killedHero == nil or killedHero:IsRealHero() == false then
		return
    end

    killedHero:GetPlayerOwner():SetMusicStatus(4,1) -- death music

    self.inflictor = ""
    if keys.entindex_inflictor == nil then
        self.inflictor = "unknown_ability"
    else
        self.inflictor = EntIndexToHScript(keys.entindex_inflictor):GetName()
    end

    --PrintTable(keys, indent, done)
    --print("entindex_inflictor ",EntIndexToHScript( keys.entindex_inflictor ):GetUnitName())
    --print("entindex_attacker ",EntIndexToHScript( keys.entindex_attacker ):GetUnitName())

    --[[
        damagebits: 0
        entindex_attacker: 88
        entindex_inflictor: 88
        entindex_killed: 88
        game_event_listener: 503316485
        game_event_name: entity_killed
        splitscreenplayer: -1
    ]]

    --[[if TRACK_DATA == true then

        local hero = killedHero

        -- GameRules:GetGameTime()
        if hero.deathsDetails == nil or #hero.deathsDetails == 0 then
            print("init - deathsDetails table does not contain anything")
            local targets = {}
            targets["attacker"] = EntIndexToHScript(keys.entindex_attacker):GetUnitName()
            targets["abilities"] = {}

            local ability = {}
            ability["spell_name"] = ""
            ability["time"] = GameRules:GetGameTime()

            ability["spell_name"] = self.inflictor
            table.insert(targets["abilities"],ability)
            table.insert(hero.deathsDetails,targets)
        else

            self.target_exists = false
            for _, targetData in pairs(hero.deathsDetails) do
                if targetData.attacker == EntIndexToHScript(keys.entindex_attacker):GetUnitName() == true then
                    self.target_exists = true
                end
            end

            if self.target_exists == true then
                for _, targetData in pairs(hero.deathsDetails) do
                    if targetData.attacker == EntIndexToHScript(keys.entindex_attacker):GetUnitName() == true then

                        local ability = {}
                        ability["spell_name"] = ""
                        ability["time"] = GameRules:GetGameTime()

                        ability["spell_name"] = self.inflictor
                        table.insert(targetData.abilities,ability)
                        break
                    end
                end
            end

            if self.target_exists == false then
                local targets = {}
                targets["attacker"] = EntIndexToHScript(keys.entindex_attacker):GetUnitName()
                targets["abilities"] = {}

                local ability = {}
                ability["spell_name"] = ""
                ability["time"] = GameRules:GetGameTime()

                ability["spell_name"] = self.inflictor
                table.insert(targets["abilities"],ability)
                table.insert(hero.deathsDetails,targets)
            end
        end
    end]]


    killedHero.playerLives = killedHero.playerLives - 1
    killedHero.playerDeaths = killedHero.playerDeaths + 1

    if killedHero.playerLives <= 0 then
        table.insert(self.player_deaths, killedHero)
        self.respawn_time = 9999
        PlayerManager:CameraControl( killedPlayerID, 0 ) -- 0 = disable camera, 1 = enable camera
    else
        self.respawn_time = BOSS_BATTLES_RESPAWN_TIME

        if self.inflictor == "fish_puddle" then
            killedHero:SetRespawnPosition( Entities:FindByName(nil, RAID_TABLES[4].spawnLocation):GetAbsOrigin() )
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
    PLAYERS_FIGHTING_BOSS = false

    DestroyItems( origin )

    GridNav:RegrowAllTrees()

    if Crystal_Phase1_Spawns_Particles ~= 0 and Crystal_Phase1_Spawns_Particles ~= nil then
        for _, crystal_particle in pairs(Crystal_Phase1_Spawns_Particles) do
            ParticleManager:DestroyParticle(crystal_particle,true)
        end
    end

    -- find all thinkers and destroy them (dota thinkers)
    local previous_result = nil
    local result = Entities:FindByClassname(nil, "npc_dota_thinker")
    local count = 0
    while result ~= nil and count < 300 do

        if result then
            result:ForceKill(false)
        end

        if previous_result == nil then
            result = Entities:FindByClassname(nil, "npc_dota_thinker")
        else
            result = Entities:FindByClassname(previous_result, "npc_dota_thinker")
        end

        count = count + 1
    end

    --[[local trees = GridNav:GetAllTreesAroundPoint( origin, 9000, false )
    for _,tree in pairs(trees) do
        if tree:IsStanding() == false then
            tree:GrowBack()
        end
    end]]

    -- find heroes in the arena and move them back to the intermission area
    

    -- on cleanup remove all modifiers except the core ones
    for _, hero in pairs(HERO_LIST) do

        hero:GetPlayerOwner():SetMusicStatus(1,1) -- chill music

        local count = hero:GetModifierCount()
	    for i=0, count - 1 do
            local mn = hero:GetModifierNameByIndex(i)

            if CheckGlobalModifierTable(mn) ~= true then
                if hero:HasModifier(mn) then
                    hero:RemoveModifierByName(mn)
                end
            end

        end
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

    local all_units = FindUnitsInRadius(
        DOTA_TEAM_BADGUYS,
        origin,
        nil,
        5000,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false)

    if all_units ~= nil then
        for _, unit in pairs(all_units) do
            if unit:GetUnitName() == "npc_rock_techies" then
                unit:RemoveSelf()
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------

function GameSetup:HeroCheck()

    -- fix up each hero depending on what they need
    for _,hero in pairs(HERO_LIST) do

        -- general clean (find all abilities that a hero has and end their cooldowns and set hero hp to full)
        if hero:GetUnitName() ~= "npc_dota_hero_phantom_assassin" and hero:GetUnitName() ~= "npc_dota_hero_huskar" then
            hero:ReduceMana(hero:GetMaxMana())
        end

        if hero:HasModifier("q_arcane_cage_modifier") then
            hero:RemoveModifierByName("q_arcane_cage_modifier")
        end

        -- templar clean
        if hero:GetUnitName() == "npc_dota_hero_huskar" then
            hero:SetMana(hero:GetMaxMana())
            if hero:HasModifier("arcane_surge_modifier") then
                hero:RemoveModifierByName("arcane_surge_modifier")
            end
            if hero:HasModifier("e_sigil_of_power_modifier_buff") then
                hero:RemoveModifierByName("e_sigil_of_power_modifier_buff")
            end
            if hero:HasModifier("e_sigil_of_power_modifier") then
                hero:RemoveModifierByName("e_sigil_of_power_modifier")
            end
            if hero:HasModifier("q_arcane_cage_modifier") then
                hero:RemoveModifierByName("q_arcane_cage_modifier")
            end
        end

        -- heal to full
        hero:SetHealth(hero:GetMaxHealth())

        hero:GetPlayerOwner():SetMusicStatus(2,1) -- battle music

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

        -- blademaster clean
        if hero:GetUnitName() == "npc_dota_hero_juggernaut" then
            hero:AddNewModifier(hero,nil,"blademaster_death_enable_spells",{duration = -1})
            if hero:HasModifier("warlord_modifier_shouts") then
                hero:RemoveModifierByName("warlord_modifier_shouts")
            end
        end

        -- fire mage clean
        if hero:GetUnitName() == "npc_dota_hero_lina" then
            if hero:HasModifier("m1_beam_fire_rage") then
                local modifier = hero:FindModifierByNameAndCaster("m1_beam_fire_rage",hero)
                modifier:SetStackCount(0)
                hero:RemoveModifierByName("m1_beam_fire_rage")
            end
        end

        -- reset spell cooldowns
        local index = 0
        while (hero:GetAbilityByIndex(index) ~= nil) do
            hero:GetAbilityByIndex(index):EndCooldown()

            if hero:GetAbilityByIndex(index):GetMaxAbilityCharges(hero:GetAbilityByIndex(index):GetLevel()) ~= nil then
                hero:GetAbilityByIndex(index):RefreshCharges()
            end

            index = index +1
        end

    end
end
-----------------------------------------------------------------------------------------------------

