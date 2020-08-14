if GameSetup == nil then
    GameSetup = class({})
end

LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )

function GameSetup:init()
    GameRules:EnableCustomGameSetupAutoLaunch(false)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetHeroSelectionTime(30)
    GameRules:SetStrategyTime(0)
    GameRules:SetPreGameTime(1)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPostGameTime(5)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 2)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 2)

    GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1800 )

    --listen to game state event
    -- events here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self) -- valve engine event
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self) -- npc_spawned is a valve engine event
    ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'PlayerPickHero'), self) -- dota_player_pick_hero is a valve engine event

end
--------------------------------------------------------------------------------------------------

function GameSetup:OnStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then

        Filters:Activate(GameSetup, self)

        local mode = GameRules:GetGameModeEntity()
        mode:SetExecuteOrderFilter(Dynamic_Wrap(GameSetup, "ExecuteOrderFilter" ), GameSetup)

        PlayerManager:SetUpMovement()
        PlayerManager:SetUpMouseUpdater()

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

        -- level up abilities for all heroes to level 1
        if npc:GetUnitName() == "npc_dota_hero_crystal_maiden" or npc:GetUnitName() == "npc_dota_hero_windrunner" then
          local index = 0
          while (npc:GetAbilityByIndex(index) ~= nil) do
            npc:GetAbilityByIndex(index):SetLevel(1)
            index = index +1
          end
        end
    end
end
--------------------------------------------------------------------------------------------------

function GameSetup:PlayerPickHero(keys)

    -- flame turrets for right side of the map, need to change facing vector
    local flame_turret_1 = CreateUnitByName("npc_flame_turret", Vector(768,1504,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_1:SetForwardVector(Vector(0,-1, flame_turret_1.z ))

    local flame_turret_2 = CreateUnitByName("npc_flame_turret", Vector(1346,1572,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_2:SetForwardVector(Vector(0,-1, flame_turret_2.z ))

    local flame_turret_3 = CreateUnitByName("npc_flame_turret", Vector(1075,-1531,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_3:SetForwardVector(Vector(0,1, flame_turret_3.z ))

    -- target dummy
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-779,1309,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(8112,6733,256), true, nil, nil, DOTA_TEAM_BADGUYS)

end
--------------------------------------------------------------------------------------------------