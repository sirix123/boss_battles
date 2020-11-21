
stun_droid_ai = class({})

LinkLuaModifier( "droid_colour_modifier_blue", "bosses/timber/droid_colour_modifier_blue", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "blue_droid_death_modifier", "bosses/timber/blue_droid_death_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_flying_movement_ground", "core/modifier_flying_movement_ground", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.stun_droid_zap = thisEntity:FindAbilityByName( "stun_droid_zap" )

	--thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:AddNewModifier(thisEntity, self, "droid_colour_modifier_blue", {duration = 9000})
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:AddNewModifier( nil, nil, "modifier_flying_movement_ground", { duration = -1 })
	thisEntity:AddNewModifier( nil, nil, "blue_droid_death_modifier", { duration = -1 })

	thisEntity.target = nil

	thisEntity:SetHullRadius(60)

	thisEntity:SetContextThink( "DroidThink", DroidThink, 0.5 )

end
--------------------------------------------------------------------------------

function DroidThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity.target == nil then
		return FindEnemy()
	end

	--if thisEntity.approach_target == nil then
		ApproachTarget()
	--end

	if ( thisEntity:GetAbsOrigin() - thisEntity.approach_target:GetAbsOrigin() ):Length2D() < 200 and thisEntity.stun_droid_zap:IsCooldownReady() and thisEntity.stun_droid_zap:IsInAbilityPhase() == false then
		thisEntity:ForceKill(false)
	end

	return 0.5
end
--------------------------------------------------------------------------------

function FindEnemy()
	local enemies = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetAbsOrigin(),
        nil,
        5000,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

	if #enemies == 0 or enemies == nil then
		return 0.5
	end

	thisEntity.target = enemies[RandomInt(1,#enemies)]

	return 1
end
--------------------------------------------------------------------------------

function ApproachTarget()

	thisEntity.approach_target = thisEntity.target
	thisEntity:MoveToPosition(thisEntity.approach_target:GetOrigin())

	--return 1
end

--------------------------------------------------------------------------------

function CastZap()
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = thisEntity.stun_droid_zap:entindex(),
			Queue = false,
	})
	return 0.5
end