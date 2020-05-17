
stun_droid_ai = class({})

LinkLuaModifier( "droid_colour_modifier_blue", "bosses/timber/droid_colour_modifier_blue", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.stun_droid_zap = thisEntity:FindAbilityByName( "stun_droid_zap" )
	
	thisEntity:AddNewModifier(thisEntity, self, "droid_colour_modifier_blue", {duration = 9000})

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
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil, 
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 then
		return 0.5
	end

	-- runtowards closest player
	thisEntity:MoveToPosition( enemies[1]:GetAbsOrigin() )

	-- distance from droid to player 
	local distanceFromPlayer = ( enemies[1]:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Length2D()

    -- cast zap
	if thisEntity.stun_droid_zap:IsCooldownReady() and ( distanceFromPlayer < 200 ) then
		CastZap()
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