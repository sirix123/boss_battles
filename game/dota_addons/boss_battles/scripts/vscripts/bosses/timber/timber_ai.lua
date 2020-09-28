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

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

	-- saw blade references and init
	thisEntity.saw_blade = thisEntity:FindAbilityByName( "saw_blade" )
	thisEntity.saw_blade:StartCooldown(10)
	thisEntity.nMaxSawBlades = thisEntity.saw_blade:GetLevelSpecialValueFor("nMaxSawBlades", thisEntity.saw_blade:GetLevel())
	thisEntity.nCurrentSawBlades = 0
	thisEntity.return_saw_blades = thisEntity:FindAbilityByName( "return_saw_blades" )

	-- chain references and init
	thisEntity.chain = thisEntity:FindAbilityByName( "chain" )
	thisEntity.chain:StartCooldown(5)

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

	thisEntity:SetHullRadius(60)

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

	--print("current saw blades ",thisEntity.nCurrentSawBlades," max saw blades ",thisEntity.nMaxSawBlades)

	--[[ 10 second timer after max sawblades hit then return
	if thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades then
		print("setting return saw blades coolodnw")
		thisEntity.return_saw_blades:StartCooldown(10)
	end]]

	--print("mana  timber ",thisEntity:GetMana())

	-- find cloest player and attack if nothing else can be cast... add everything not ready?
	-- GetAggroTarget
	if thisEntity:GetAttackTarget() == nil then
		AttackClosestPlayer()
	end

	-- saw blade cast logic
	if thisEntity.saw_blade ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades < thisEntity.nMaxSawBlades and thisEntity.saw_blade:IsCooldownReady() then
		thisEntity.nCurrentSawBlades = thisEntity.nCurrentSawBlades + 1
		--print("casting saw baldes")
		return CastSawBlade()
	elseif thisEntity.return_saw_blades ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades and thisEntity.return_saw_blades:IsCooldownReady() then
		--print("casting return sawblades")
		thisEntity.nCurrentSawBlades = 0
		return CastReturnSawBlade()
	end

	-- chain cast logic
	if thisEntity.chain ~= nil and thisEntity.chain:IsFullyCastable() and thisEntity.chain:IsCooldownReady() then
		return CastChain()
	end

	-- fire shell logic
	if thisEntity:GetHealthPercent() < 99 and thisEntity.fire_shell ~= nil and thisEntity.fire_shell:IsFullyCastable() and thisEntity.fire_shell:IsCooldownReady() then
		--print("casting fireshell")
		return CastFireShell()
	end

	-- droid support logic
	if thisEntity:GetHealthPercent() < 85 and thisEntity.timber_droid_support ~= nil and thisEntity.timber_droid_support:IsFullyCastable() and thisEntity.timber_droid_support:IsCooldownReady() then
		return CastDroidSupport()
	end

	-- blast wave (hardmode) logic 
	if thisEntity.blast_wave ~= nil and thisEntity.blast_wave:IsFullyCastable() and thisEntity:GetHealthPercent() < 80 and thisEntity.blast_wave:IsCooldownReady() then
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
		3000,
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
		3000,
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

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.chain:entindex(),
		Queue = 0,
	})

	return 2
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
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.blast_wave:entindex(),
		Queue = 0,
	})

	return 3
end
--------------------------------------------------------------------------------