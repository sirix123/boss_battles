clock_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- summon furnace
	local furnace_1 = Entities:FindByName(nil, "furnace_1"):GetAbsOrigin()
	local furnace_2 = Entities:FindByName(nil, "furnace_2"):GetAbsOrigin()
	local furnace_3 = Entities:FindByName(nil, "furnace_3"):GetAbsOrigin()
	local furnace_4 = Entities:FindByName(nil, "furnace_4"):GetAbsOrigin()
	CreateUnitByName("furnace", furnace_1, true, nil, nil, DOTA_TEAM_BADGUYS)
	CreateUnitByName("furnace", furnace_2, true, nil, nil, DOTA_TEAM_BADGUYS)
	CreateUnitByName("furnace", furnace_3, true, nil, nil, DOTA_TEAM_BADGUYS)
	CreateUnitByName("furnace", furnace_4, true, nil, nil, DOTA_TEAM_BADGUYS)

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	-- droids + turrets
	thisEntity.summon_flame_turret = thisEntity:FindAbilityByName( "summon_flame_turret" )
	thisEntity.summon_flame_turret:StartCooldown(thisEntity.summon_flame_turret:GetCooldown(thisEntity.summon_flame_turret:GetLevel()))
	thisEntity.summon_chain_gun_turret = thisEntity:FindAbilityByName( "summon_chain_gun_turret" )
	thisEntity.summon_chain_gun_turret:StartCooldown(thisEntity.summon_chain_gun_turret:GetCooldown(thisEntity.summon_chain_gun_turret:GetLevel()))
	thisEntity.summon_furnace_droid = thisEntity:FindAbilityByName( "summon_furnace_droid" )
	thisEntity.summon_furnace_droid:StartCooldown(thisEntity.summon_furnace_droid:GetCooldown(thisEntity.summon_furnace_droid:GetLevel()))

	-- electric turret
	thisEntity.summon_electric_turret = thisEntity:FindAbilityByName( "summon_electric_turret" )
	--thisEntity.summon_electric_turret:StartCooldown(thisEntity.summon_electric_turret:GetCooldown(thisEntity.summon_electric_turret:GetLevel()))

	-- hook
	thisEntity.hookshot = thisEntity:FindAbilityByName( "hookshot" )
	thisEntity.return_hookshot = thisEntity:FindAbilityByName( "return_hookshot" )
	thisEntity.hookshotStayInFurnaceDuration = 20
	thisEntity.hookshot:StartCooldown(thisEntity.hookshot:GetCooldown(thisEntity.hookshot:GetLevel()))

	-- salvo
	thisEntity.missile_salvo = thisEntity:FindAbilityByName( "missile_salvo" )
	thisEntity.nMaxWaves = thisEntity.missile_salvo:GetLevelSpecialValueFor("nMaxWaves", thisEntity.missile_salvo:GetLevel())
	thisEntity.flTimeBetweenWaves = thisEntity.missile_salvo:GetLevelSpecialValueFor("flTimeBetweenWaves", thisEntity.missile_salvo:GetLevel())

	-- start misile salvo cd so he doesn't cast it on spawn
	thisEntity.missile_salvo:StartCooldown(thisEntity.missile_salvo:GetCooldown(thisEntity.missile_salvo:GetLevel()))

	-- chooking gas
	thisEntity.choking_gas = thisEntity:FindAbilityByName( "choking_gas" )
	thisEntity.choking_gas:StartCooldown(thisEntity.choking_gas:GetCooldown(thisEntity.choking_gas:GetLevel()))

	-- invul debuff
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

	-- furnace furnace assistant
	thisEntity.SpawnFurnaceAssistant = true

	thisEntity.clockSpawnTime = GameRules:GetGameTime()

	-- handle level up
	thisEntity.levelTracker = 1

	-- states
	thisEntity.STATE = 0
	thisEntity.NOT_BURN_PHASE = 0
	thisEntity.BURN_PHASE = 1

	-- hitbox/hullraidus
	thisEntity:SetHullRadius(50)

	thisEntity:SetContextThink( "Clock", ClockThink, 0.5 )
end

function ClockThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	local nActiveFurnaces = FindFurnacesWithActivatedBuff()

	-- check how many furnaces are active so we can level up abilities
	if nActiveFurnaces == 1 and thisEntity.levelTracker == 1 then
		if thisEntity.SpawnFurnaceAssistant == true then
			thisEntity.SpawnFurnaceAssistant = false
			CreateUnitByName("npc_assistant", Vector(7414,7809,256), true, nil, nil, DOTA_TEAM_BADGUYS) -- summon furnace assistant
		end
	end
	if nActiveFurnaces == 2 and thisEntity.levelTracker == 2 then
		LevelUpAbilities() -- forces all abilities to be level 2
	end
	if nActiveFurnaces == 3 and thisEntity.levelTracker == 3 then
		LevelUpAbilities() -- forces all abilities to be level 3
	end
	if nActiveFurnaces == 4 and thisEntity.levelTracker == 3 then
		LevelUpAbilities() -- forces all abilities to be level 4
	end

	--print(thisEntity.STATE)

	-- apply invul every loop, remove invul explictly in furnace below modifier
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

	if thisEntity.STATE == thisEntity.BURN_PHASE then
		if thisEntity:HasModifier("inside_furnace_modifier") == false then -- this applied in furnace AI
			if thisEntity.return_hookshot:IsFullyCastable() then
				thisEntity.STATE = thisEntity.NOT_BURN_PHASE
				return CastReturnHookshot()
			end
		else -- if clock has the furnace modiifer then remove invul, wait, then hook back

			-- remove invul
			thisEntity:RemoveModifierByName("modifier_invulnerable")

			-- play sound affect
			thisEntity:EmitSound("rattletrap_ratt_anger_03")

			-- wait x seconds then returnhook
			Timers:CreateTimer(thisEntity.hookshotStayInFurnaceDuration, function()
				return false
			end)

			-- cast return hookshot
			if thisEntity.return_hookshot:IsFullyCastable() then
				thisEntity.STATE = thisEntity.NOT_BURN_PHASE
				return CastReturnHookshot()
			end
		end
	end

	if thisEntity.STATE == thisEntity.NOT_BURN_PHASE then

		--hook shot cast on x mana, gets mana from furnace droids
		if thisEntity.hookshot:IsFullyCastable() then
			thisEntity.STATE = thisEntity.BURN_PHASE
			-- i dont want to large return values here cause then the invul won't drop straight away, start cooldown works better
			thisEntity.return_hookshot:StartCooldown(thisEntity.return_hookshot:GetCooldown(thisEntity.return_hookshot:GetLevel()))
			return CastHookshot()
		end

		-- check if electric turrets exist on map if there are none, summon more
		if thisEntity.summon_electric_turret:IsFullyCastable() and FindNumOfElectricTurrets() == 0 then
			return CastSummonElectricTurret()
		end

		if thisEntity.summon_flame_turret:IsFullyCastable() then
			return CastSummonFlameTurret()
		end

		if thisEntity.summon_furnace_droid:IsFullyCastable() then
			return CastSummonFurnaceDroid()
		end

		if thisEntity.summon_chain_gun_turret:IsFullyCastable() then
			return CastChainGunTurret()
		end

		if thisEntity.missile_salvo:IsFullyCastable() then
			return CastMissileSalvo()
		end

		if thisEntity.choking_gas:IsFullyCastable() then
			return CastChokingGas()
		end

	end

	return 0.5
end
--------------------------------------------------------------------------------

function HardModeCheck()


end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	thisEntity.levelTracker = thisEntity.levelTracker + 1

	thisEntity.summon_flame_turret:SetLevel(thisEntity.levelTracker)
	thisEntity.summon_chain_gun_turret:SetLevel(thisEntity.levelTracker)
	thisEntity.summon_furnace_droid:SetLevel(thisEntity.levelTracker)
	thisEntity.summon_electric_turret:SetLevel(thisEntity.levelTracker)
	thisEntity.hookshot:SetLevel(thisEntity.levelTracker)
	thisEntity.return_hookshot:SetLevel(thisEntity.levelTracker)
	thisEntity.choking_gas:SetLevel(thisEntity.levelTracker)

end
--------------------------------------------------------------------------------

function FindRandomPlayer()
	-- find closet player
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 then
		return 0
	end

	local i = RandomInt(1,#enemies)

	return enemies[i]
end
--------------------------------------------------------------------------------

function FindNumOfElectricTurrets()
	-- find closet player
	local units = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )

	if #units == 0 then
		return 0
	end

	local nElecTurrets = 0
	for _, unit in pairs(units) do
		if unit:GetUnitName() == "electric_turret" then
			nElecTurrets = nElecTurrets + 1
		end
	end

	return nElecTurrets
end
--------------------------------------------------------------------------------

function FindFurnacesWithActivatedBuff()
	-- find closet player
	local units = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #units == 0 then
		--print("are we returning 0?")
		return 0
	end

	thisEntity.nActivatedFurnaces = 0
	for _, unit in pairs(units) do
		if unit:GetUnitName() == "furnace" then
			thisEntity.furnace = unit
			if thisEntity.furnace:HasModifier("inside_furnace_modifier") == true then
				thisEntity.nActivatedFurnaces = thisEntity.nActivatedFurnaces + 1
			end
		end
	end

	return thisEntity.nActivatedFurnaces
end
--------------------------------------------------------------------------------

function CastHookshot()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hookshot:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------

function CastReturnHookshot()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.return_hookshot:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------

function CastSummonFlameTurret()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_flame_turret:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastChainGunTurret()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_chain_gun_turret:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastSummonFurnaceDroid()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_furnace_droid:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastSummonElectricTurret()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_electric_turret:entindex(),
		Queue = 0,
	})
	return 2
end
--------------------------------------------------------------------------------

function CastMissileSalvo()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.missile_salvo:entindex(),
		Queue = 0,
	})

	return ((thisEntity.nMaxWaves * thisEntity.flTimeBetweenWaves) + 2)
end
--------------------------------------------------------------------------------

function CastChokingGas()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.choking_gas:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

