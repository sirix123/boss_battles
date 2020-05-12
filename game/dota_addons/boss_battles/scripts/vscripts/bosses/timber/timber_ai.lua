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

	-- fire shell references and init
	thisEntity.fire_shell = thisEntity:FindAbilityByName( "fire_shell" )
	-- get fireshell referecnes for roughly how long it will cast for then use that for the return value when casting it see maxsawblades above

	-- droid support references and init
	thisEntity.timber_droid_support = thisEntity:FindAbilityByName( "timber_droid_support" )

	-- blast wave references and init
	thisEntity.blast_wave = thisEntity:FindAbilityByName( "blast_wave" )

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

	-- find cloest player and attack


	-- saw blade cast logic
	if thisEntity:GetHealthPercent() < 95 and thisEntity.saw_blade ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades < thisEntity.nMaxSawBlades then
		thisEntity.nCurrentSawBlades = thisEntity.nCurrentSawBlades + 1
		return CastSawBlade()
	elseif thisEntity.return_saw_blades ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades then
		thisEntity.nCurrentSawBlades = 0
		return CastReturnSawBlade()
	end

	-- chain cast logic
	if thisEntity:GetHealthPercent() < 95 and thisEntity.chain ~= nil and thisEntity.chain:IsFullyCastable() then
		return CastChain()
	end

	-- fire shell logic
	if thisEntity:GetHealthPercent() < 95 and thisEntity.fire_shell ~= nil and thisEntity.fire_shell:IsFullyCastable() then
		return CastFireShell()
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
		FIND_ANY_ORDER,
		false )

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
--------------------------------------------------------------------------------

function CastChain()

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

	-- get further away player or second furtherst away player
	-- need this to handle players death
	if #enemies == 1 then
		thisEntity.vLocation = enemies[1]:GetAbsOrigin()
	elseif #enemies ~= nil or #enemies > 1 then
		thisEntity.vLocation = enemies[RandomInt(( #enemies - 1) , #enemies )]:GetAbsOrigin()
	elseif #enemies == nil then
		return 0.5
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.chain:entindex(),
		Position = thisEntity.vLocation,
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastFireShell()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.fire_shell:entindex(),
		Queue = 0,
	})
	return 30.0
end
--------------------------------------------------------------------------------