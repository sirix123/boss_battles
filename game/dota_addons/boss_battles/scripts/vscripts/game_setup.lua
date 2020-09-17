if GameSetup == nil then
    GameSetup = class({})
end

LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_respawn", "core/modifier_respawn", LUA_MODIFIER_MOTION_NONE )

function GameSetup:init()
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

    GameRules:SetHeroRespawnEnabled(false)

    GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1800 )-- killed:SetTimeUntilRespawn(new_respawn_time)

    --listen to game state event
    -- events here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self) -- valve engine event
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self) -- npc_spawned is a valve engine event
    --ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'PlayerPickHero'), self) -- dota_player_pick_hero is a valve engine event
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self) --
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'OnEntityHurt'), self)

    -- setup listeners
    PlayerManager:SetUpMouseUpdater()
    PlayerManager:SetUpMovement()

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then

        Filters:Activate(GameSetup, self)

        local mode = GameRules:GetGameModeEntity()
        mode:SetExecuteOrderFilter(Dynamic_Wrap(GameSetup, "ExecuteOrderFilter" ), GameSetup)
        mode:SetFogOfWarDisabled(true)

    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        -- spawn testing stuff
        self:SpawnTestingStuff()

        -- setup listeners
        --self:SetupListeners()

    end

end
--------------------------------------------------------------------------------------------------
function GameSetup:SetupListeners()

    local data =
    {
        1234,
    }
    CustomNetTables:SetTableValue("heroes", "index_1", data)
    --CustomNetTables:SetTableValue("heroes", "index_" .. data.entity_index, data)
end
--------------------------------------------------------------------------------------------------

function GameSetup:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)

    if npc:IsRealHero() and npc.bFirstSpawned == nil then
        npc.bFirstSpawned = true

        npc:AddNewModifier( npc,  nil, "movement_modifier_thinker", { } )
        npc:AddNewModifier( npc,  nil, "remove_attack_modifier", { } )

        npc:Initialize(keys)

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

end

--------------------------------------------------------------------------------------------------

-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Custom_Nettables

--Sets a the data for a custom nettable called dps_meter
function UpdateDamageMeter()
    dpsTable = {}
    local heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        heroDps = {}
        heroDps.hero = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID())
        -- heroDps.dps = DpsInLastMinute(hero:GetEntityIndex()) -- todo: trim the float to 2 digits
        heroDps.dps = string.format("%.2f", DpsInLastMinute(hero:GetEntityIndex()) )
        dpsTable[#dpsTable+1] = heroDps
    end
    CustomNetTables:SetTableValue("dps_meter", "key", dpsTable)
end

--Track damage done by adding to a global var each time an entity gets hurts
_G.TotalDamageDone = {}
function GameSetup:OnEntityHurt(keys)
    -- Store the dmg done in a table to maintain history. 
    -- StoreDamageDone(keys)

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

    
    --Show dmg done text above victim using particles to display text in UI
    if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
        -- The ability/item used to damage, or nil if not damaged by an item/ability
        local damagingAbility = nil
        local entityVictim = EntIndexToHScript(keys.entindex_killed)

        if keys.entindex_inflictor ~= nil then
            damagingAbility = EntIndexToHScript(keys.entindex_inflictor)
        end

        local word_length = string.len(tostring(math.floor(keys.damage)))

        local color =  Vector(250, 70, 70)
        local effect_cast = ParticleManager:CreateParticle("particles/msg_fx/msg_damage.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, entityVictim:GetAbsOrigin() + Vector(-10,-20,0))
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, keys.damage, 0))
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(math.max(1, keys.damage / 10), word_length, 0))
        ParticleManager:SetParticleControl(effect_cast, 3, color)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

end

function DpsInLastMinute(attackerEntity)
    local currentTime = GameRules:GetGameTime()

    local dmg = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.attackerEntity == attackerEntity then

            local dt = currentTime - dmgEntry.timeOf
            if ( dt < 60 ) then
                dmg = dmg + dmgEntry.dmg
            end
        end 
    end
    return dmg / 60
end

-- Track damage done by adding the attacker, victim and damage into a globalVar table.
_G.DamageTable = {}
function StoreDamageDone(keys)
    local data = {}
    data["dmg"] = keys.damage
    data["dmgBits"] = keys.damagebits 
    data["victimEntity"] = keys.entindex_killed
    data["attackerEntity"] = keys.entindex_attacker
    data["victimName"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
    data["attackerName"] = EntIndexToHScript(keys.entindex_attacker):GetUnitName()
    data["timeOf"] = GameRules:GetGameTime()

    --TEST: Not sure this is correct...
    table.insert(_G.DamageTable, data)

    --NET TABLES EXAMPLE:
    --Stopped using net tables as I don't need to post this event each time the dmgDone is updated, just keep track of it
    --print("setting CustomNetTables dmg_done")
    --CustomNetTables:SetTableValue("dmg_done", tostring(entindex_attacker), _G.DamageTotalsTable)
end

function GetDamageDone(attackerEntity)
    local sum = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.attackerEntity == attackerEntity then
            sum = sum + dmgEntry.dmg
        end 
    end
    return sum
end

function GetDamageTaken(victimEntity)
    local sum = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.victimEntity == victimEntity  then
            sum = sum + dmgEntry.dmg
        end 
    end
    return sum
end

--TODO: implement this elsewhere...
function GetClassName(unitName)
    --TODO: implement this the current classes...
    return "ice_mage"
end

--------------------------------------------------------------------------------------------------

-- handles tping players to the boss arena and spawning the boss
function GameSetup:Test123() -- called from trigger lua file for activators (ready_up)
    --beastmaster_playerspawn
    --beastmaster_bossspawn
    local heroes = HeroList:GetAllHeroes()
    local beastmasterPlaySpawn = Entities:FindByName(nil, "beastmaster_playerspawn"):GetAbsOrigin()
    local beastmasterBossSpawn = Entities:FindByName(nil, "beastmaster_bossspawn"):GetAbsOrigin()

    for _,hero in pairs(heroes) do
        hero:SetMana(0)
        FindClearSpaceForUnit(hero, beastmasterPlaySpawn, true)
    end

    Timers:CreateTimer(2.0, function()
        CreateUnitByName("npc_beastmaster", beastmasterBossSpawn, true, nil, nil, DOTA_TEAM_BADGUYS)
    end)

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnHeroKilled(killed)
    killed:SetTimeUntilRespawn(5)

    --[[if self.WIN_CONDITION.type == "AMETHYSTS" then
        killed.lifes = killed.lifes - 1

        local new_respawn_time = nil

        if killed.lifes <= 0 then
            new_respawn_time = 999
        else
            new_respawn_time = self.BASE_RESPAWN_TIME + self.RESPAWN_TIME_PER_DEATH * (PlayerResource:GetDeaths(killed:GetPlayerID()) - 1)
            if new_respawn_time > self.MAX_RESPAWN_TIME then 
                new_respawn_time = self.MAX_RESPAWN_TIME 
            end
        end

        killed:SetTimeUntilRespawn(new_respawn_time)
    end]]
end
