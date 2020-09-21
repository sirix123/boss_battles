electric_vortex_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.electric_vortex = thisEntity:FindAbilityByName( "electric_vortex" )

    thisEntity:SetHullRadius(60)

	thisEntity:SetContextThink( "ElectricTurretThink", ElectricTurretThink, 1 )

end
--------------------------------------------------------------------------------

function ElectricTurretThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    if thisEntity.electric_vortex:IsFullyCastable() then
        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
            AbilityIndex = thisEntity.electric_vortex:entindex(),
            Queue = false,
        })
    end

	return 5
end

--------------------------------------------------------------------------------