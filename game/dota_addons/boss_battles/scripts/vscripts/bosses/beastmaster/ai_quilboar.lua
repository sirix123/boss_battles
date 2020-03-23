
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.hPuddle = thisEntity:FindAbilityByName( "quilboar_puddle" )

	thisEntity:SetContextThink( "Quilboar", QuilboarThink, 0.5 )

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

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end
	
	local fDelayBeforeCast = RandomFloat( 5, 15 )
	local lastPuddle = 0
	local vTargetPos = nil
	
	if GameRules:GetGameTime() > (fDelayBeforeCast + lastPuddle) then
		lastPuddle = GameRules:GetGameTime()
		if thisEntity.hPuddle ~= nil and thisEntity.hPuddle:IsFullyCastable() then
			for key, enemy in pairs(enemies) do 
				vTargetPos = enemy:GetAbsOrigin()
			end
	
			if vTargetPos ~= nil then
				return LaunchPuddle( vTargetPos )
			else
				return 0.5
			end
	
		end
	end

	return 1.0
end

--------------------------------------------------------------------------------

function LaunchPuddle( vTargetPos )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.hPuddle:entindex(),
		Position = vTargetPos,
		Queue = false,
	})
	return 0.5
end

