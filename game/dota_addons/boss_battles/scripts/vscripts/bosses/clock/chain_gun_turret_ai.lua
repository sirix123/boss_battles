
chain_gun_turret_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

    thisEntity.chain_gun_shoot = thisEntity:FindAbilityByName( "chain_gun_shoot" )

    Timers:CreateTimer(2, function()

        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
            AbilityIndex = thisEntity.chain_gun_shoot:entindex(),
            Queue = false,
        })

        return false

    end)

	thisEntity:SetContextThink( "ChainGunThinker", ChainGunThinker, 1 )

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
