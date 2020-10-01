
chain_gun_turret_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

    thisEntity.chain_gun_shoot = thisEntity:FindAbilityByName( "chain_gun_shoot" )

	local friendlies = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetAbsOrigin(),
        nil,
        5000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    for _, friend in pairs(friendlies) do
        if friend:GetUnitName() == "npc_clock"  then
			if friend:HasModifier("furnace_modifier_1") then
				thisEntity:AddNewModifier( nil, nil, "electric_turret_minion_buff", { duration = -1 } )
			end
        end
    end

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
