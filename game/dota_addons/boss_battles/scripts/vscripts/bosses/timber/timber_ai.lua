timber_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- saw blade references and init
	thisEntity.saw_blade = thisEntity:FindAbilityByName( "saw_blade" )
	thisEntity.nMaxSawBlades = thisEntity.saw_blade:GetLevelSpecialValueFor("nMaxSawBlades", thisEntity.saw_blade:GetLevel())
	thisEntity.nCurrentSawBlades = 0
	thisEntity.return_saw_blades = thisEntity:FindAbilityByName( "return_saw_blades" )

	-- chain references and init
	thisEntity.chain = thisEntity:FindAbilityByName( "chain" )



	thisEntity.fire_shell = thisEntity:FindAbilityByName( "fire_shell" )
	thisEntity.timber_droid_support = thisEntity:FindAbilityByName( "timber_droid_support" )

	thisEntity.timberSpawnTime = GameRules:GetGameTime()

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

	-- saw blade cast logic
	if thisEntity:GetHealthPercent() < 95 and thisEntity.saw_blade ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades < thisEntity.nMaxSawBlades then
		thisEntity.nCurrentSawBlades = thisEntity.nCurrentSawBlades + 1
		return CastSawBlade()
	elseif thisEntity.return_saw_blades ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades then
		thisEntity.nCurrentSawBlades = 0
		return CastReturnSawBlade()
	end

	-- chain cast logic
	-- if health < 95 and .. and ..
	-- return castchain 
	-- chain inside 
	-- find units... in cloest to furtherst 
	-- if enemy[last 2index] > 300 yards away then cast chain on them 

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
		FIND_ANY_ORDER,
		false )

    -- get a random enemy location
	thisEntity.vLocation = enemies[RandomInt(1,#enemies)]:GetAbsOrigin()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.saw_blade:entindex(),
		Position = thisEntity.vLocation,
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastReturnSawBlade()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.return_saw_blades:entindex(),
		Queue = 0,
	})
	return 10.0
end