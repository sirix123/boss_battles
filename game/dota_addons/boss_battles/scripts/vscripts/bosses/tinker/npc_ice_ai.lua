npc_ice_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.ice_ele_attack = thisEntity:FindAbilityByName( "ice_ele_attack_v2" )

    thisEntity:SetContextThink( "IceThinker", IceThinker, 0.5 )

end
--------------------------------------------------------------------------------

function IceThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	if #hEnemies == 0 then
		return 1
    end

    -- this AI will run away from players if too close, but won't retreat all the time if ran away recently will just attack, if too far away will get closer
    local hAttackTarget = nil
	local hApproachTarget = nil
	for _, hEnemy in pairs( hEnemies ) do
		if hEnemy ~= nil and hEnemy:IsAlive() then
			local flDist = ( hEnemy:GetOrigin() - thisEntity:GetOrigin() ):Length2D()
            if flDist < 400 then
                if ( thisEntity.fTimeOfLastRetreat and ( GameRules:GetGameTime() < thisEntity.fTimeOfLastRetreat + 3 ) ) then
					hAttackTarget = hEnemy
                else
					return Retreat( hEnemy )
				end
			end
			if flDist <= 1500 then
				hAttackTarget = hEnemy
			end
            if flDist > 1500 then
				hApproachTarget = hEnemy
			end
		end
	end

    if hAttackTarget == nil and hApproachTarget ~= nil then
		return Approach( hApproachTarget )
	end

    if hAttackTarget and thisEntity.ice_ele_attack ~= nil and thisEntity.ice_ele_attack:IsFullyCastable() then
		return CastIceEleAttack( hAttackTarget )
	end

	if hAttackTarget then
		thisEntity:FaceTowards( hAttackTarget:GetOrigin() )
		return 1.0
	end

	return 0.5
end
--------------------------------------------------------------------------------

function CastIceEleAttack( hEnemy )
	local vTargetPos = hEnemy:GetOrigin()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = vTargetPos,
		AbilityIndex = thisEntity.ice_ele_attack:entindex(),
		Queue = false,
	})

	return 3
end

--------------------------------------------------------------------------------

function Approach(unit)

    thisEntity:MoveToPosition(unit:GetOrigin())

	return 1
end

--------------------------------------------------------------------------------

function Retreat(unit)
	local vAwayFromEnemy = thisEntity:GetOrigin() - unit:GetOrigin()
	vAwayFromEnemy = vAwayFromEnemy:Normalized()
	local vMoveToPos = thisEntity:GetOrigin() + vAwayFromEnemy * thisEntity:GetIdealSpeed()

	local nAttempts = 0
	while ( ( not GridNav:CanFindPath( thisEntity:GetOrigin(), vMoveToPos ) ) and ( nAttempts < 5 ) ) do
		vMoveToPos = thisEntity:GetOrigin() + RandomVector( thisEntity:GetIdealSpeed() )
		nAttempts = nAttempts + 1
	end

    thisEntity.fTimeOfLastRetreat = GameRules:GetGameTime()

    thisEntity:MoveToPosition(vMoveToPos)

	return 1.25
end