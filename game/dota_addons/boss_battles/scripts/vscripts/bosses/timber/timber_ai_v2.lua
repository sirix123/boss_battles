LinkLuaModifier("modifier_remove_healthbar", "core/modifier_remove_healthbar", LUA_MODIFIER_MOTION_NONE)

timber_ai_v2 = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	GameRules:SetTreeRegrowTime(800.0)

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )

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

	thisEntity.chain_map_edge = thisEntity:FindAbilityByName( "chain_map_edge" )

	thisEntity.vertical_saw_blade = thisEntity:FindAbilityByName( "vertical_saw_blade" )

	-- fire shell references and init
	thisEntity.fire_shell = thisEntity:FindAbilityByName( "fire_shell" )
	thisEntity.nMaxWaves = thisEntity.fire_shell:GetLevelSpecialValueFor("nMaxWaves", thisEntity.fire_shell:GetLevel())
	thisEntity.fTimeBetweenWaves = thisEntity.fire_shell:GetLevelSpecialValueFor("fTimeBetweenWaves", thisEntity.fire_shell:GetLevel())

	-- droid support references and init
	thisEntity.timber_droid_support = thisEntity:FindAbilityByName( "timber_droid_support" )

	-- blast wave references and init
	thisEntity.blast_wave = thisEntity:FindAbilityByName( "blast_wave_v2" )

	thisEntity.timberSpawnTime = GameRules:GetGameTime()

	-- handle level up
	thisEntity.levelTracker = 0
	thisEntity.state = 1

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

	--print("thisEntity.state ",thisEntity.state)

	-- state change handler
	if thisEntity:GetHealthPercent() < 50 and thisEntity.chain_map_edge:IsCooldownReady() == true then
		thisEntity.state = 2
	elseif thisEntity.state == 2 and FindUnitsClose() == true then
		thisEntity:RemoveModifierByName("modifier_rooted")
		thisEntity.state = 1
	end

	if thisEntity.state == 1 then

		-- find cloest player and attack if nothing else can be cast... add everything not ready?
		-- GetAggroTarget
		--if thisEntity:GetAttackTarget() == nil then
			--AttackClosestPlayer()
		--end

		-- saw blade cast logic
		if thisEntity.saw_blade:IsInAbilityPhase() == false and thisEntity.saw_blade ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades < thisEntity.nMaxSawBlades and thisEntity.saw_blade:IsCooldownReady() then
			thisEntity.nCurrentSawBlades = thisEntity.nCurrentSawBlades + 1
			--print("casting saw baldes")
			return CastSawBlade()
		elseif thisEntity.return_saw_blades ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades and thisEntity.return_saw_blades:IsCooldownReady() then
			--print("casting return sawblades")
			thisEntity.nCurrentSawBlades = 0
			return CastReturnSawBlade()
		end

		-- chain cast logic
		if thisEntity.chain ~= nil and thisEntity.chain:IsFullyCastable() and thisEntity.chain:IsCooldownReady() and thisEntity.chain:IsInAbilityPhase() then
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
		if thisEntity.blast_wave ~= nil and thisEntity.blast_wave:IsFullyCastable() and thisEntity:GetHealthPercent() < 95 and thisEntity.blast_wave:IsCooldownReady() then
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

		if thisEntity:GetMana() >= 99 then
			thisEntity.fire_shell:EndCooldown()
		end
	end

	if thisEntity.state == 2 then
		--print("in phase 2")
		if thisEntity.chain_map_edge ~= nil and thisEntity.chain_map_edge:IsFullyCastable() and thisEntity.chain_map_edge:IsCooldownReady() and thisEntity.chain_map_edge:IsInAbilityPhase() == false then
			--print("map edge")
			return CastChainMapEdge()
		end

		if thisEntity.vertical_saw_blade ~= nil and thisEntity.vertical_saw_blade:IsFullyCastable() and thisEntity.vertical_saw_blade:IsCooldownReady() and thisEntity.vertical_saw_blade:IsInAbilityPhase() == false then
			return CastVerticalSawBlade()
		end
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

function FindUnitsClose()
	-- find closet player
	local enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		400,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 or enemies == nil then
		return false
	else
		return true
	end
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
	return 3
end
--------------------------------------------------------------------------------

function CastChain()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.chain:entindex(),
		Queue = 0,
	})

	return 4
end
--------------------------------------------------------------------------------

function CastChainMapEdge()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.chain_map_edge:entindex(),
		Queue = 0,
	})

	return 1.5
end
--------------------------------------------------------------------------------

function CastVerticalSawBlade()

	-- root self in place
	thisEntity:AddNewModifier( nil, nil, "modifier_rooted", { duration = -1 })

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.vertical_saw_blade:entindex(),
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
	return (thisEntity.nMaxWaves * thisEntity.fTimeBetweenWaves) + 4
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