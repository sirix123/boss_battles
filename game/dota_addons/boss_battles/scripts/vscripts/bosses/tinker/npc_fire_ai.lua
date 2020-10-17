npc_fire_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.fire_ele_attack = thisEntity:FindAbilityByName( "fire_ele_attack" )

    thisEntity:SetContextThink( "FireThinker", FireThinker, 0.1 )

end
--------------------------------------------------------------------------------

function FireThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    -- find all units
    local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	if #hEnemies == 0 then
		return 1
	end

    local hAttackTarget = nil
	local hApproachTarget = nil
    for _, hEnemy in pairs( hEnemies ) do
        if hEnemy ~= nil and hEnemy:IsAlive() then
            --print("found enemy")
			local flDist = ( hEnemy:GetOrigin() - thisEntity:GetOrigin() ):Length2D()
            if flDist < thisEntity.fire_ele_attack:GetCastRange(thisEntity:GetAbsOrigin(), hEnemy) then
                --print("casting")
				hAttackTarget = hEnemy
			end
            if flDist > thisEntity.fire_ele_attack:GetCastRange(thisEntity:GetAbsOrigin(), hEnemy) then
                --print("enemy fasr away")
				hAttackTarget = hEnemy
			end

			if flDist < thisEntity.fire_ele_attack:GetCastRange(thisEntity:GetAbsOrigin(), hEnemy) then
                --print("enemy fasr away")
				hApproachTarget = hEnemy
			end

		end
	end

	if hAttackTarget == nil and hApproachTarget ~= nil then
		return Approach( hApproachTarget )
	end

    if hAttackTarget and  thisEntity.fire_ele_attack ~= nil and  thisEntity.fire_ele_attack:IsFullyCastable() then
		return CastFireEleAttack( hAttackTarget )
	end

	if hAttackTarget then
		thisEntity:FaceTowards( hAttackTarget:GetOrigin() )
		return 1.0
	end

	return 0.5
end

function CastFireEleAttack( hEnemy )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex  = hEnemy:entindex(),
		AbilityIndex = thisEntity.fire_ele_attack:entindex(),
		Queue = false,
	})

	return 2
end

function Approach(unit)

    thisEntity:MoveToPosition(unit:GetOrigin())

	return 1
end

