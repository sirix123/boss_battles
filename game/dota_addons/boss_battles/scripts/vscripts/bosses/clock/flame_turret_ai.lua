
flame_turret_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.fire_turret_flame = thisEntity:FindAbilityByName( "fire_turret_flame" )

	thisEntity:SetContextThink( "FlameTurretThink", FlameTurretThink, 1 )

end
--------------------------------------------------------------------------------

function FlameTurretThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.fire_turret_flame:entindex(),
        Queue = false,
    })

	return 5
end

--------------------------------------------------------------------------------
