
electric_turret_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

    thisEntity.electric_turret_electric_charge = thisEntity:FindAbilityByName( "electric_turret_electric_charge" )

    Timers:CreateTimer(1, function()

        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
            AbilityIndex = thisEntity.electric_turret_electric_charge:entindex(),
            Queue = false,
        })

        return false

    end)

	thisEntity:SetContextThink( "ElectricTurretThinker", ElectricTurretThinker, 1 )

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

	return 5
end

--------------------------------------------------------------------------------
