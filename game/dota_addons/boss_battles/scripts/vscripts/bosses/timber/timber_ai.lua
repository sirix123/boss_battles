timber_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	-- saw blade references and init
	thisEntity.saw_blade = thisEntity:FindAbilityByName( "saw_blade" )
	thisEntity.nMaxSawBlades = thisEntity.saw_blade:GetLevelSpecialValueFor("nMaxSawBlades", thisEntity.saw_blade:GetLevel())
	thisEntity.nCurrentSawBlades = 0
	thisEntity.return_saw_blades = thisEntity:FindAbilityByName( "return_saw_blades" )

	-- chain references and init
	thisEntity.chain = thisEntity:FindAbilityByName( "chain" )

	-- fire shell references and init
	thisEntity.fire_shell = thisEntity:FindAbilityByName( "fire_shell" )
	thisEntity.nMaxWaves = thisEntity.fire_shell:GetLevelSpecialValueFor("nMaxWaves", thisEntity.fire_shell:GetLevel())
	thisEntity.fTimeBetweenWaves = thisEntity.fire_shell:GetLevelSpecialValueFor("fTimeBetweenWaves", thisEntity.fire_shell:GetLevel())

	-- droid support references and init
	thisEntity.timber_droid_support = thisEntity:FindAbilityByName( "timber_droid_support" )

	-- blast wave references and init
	thisEntity.blast_wave = thisEntity:FindAbilityByName( "blast_wave" )

	thisEntity.timberSpawnTime = GameRules:GetGameTime()

	-- handle level up
	thisEntity.levelTracker = 0

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

	-- 10 second timer after max sawblades hit then return
	if thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades then
		thisEntity.return_saw_blades:StartCooldown(10)
	end

	-- find cloest player and attack if nothing else can be cast... add everything not ready?
	-- GetAggroTarget
	if thisEntity:GetAttackTarget() == nil then
		AttackClosestPlayer()
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
	if thisEntity:GetHealthPercent() < 95 and thisEntity.chain ~= nil and thisEntity.chain:IsFullyCastable() then
		return CastChain()
	end

	-- fire shell logic
	if thisEntity:GetHealthPercent() < 95 and thisEntity.fire_shell ~= nil and thisEntity.fire_shell:IsFullyCastable() then
		return CastFireShell()
	end

	-- droid support logic
	if thisEntity:GetHealthPercent() < 75 and thisEntity.timber_droid_support ~= nil and thisEntity.timber_droid_support:IsFullyCastable() then
		return CastDroidSupport()
	end

	-- blast wave (hardmode) logic 
	if thisEntity.blast_wave ~= nil and thisEntity.blast_wave:IsFullyCastable() and thisEntity:GetHealthPercent() < 85 then
		return CastBlastWave()
	end

	-- level up abilities at certain hp %ers
	if thisEntity:GetHealthPercent() < 99 and thisEntity.levelTracker == 0 then
		LevelUpAbilities() -- forces all abilities to be level 1
	end
	if thisEntity:GetHealthPercent() < 80 and thisEntity.levelTracker == 1 then
		LevelUpAbilities() -- forces all abilities to be level 2
	end
	if thisEntity:GetHealthPercent() < 60 and thisEntity.levelTracker == 2 then
		LevelUpAbilities() -- forces all abilities to be level 3
	end
	if thisEntity:GetHealthPercent() < 40 and thisEntity.levelTracker == 3 then
		LevelUpAbilities() -- forces all abilities to be level 4
	end

	return 0.5
end
--------------------------------------------------------------------------------

function HardModeCheck()

	local trees = GridNav:GetAllTreesAroundPoint( thisEntity:GetAbsOrigin(), 10000, true )

	if #trees < 1 then
		return true
	else
		return false
	end
end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	thisEntity.levelTracker = thisEntity.levelTracker + 1

	thisEntity.saw_blade:SetLevel(thisEntity.levelTracker)
	thisEntity.chain:SetLevel(thisEntity.levelTracker)
	thisEntity.fire_shell:SetLevel(thisEntity.levelTracker)
	thisEntity.timber_droid_support:SetLevel(thisEntity.levelTracker)
	thisEntity.blast_wave:SetLevel(thisEntity.levelTracker)

end
--------------------------------------------------------------------------------

function AttackClosestPlayer()
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

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		TargetIndex = enemies[1]:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------

function CastSawBlade()

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

	if #enemies == 0 or enemies == nil then
		return 0.5
	end

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
	return 1
end
--------------------------------------------------------------------------------

function CastFireShell()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.fire_shell:entindex(),
		Queue = 0,
	})
	return (thisEntity.nMaxWaves * thisEntity.fTimeBetweenWaves) + 2
end
--------------------------------------------------------------------------------

function CastDroidSupport()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.timber_droid_support:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastBlastWave()
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

	if #enemies == 0 or enemies == nil then
		return 0.5
	else
		local randomEnemy = RandomInt(1,#enemies)
		thisEntity.vLocation = enemies[randomEnemy]:GetAbsOrigin()
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.blast_wave:entindex(),
		Position = thisEntity.vLocation,
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------