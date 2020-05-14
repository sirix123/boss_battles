
mine_droid_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

    thisEntity.mine_droid_laymine = thisEntity:FindAbilityByName( "mine_droid_laymine" )

	thisEntity:SetContextThink( "DroidThink", DroidThink, 0.5 )

end
--------------------------------------------------------------------------------

function DroidThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	-- find closet player
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 then
		return 0.5
	end

	-- distance from droid to timber
	thisEntity.distanceFromPlayer = ( thisEntity:GetAbsOrigin() - enemies[1]:GetAbsOrigin() ):Length2D()

	-- cast enhance
	if thisEntity.mine_droid_laymine:IsCooldownReady() and ( thisEntity.distanceFromPlayer < 400 ) then
		CastLayMine( enemies[1]:GetAbsOrigin() )
	elseif thisEntity.distanceFromPlayer > 400 then
		thisEntity:MoveToPosition( enemies[1]:GetAbsOrigin() )
	end

	return 1.0
end
--------------------------------------------------------------------------------

function CastLayMine( vTargetPos )
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            AbilityIndex = thisEntity.mine_droid_laymine:entindex(),
            Position = vTargetPos,
			Queue = false,
	})
	return 0.5
end