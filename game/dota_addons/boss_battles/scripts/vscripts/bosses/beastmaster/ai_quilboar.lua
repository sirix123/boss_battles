
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.hPuddle = thisEntity:FindAbilityByName( "quilboar_puddle" )

	thisEntity.vTargetPos = nil

	local randomStartTime = RandomInt(1,4)

	thisEntity:SetContextThink( "Quilboar", QuilboarThink, randomStartTime )

	thisEntity:SetHullRadius(30)

end

--------------------------------------------------------------------------------

function QuilboarThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	local enemies = {}

	enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		2500,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	-- find all players in the entire map
	if thisEntity.hPuddle ~= nil and thisEntity.hPuddle:IsFullyCastable() and enemies ~= nil and enemies ~= 0 then
		LaunchPuddle( )
	end


	return 0.5
end

--------------------------------------------------------------------------------

function LaunchPuddle( )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hPuddle:entindex(),
		Queue = false,
	})
	return 0.5
end

