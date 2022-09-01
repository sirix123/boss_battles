
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	if SOLO_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "SOLO_MODE_modifier", { duration = -1 } )
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
	if thisEntity.hPuddle ~= nil and thisEntity.hPuddle:IsFullyCastable() and enemies ~= nil and #enemies ~= 0 and thisEntity.hPuddle:IsCooldownReady() == true and thisEntity.hPuddle:IsInAbilityPhase() == false  then
		LaunchPuddle( enemies[RandomInt(1, #enemies)] )
	end


	return 0.5
end

--------------------------------------------------------------------------------

function LaunchPuddle( unit )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = thisEntity.hPuddle:entindex(),
		TargetIndex = unit:entindex(),
		Queue = false,
	})
	return 0.5
end

