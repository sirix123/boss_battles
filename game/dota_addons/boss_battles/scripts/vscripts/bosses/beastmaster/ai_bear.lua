
--[[ bosses/beastmaster/ai_bear.lua ]]

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.hClaw = thisEntity:FindAbilityByName( "bear_claw" )
	thisEntity.hBloodlust = thisEntity:FindAbilityByName( "bear_bloodlust" )

	thisEntity:SetContextThink( "BearThink", BearThink, 0.5 )

end

--------------------------------------------------------------------------------

function BearThink()
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

	local bHasModifier = nil

	-- search each enemy on the map for the beastmaster mark 
	for key, enemy in pairs(enemies) do 
		bHasModifier = enemy:HasModifier("beastmaster_mark_modifier")

		-- if a player has the mark send bear to attack and cast claw
		if enemy:HasModifier("beastmaster_mark_modifier") then
			beastmasterMarkTarget = enemy
			thisEntity:MoveToTargetToAttack(beastmasterMarkTarget)
			if thisEntity.hClaw ~= nil and thisEntity.hClaw:IsFullyCastable() then
				CastClaw(beastmasterMarkTarget)
			end
		end
	end

	-- cast bloodlust on cd no matter what
	-- remove bloodlust stacks from bear
	if thisEntity.hBloodlust ~= nil and thisEntity.hBloodlust:IsCooldownReady() then
		return CastBloodlust()
	end

	return 1.0
end

--------------------------------------------------------------------------------

function CastClaw(beastmasterMarkTarget)
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = beastmasterMarkTarget:entindex(),
			AbilityIndex = thisEntity.hClaw:entindex(),
			Queue = false,
	})

	return 0.5
end

function CastBloodlust()
		ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hBloodlust:entindex(),
		Queue = false,
	})
	return 0.5
end

