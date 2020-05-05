timber = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.saw_blade = thisEntity:FindAbilityByName( "saw_blade" )
	thisEntity.saw_blade_return = thisEntity:FindAbilityByName( "saw_blade_return" )
	thisEntity.chain = thisEntity:FindAbilityByName( "chain" )
	thisEntity.fire_shell = thisEntity:FindAbilityByName( "fire_shell" )
	thisEntity.timber_droid_support = thisEntity:FindAbilityByName( "timber_droid_support" )

	thisEntity.timberSpawnTime = GameRules:GetGameTime()
	thisEntity.switchToReturnSawBlade = 0

	thisEntity:SetContextThink( "Timber", TimberThink, 0.5 )
end

function TimberThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity.saw_blade ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.switchToReturnSawBlade ~= 5 then
		thisEntity.switchToReturnSawBlade = thisEntity.switchToReturnSawBlade + 1
		print("casting sawblades....")
		print(thisEntity.switchToReturnSawBlade)
		CastSawBlade()
	elseif thisEntity.switchToReturnSawBlade == 5 then
		print("casting return sawblades....")
		thisEntity.switchToReturnSawBlade = 0
		CastReturnSawBlade()
	end


	return 0.5
end
--------------------------------------------------------------------------------

function CastSawBlade()

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

    -- get closet enemy location
	thisEntity.vLocation = enemies[1]:GetAbsOrigin()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.saw_blade:entindex(),
		Position = thisEntity.vLocation,
		Queue = false,
	})
	return 2.0
end
--------------------------------------------------------------------------------

function CastReturnSawBlade()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_ABILITY_BEHAVIOR_NO_TARGET,
		AbilityIndex = thisEntity.saw_blade_return:entindex(),
		Queue = false,
	})
	return 10.0
end