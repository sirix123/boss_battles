
stun_droid_ai = class({})

LinkLuaModifier( "droid_colour_modifier_blue", "bosses/timber/droid_colour_modifier_blue", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.stun_droid_zap = thisEntity:FindAbilityByName( "stun_droid_zap" )

	--thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	
	thisEntity:AddNewModifier(thisEntity, self, "droid_colour_modifier_blue", {duration = 9000})

	thisEntity.found_player = false

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

	-- find closet player
	if thisEntity.found_player == false then
		thisEntity.enemies = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity:GetAbsOrigin(),
			nil, 
			5000,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			false )

		thisEntity.found_player = true
	end

	if thisEntity.enemies ~= nil then

		-- runtowards closest player
		thisEntity:MoveToPosition( thisEntity.enemies[1]:GetAbsOrigin() )

		-- distance from droid to player
		thisEntity.distanceFromPlayer = ( thisEntity.enemies[1]:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Length2D()

		-- cast zap
		if thisEntity.stun_droid_zap:IsCooldownReady() and ( thisEntity.distanceFromPlayer < 200 ) then
			CastZap()
		end
	else
		thisEntity.found_player = false
	end

	return 1.0
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