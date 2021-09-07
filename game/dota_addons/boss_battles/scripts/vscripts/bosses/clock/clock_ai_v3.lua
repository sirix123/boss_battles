clock_ai_v2 = class({})

LinkLuaModifier("furnace_modifier_1", "bosses/clock/modifiers/furnace_modifier_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("furnace_modifier_2", "bosses/clock/modifiers/furnace_modifier_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("furnace_modifier_3", "bosses/clock/modifiers/furnace_modifier_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("furnace_modifier_4", "bosses/clock/modifiers/furnace_modifier_4", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("armor_buff_modifier", "bosses/clock/modifiers/armor_buff_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("enrage", "bosses/clock/modifiers/enrage", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_remove_healthbar", "core/modifier_remove_healthbar", LUA_MODIFIER_MOTION_NONE)

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	boss_frame_manager:SendBossName()
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:ShowBossManaFrame()
	boss_frame_manager:ShowBossHpFrame()

	if EASY_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "easy_mode_modifier", { duration = -1 } )
    end

	-- armor modifier
	-- start stacks at 3, reduce to 0
	-- add code to the activate furnace stuf
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity.hBuff = thisEntity:AddNewModifier( nil, nil, "armor_buff_modifier", { duration = -1 } )
	thisEntity.hBuff:SetStackCount(4)
	thisEntity.nStacks = 0

	-- summon furnace
	thisEntity.furnace_1 = Entities:FindByName(nil, "furnace_1"):GetAbsOrigin()
	thisEntity.furnace_2 = Entities:FindByName(nil, "furnace_2"):GetAbsOrigin()
	thisEntity.furnace_3 = Entities:FindByName(nil, "furnace_3"):GetAbsOrigin()
	thisEntity.furnace_4 = Entities:FindByName(nil, "furnace_4"):GetAbsOrigin()

	thisEntity.furnace_1_unit = CreateUnitByName("furnace_1", thisEntity.furnace_1, false, nil, nil, DOTA_TEAM_BADGUYS)
	thisEntity.furnace_2_unit = CreateUnitByName("furnace_2", thisEntity.furnace_2, false, nil, nil, DOTA_TEAM_BADGUYS)
	thisEntity.furnace_3_unit = CreateUnitByName("furnace_3", thisEntity.furnace_3, false, nil, nil, DOTA_TEAM_BADGUYS)
	thisEntity.furnace_4_unit = CreateUnitByName("furnace_4", thisEntity.furnace_4, false, nil, nil, DOTA_TEAM_BADGUYS)

	thisEntity.nActivatedFurnaces = 0

	thisEntity.furnace_1_activated = false
	thisEntity.furnace_2_activated = false
	thisEntity.furnace_3_activated = false
	thisEntity.furnace_4_activated = false

	thisEntity.t_activated_furnaces = {thisEntity.furnace_1_unit, thisEntity.furnace_2_unit, thisEntity.furnace_3_unit, thisEntity.furnace_4_unit}

	thisEntity.cool_down_between_furnaces = 20

	-- spawn arrows in furnace location
	thisEntity.spawn_arrows = true

	-- setup timers
	FindNewTarget()
	ActivateFurnace()
	CheckFurnace()
	CheckEnrage()

	thisEntity.i = 0
	thisEntity.nActivatedFurnaces = 0

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	-- droids + turrets
	thisEntity.summon_flame_turret = thisEntity:FindAbilityByName( "summon_flame_turret" )
	thisEntity.summon_flame_turret:StartCooldown(5)

	thisEntity.summon_chain_gun_turret = thisEntity:FindAbilityByName( "summon_chain_gun_turret" )
	thisEntity.summon_chain_gun_turret:StartCooldown(8)

	thisEntity.summon_furnace_droid = thisEntity:FindAbilityByName( "summon_furnace_droid" )
	--thisEntity.summon_furnace_droid:StartCooldown(thisEntity.summon_furnace_droid:GetCooldown(thisEntity.summon_furnace_droid:GetLevel()))
	thisEntity.summon_furnace_droid:EndCooldown()

	-- electric turret
	thisEntity.summon_electric_turret = thisEntity:FindAbilityByName( "summon_electric_turret" )

	-- hook
	thisEntity.hookshot = thisEntity:FindAbilityByName( "hookshot" )
	thisEntity.hookshot:StartCooldown(thisEntity.hookshot:GetCooldown(thisEntity.hookshot:GetLevel()))

	-- salvo
	thisEntity.missile_salvo = thisEntity:FindAbilityByName( "missile_salvo" )
	thisEntity.nMaxWaves = thisEntity.missile_salvo:GetLevelSpecialValueFor("nMaxWaves", thisEntity.missile_salvo:GetLevel())
	thisEntity.flTimeBetweenWaves = thisEntity.missile_salvo:GetLevelSpecialValueFor("flTimeBetweenWaves", thisEntity.missile_salvo:GetLevel())

	-- cogs
	thisEntity.cogs = thisEntity:FindAbilityByName( "cogs" )
	thisEntity.loop = thisEntity.cogs:GetLevelSpecialValueFor("totalTicks", thisEntity.cogs:GetLevel())
	thisEntity.interval = thisEntity.cogs:GetLevelSpecialValueFor("timerInterval", thisEntity.cogs:GetLevel())
	thisEntity.cogs:StartCooldown(18)
	thisEntity.cast_cogs = false
	thisEntity.mana_regen = thisEntity:GetManaRegen()

	-- start misile salvo cd so he doesn't cast it on spawn
	thisEntity.missile_salvo:StartCooldown(thisEntity.missile_salvo:GetCooldown(thisEntity.missile_salvo:GetLevel()))

	-- chooking gas
	thisEntity.choking_gas = thisEntity:FindAbilityByName( "choking_gas" )
	thisEntity.choking_gas:StartCooldown(thisEntity.choking_gas:GetCooldown(thisEntity.choking_gas:GetLevel()))

	-- vortex grenade
	thisEntity.vortex_grenade = thisEntity:FindAbilityByName( "vortex_grenade" )

	-- missile single
	thisEntity.fire_missile = thisEntity:FindAbilityByName( "fire_missile_tracking" )

	-- handle level up
	thisEntity.levelTracker = 1

	-- hitbox/hullraidus
	thisEntity:SetHullRadius(50)

	thisEntity:SetContextThink( "Clock", ClockThink, 0.5 )
end

function ClockThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		ParticleManager:DestroyParticle(thisEntity.pfx_1, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_2, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_3, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_4, true)

		ParticleManager:ReleaseParticleIndex(thisEntity.pfx_1)
		ParticleManager:ReleaseParticleIndex(thisEntity.pfx_2)
		ParticleManager:ReleaseParticleIndex(thisEntity.pfx_3)
		ParticleManager:ReleaseParticleIndex(thisEntity.pfx_4)
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity.spawn_arrows == true then
		SpawnArrows()
	end

	if thisEntity.cast_cogs ~= true then
		thisEntity.nActiveFurnaces = FindFurnacesWithActivatedBuff()
	end

	--print("thisEntity.cast_cogs ",thisEntity.cast_cogs)

	if thisEntity:HasModifier("armor_buff_modifier") == true and thisEntity.nActiveFurnaces ~= 4 or thisEntity.nActiveFurnaces ~= 0.5 and thisEntity.hBuff:IsNull() == false then
		thisEntity.nStacks = thisEntity.hBuff:GetStackCount()
		--print("thisEntity.nStacks ",thisEntity.nStacks)
	end

	-- after using the cogs ability reapply the armor modifier with the correct stacks
	if thisEntity.nActiveFurnaces ~= nil then
		if thisEntity:HasModifier("armor_buff_modifier") == false and thisEntity.cast_cogs == true and thisEntity.nActiveFurnaces < 4 and thisEntity.nStacks ~= 0 then
			--print("nActiveFurnaces ",thisEntity.nActiveFurnaces)
			--print("----")
			thisEntity.hBuff = thisEntity:AddNewModifier( nil, nil, "armor_buff_modifier", { duration = -1 } )
			thisEntity.hBuff:SetStackCount(thisEntity.nStacks)
			thisEntity.cast_cogs = false
			thisEntity:SetBaseManaRegen(thisEntity.mana_regen)
		end
	end

	--[[if thisEntity:HasModifier("armor_buff_modifier") then
		if thisEntity.hBuff:GetStackCount() ~= 0 and thisEntity.hBuff:GetStackCount() ~= nil then
			--print("thisEntity:GetPhysicalArmorValue ",thisEntity:GetPhysicalArmorValue(false))
			--print("stackcount ",thisEntity.hBuff:GetStackCount())
		end
	end]]

	-- check how many furnaces are active so we can level up abilities
	if thisEntity.nActiveFurnaces == 1 and thisEntity.levelTracker == 1 then
		LevelUpAbilities() -- forces all abilities to be level 2
	end
	if thisEntity.nActiveFurnaces == 2 and thisEntity.levelTracker == 2 then
		LevelUpAbilities() -- forces all abilities to be level 2
	end
	if thisEntity.nActiveFurnaces == 3 and thisEntity.levelTracker == 3 then
		LevelUpAbilities() -- forces all abilities to be level 3
	end
	if thisEntity.nActiveFurnaces == 4 and thisEntity.levelTracker == 4 then
		LevelUpAbilities() -- forces all abilities to be level 4
	end

	if thisEntity.fire_missile:IsFullyCastable() and thisEntity.fire_missile:IsCooldownReady() and thisEntity.fire_missile:IsInAbilityPhase() == false then
		return CastFireMissile()
	end

	if thisEntity.choking_gas:IsFullyCastable() and thisEntity.choking_gas:IsCooldownReady() and thisEntity:HasModifier("furnace_modifier_2") and thisEntity.choking_gas:IsInAbilityPhase() == false then
		return CastChokingGas()
	end

	if thisEntity.summon_flame_turret:IsFullyCastable() and thisEntity.summon_flame_turret:IsCooldownReady() and thisEntity.summon_flame_turret:IsInAbilityPhase() == false then
		return CastSummonFlameTurret()
	end

	if EASY_MODE == false then
		if thisEntity.summon_chain_gun_turret:IsFullyCastable() and thisEntity.summon_chain_gun_turret:IsCooldownReady() and thisEntity.summon_chain_gun_turret:IsInAbilityPhase() == false then
			return CastChainGunTurret()
		end
	end

	if thisEntity.cogs:IsFullyCastable() and thisEntity.cogs:IsCooldownReady() and thisEntity.cast_cogs == false and thisEntity.cogs:IsInAbilityPhase() == false then
		return CastCogs()
	end

	if thisEntity.missile_salvo:IsFullyCastable() and thisEntity.missile_salvo:IsCooldownReady() and thisEntity.missile_salvo:IsInAbilityPhase() == false then
		return CastMissileSalvo()
	end

	if thisEntity.vortex_grenade:IsFullyCastable() and thisEntity.vortex_grenade:IsCooldownReady() and thisEntity:HasModifier("furnace_modifier_3") and thisEntity.vortex_grenade:IsInAbilityPhase() == false then
		return CastVortexGrenade()
	end

	if thisEntity.hookshot:IsFullyCastable() and thisEntity.hookshot:IsCooldownReady() and thisEntity:HasModifier("furnace_modifier_4") then
		return CastHookshot()
	end
	return 0.5
end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	thisEntity.levelTracker = thisEntity.levelTracker + 1

	thisEntity.summon_flame_turret:SetLevel(thisEntity.levelTracker)
	thisEntity.summon_chain_gun_turret:SetLevel(thisEntity.levelTracker)
	thisEntity.summon_furnace_droid:SetLevel(thisEntity.levelTracker)
	thisEntity.summon_electric_turret:SetLevel(thisEntity.levelTracker)
	thisEntity.hookshot:SetLevel(thisEntity.levelTracker)
	thisEntity.vortex_grenade:SetLevel(thisEntity.levelTracker)
	thisEntity.choking_gas:SetLevel(thisEntity.levelTracker)
	thisEntity.cogs:SetLevel(thisEntity.levelTracker)

end
--------------------------------------------------------------------------------

function FindNewTarget()

	Timers:CreateTimer(function()
		if IsValidEntity(thisEntity) == false then return false end
		if ( not thisEntity:IsAlive() ) then
			print("end timer?")
			return false
		end

		-- find random player
		local enemies = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity:GetAbsOrigin(),
			nil,
			5000,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			false )

		if #enemies ~= 0 and enemies ~= nil then

			local random_target = RandomInt(1,#enemies)
			local test_target = enemies[random_target]:GetAbsOrigin()

			local distance_from_target = ( thisEntity:GetAbsOrigin() - test_target ):Length2D()

			if distance_from_target < 800 then
				thisEntity.main_target = nil
				return 0.1
			else
				thisEntity.main_target = test_target
				return 0.5
			end

		end

		return 0.5
	end)
end
--------------------------------------------------------------------------------

function CastFireMissile( )
	ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.fire_missile:entindex(),
        Queue = false,
	})
	return 0.1
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

function CastHookshot()

	local tFarTargets = {}

	local units = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),	-- int, your team number
		thisEntity:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		2500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if units == nil or #units == 0 then
		return 0.5
	else
		for _, unit in pairs(units) do
			if ( thisEntity:GetAbsOrigin() - unit:GetAbsOrigin() ):Length2D() > 400 then
				table.insert(tFarTargets,unit)
			end
		end

		if tFarTargets == nil or #tFarTargets == 0 then
			return 0.5
		else
			thisEntity.hTarget = tFarTargets[RandomInt(1, #tFarTargets)]
		end

		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity.hTarget:entindex(),
			AbilityIndex = thisEntity.hookshot:entindex(),
			Queue = false,
		})

		return 5

	end

	return 0.5
end
--------------------------------------------------------------------------------

function CastCogs()
	thisEntity:SetBaseManaRegen(0)

	thisEntity.count = 5
	Timers:CreateTimer(function()

		if thisEntity:IsAlive() == nil or thisEntity:IsAlive() == false then
			ParticleManager:DestroyParticle(thisEntity.particle, true)
			return false
		end

		if thisEntity.count == 0 then

			ParticleManager:DestroyParticle(thisEntity.particle, true)

			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.cogs:entindex(),
				Queue = 0,
			})

			thisEntity.cast_cogs = true

			if thisEntity:HasModifier("armor_buff_modifier") == true then
				thisEntity.hBuff:SetStackCount(0)
			end

			return false
		end

		if thisEntity.particle then
			ParticleManager:DestroyParticle(thisEntity.particle, true)
		end

		thisEntity.particle = ParticleManager:CreateParticle("particles/clock/clock_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, thisEntity)
		ParticleManager:SetParticleControl(thisEntity.particle, 0, thisEntity:GetAbsOrigin())
		ParticleManager:SetParticleControl(thisEntity.particle, 1, Vector( 0, thisEntity.count, 0 ))
		thisEntity.count = thisEntity.count - 1

		return 1

	end)

	return ( thisEntity.loop * thisEntity.interval ) + 10
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

function CastSummonElectricTurret()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_electric_turret:entindex(),
		Queue = 0,
	})
	return 0.5
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

function CastVortexGrenade()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.vortex_grenade:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function SpawnArrows()
	thisEntity.spawn_arrows = false

	local particleName_1 = "particles/clock/blue_clock_npx_moveto_arrow.vpcf"
	thisEntity.pfx_1 = ParticleManager:CreateParticle( particleName_1, PATTACH_WORLDORIGIN, thisEntity )
	ParticleManager:SetParticleControl( thisEntity.pfx_1, 0, thisEntity.furnace_1 )

	local particleName_2 = "particles/clock/red_clock_npx_moveto_arrow.vpcf"
	thisEntity.pfx_2 = ParticleManager:CreateParticle( particleName_2, PATTACH_WORLDORIGIN, thisEntity )
	ParticleManager:SetParticleControl( thisEntity.pfx_2, 0, thisEntity.furnace_2 )

	local particleName_3 = "particles/clock/green_clock_npx_moveto_arrow.vpcf"
	thisEntity.pfx_3 = ParticleManager:CreateParticle( particleName_3, PATTACH_WORLDORIGIN, thisEntity )
	ParticleManager:SetParticleControl( thisEntity.pfx_3, 0, thisEntity.furnace_3 )

	local particleName_4 = "particles/clock/orange_clock_npx_moveto_arrow.vpcf"
	thisEntity.pfx_4 = ParticleManager:CreateParticle( particleName_4, PATTACH_WORLDORIGIN, thisEntity )
	ParticleManager:SetParticleControl( thisEntity.pfx_4, 0, thisEntity.furnace_4 )

end
--------------------------------------------------------------------------------

function FindFurnacesWithActivatedBuff()

	--if thisEntity.cast_cogs == true then return 0.5 end

	if thisEntity.furnace_1_unit.FURNACE_1 == true and thisEntity.furnace_1_activated == false and thisEntity.cast_cogs ~= true then
		thisEntity.furnace_1_activated = true
		thisEntity.nActivatedFurnaces = thisEntity.nActivatedFurnaces + 1
		thisEntity:AddNewModifier( nil, nil, "furnace_modifier_1", { duration = -1 } )

		-- arrow handler
		ParticleManager:DestroyParticle(thisEntity.pfx_1, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_2, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_3, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_4, true)

		-- remove furnace from the table
		for k, furnace in pairs(thisEntity.t_activated_furnaces) do
			if furnace == thisEntity.furnace_1_unit then
				print("removing f1 from table")
				table.remove(thisEntity.t_activated_furnaces, k)
			end
		end

		-- start timer, at end of timer display arrows again
		ResetArrows()

		-- reduce stack count
		if thisEntity.hBuff ~= nil then
			thisEntity.hBuff:DecrementStackCount()
		end


	elseif thisEntity.furnace_2_unit.FURNACE_2 == true and thisEntity.furnace_2_activated == false and thisEntity.cast_cogs ~= true then
		thisEntity.furnace_2_activated = true
		thisEntity.nActivatedFurnaces = thisEntity.nActivatedFurnaces + 1
		thisEntity:AddNewModifier( nil, nil, "furnace_modifier_2", { duration = -1 } )

		-- arrow handler
		ParticleManager:DestroyParticle(thisEntity.pfx_1, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_2, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_3, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_4, true)

		-- remove furnace from the table
		for k, furnace in pairs(thisEntity.t_activated_furnaces) do
			if furnace == thisEntity.furnace_2_unit then
				print("removing f2 from table")
				table.remove(thisEntity.t_activated_furnaces, k)
			end
		end

		-- start timer, at end of timer display arrows again
		ResetArrows()

		-- reduce stack count
		if thisEntity.hBuff ~= nil then
			thisEntity.hBuff:DecrementStackCount()
		end

	elseif thisEntity.furnace_3_unit.FURNACE_3 == true and thisEntity.furnace_3_activated == false and thisEntity.cast_cogs ~= true then
		thisEntity.furnace_3_activated = true
		thisEntity.nActivatedFurnaces = thisEntity.nActivatedFurnaces + 1
		thisEntity:AddNewModifier( nil, nil, "furnace_modifier_3", { duration = -1 } )

		-- arrow handler
		ParticleManager:DestroyParticle(thisEntity.pfx_1, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_2, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_3, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_4, true)

		-- remove furnace from the table
		for k, furnace in pairs(thisEntity.t_activated_furnaces) do
			if furnace == thisEntity.furnace_3_unit then
				print("removing f3 from table")
				table.remove(thisEntity.t_activated_furnaces, k)
			end
		end

		-- start timer, at end of timer display arrows again
		ResetArrows()

		-- reduce stack count
		if thisEntity.hBuff ~= nil then
			thisEntity.hBuff:DecrementStackCount()
		end

	elseif thisEntity.furnace_4_unit.FURNACE_4 == true and thisEntity.furnace_4_activated == false and thisEntity.cast_cogs ~= true then
		thisEntity.furnace_4_activated = true
		thisEntity.nActivatedFurnaces = thisEntity.nActivatedFurnaces + 1
		thisEntity:AddNewModifier( nil, nil, "furnace_modifier_4", { duration = -1 } )

		-- arrow handler
		ParticleManager:DestroyParticle(thisEntity.pfx_1, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_2, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_3, true)
		ParticleManager:DestroyParticle(thisEntity.pfx_4, true)

		-- remove furnace from the table
		for k, furnace in pairs(thisEntity.t_activated_furnaces) do
			if furnace == thisEntity.furnace_4_unit then
				print("removing f4 from table")
				table.remove(thisEntity.t_activated_furnaces, k)
			end
		end

		-- start timer, at end of timer display arrows again
		ResetArrows()

		-- reduce stack count
		if thisEntity.hBuff ~= nil then
			thisEntity.hBuff:DecrementStackCount()
		end

	end

	--print("thisEntity.nActivatedFurnaces ",thisEntity.nActivatedFurnaces)
	return thisEntity.nActivatedFurnaces
end
--------------------------------------------------------------------------------

function ResetArrows()
	Timers:CreateTimer(thisEntity.cool_down_between_furnaces,function()
		if ( not thisEntity:IsAlive() ) then
			return false
		end

		if thisEntity.furnace_1_unit.FURNACE_1 == false and thisEntity.furnace_1_activated == false then
			local particleName_1 = "particles/clock/blue_clock_npx_moveto_arrow.vpcf"
			thisEntity.pfx_1 = ParticleManager:CreateParticle( particleName_1, PATTACH_WORLDORIGIN, thisEntity )
			ParticleManager:SetParticleControl( thisEntity.pfx_1, 0, thisEntity.furnace_1 )
		end

		if thisEntity.furnace_2_unit.FURNACE_2 == false and thisEntity.furnace_2_activated == false then
			local particleName_2 = "particles/clock/red_clock_npx_moveto_arrow.vpcf"
			thisEntity.pfx_2 = ParticleManager:CreateParticle( particleName_2, PATTACH_WORLDORIGIN, thisEntity )
			ParticleManager:SetParticleControl( thisEntity.pfx_2, 0, thisEntity.furnace_2 )
		end

		if thisEntity.furnace_3_unit.FURNACE_3 == false and thisEntity.furnace_3_activated == false then
			local particleName_3 = "particles/clock/green_clock_npx_moveto_arrow.vpcf"
			thisEntity.pfx_3 = ParticleManager:CreateParticle( particleName_3, PATTACH_WORLDORIGIN, thisEntity )
			ParticleManager:SetParticleControl( thisEntity.pfx_3, 0, thisEntity.furnace_3 )
		end

		if thisEntity.furnace_4_unit.FURNACE_4 == false and thisEntity.furnace_4_activated == false then
			local particleName_4 = "particles/clock/orange_clock_npx_moveto_arrow.vpcf"
			thisEntity.pfx_4 = ParticleManager:CreateParticle( particleName_4, PATTACH_WORLDORIGIN, thisEntity )
			ParticleManager:SetParticleControl( thisEntity.pfx_4, 0, thisEntity.furnace_4 )
		end

		return false
	end)
end
--------------------------------------------------------------------------------
function CheckEnrage()
	Timers:CreateTimer(function()
		if IsValidEntity(thisEntity) == false then return false end
		if ( not thisEntity:IsAlive() ) then
			print("end timer?")
			return false
		end

		if thisEntity:HasModifier("enrage") == true and thisEntity.nActivatedFurnaces == thisEntity.i then
			print("removing enrage buff")
			thisEntity:RemoveModifierByName("enrage")
		end

		return 0.1
	end)
end
--------------------------------------------------------------------------------

function CheckFurnace()

	-- check if furnace count is increasing every 2mins
	-- 120
	Timers:CreateTimer(45,function()
		if IsValidEntity(thisEntity) == false then return false end
		if ( not thisEntity:IsAlive() ) then
			thisEntity.i = 0
			--print("end timer?")
			return false
		end

		if thisEntity.cast_cogs == true then return 0.5 end

		thisEntity.i = thisEntity.i + 1
		--print("thisEntity.i ", thisEntity.i)
		--print("thisEntity.nActivatedFurnaces ", thisEntity.nActivatedFurnaces)

		-- if all furnace active stop timer
		if thisEntity.nActivatedFurnaces == 4 then
			--print("end timer... dont check for enrage anymore cause all furnace are active")
			return false
		end

		-- check if furnace count is the same as before and boss doesn't have enrage buff, give enrage buff and end timer
		if thisEntity:HasModifier("enrage") ~= true and thisEntity.nActivatedFurnaces < thisEntity.i then

			-- link the non activated furnaces
			if thisEntity.furnace_1_activated == false then
				thisEntity.nfx_1 = ParticleManager:CreateParticle("particles/beastmaster/beastmaster_razor_static_link.vpcf", PATTACH_POINT_FOLLOW, thisEntity)
				ParticleManager:SetParticleControlEnt(thisEntity.nfx_1, 0, thisEntity, PATTACH_POINT_FOLLOW, "attach_hitloc", thisEntity:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(thisEntity.nfx_1, 1, thisEntity.furnace_1)
			end

			if thisEntity.furnace_2_activated == false then
				thisEntity.nfx_2 = ParticleManager:CreateParticle("particles/beastmaster/beastmaster_razor_static_link.vpcf", PATTACH_POINT_FOLLOW, thisEntity)
				ParticleManager:SetParticleControlEnt(thisEntity.nfx_2 , 0, thisEntity, PATTACH_POINT_FOLLOW, "attach_hitloc", thisEntity:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(thisEntity.nfx_2 , 1, thisEntity.furnace_2)
			end

			if thisEntity.furnace_3_activated == false then
				thisEntity.nfx_3 = ParticleManager:CreateParticle("particles/beastmaster/beastmaster_razor_static_link.vpcf", PATTACH_POINT_FOLLOW, thisEntity)
				ParticleManager:SetParticleControlEnt(thisEntity.nfx_3, 0, thisEntity, PATTACH_POINT_FOLLOW, "attach_hitloc", thisEntity:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(thisEntity.nfx_3, 1, thisEntity.furnace_3)
			end

			if thisEntity.furnace_4_activated == false then
				thisEntity.nfx_4 = ParticleManager:CreateParticle("particles/beastmaster/beastmaster_razor_static_link.vpcf", PATTACH_POINT_FOLLOW, thisEntity)
				ParticleManager:SetParticleControlEnt(thisEntity.nfx_4, 0, thisEntity, PATTACH_POINT_FOLLOW, "attach_hitloc", thisEntity:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(thisEntity.nfx_4, 1, thisEntity.furnace_4)
			end

			--after x seconds enrage
			Timers:CreateTimer(10,function()

				-- destroy particle effect
				if thisEntity.nfx_1 ~= nil then
					ParticleManager:DestroyParticle(thisEntity.nfx_1, true)
				end
				if thisEntity.nfx_2 ~= nil then
					ParticleManager:DestroyParticle(thisEntity.nfx_2, true)
				end
				if thisEntity.nfx_3 ~= nil then
					ParticleManager:DestroyParticle(thisEntity.nfx_3, true)
				end
				if thisEntity.nfx_4 ~= nil then
					ParticleManager:DestroyParticle(thisEntity.nfx_4, true)
				end

				-- apply enrage
				--print("applying enrage buff")

				-- play voice line
				EmitGlobalSound("rattletrap_ratt_immort_01")


				thisEntity:AddNewModifier( nil, nil, "enrage", { duration = -1 } )
			end)

			return 85
		else
			return 85
		end

	end)
end

--------------------------------------------------------------------------------
function ActivateFurnace()

	Timers:CreateTimer(function()
		if IsValidEntity(thisEntity) == false then
			return false
		end

		if ( not thisEntity:IsAlive() ) then
			print("end timer?")
			return false
		end

		if thisEntity.cast_cogs == true then return 0.5 end

		--print("ActivateFurnace timer running")

		local units_f1 = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity.furnace_1,
			nil,
			200,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false )

		local units_f2 = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity.furnace_2,
			nil,
			200,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false )

		local units_f3 = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity.furnace_3,
			nil,
			200,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false )

		local units_f4 = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity.furnace_4,
			nil,
			200,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false )


		for _, unit in pairs(units_f1) do
			if unit:GetUnitName() == "npc_clock" and thisEntity.furnace_1_unit.FURNACE_1 == false then
				thisEntity.furnace_1_unit.FURNACE_1 = true
				print("looking for units in f1")
				-- activate / play effect
				local particleName = "particles/clock/blue_furnace_activate_jakiro_ti10_macropyre.vpcf"
				thisEntity.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
				ParticleManager:SetParticleControl( thisEntity.pfx, 0, thisEntity.furnace_1 )
				ParticleManager:SetParticleControl( thisEntity.pfx, 1, thisEntity.furnace_1 )
				ParticleManager:ReleaseParticleIndex(thisEntity.pfx)

				thisEntity:EmitSound("Hero_OgreMagi.Fireblast.Target")

				-- return timer the cooldown
				return thisEntity.cool_down_between_furnaces

			end
		end

		for _, unit in pairs(units_f2) do
			if unit:GetUnitName() == "npc_clock" and thisEntity.furnace_2_unit.FURNACE_2 == false then
				thisEntity.furnace_2_unit.FURNACE_2 = true
				print("looking for units in f2")
				-- activate / play effect
				local particleName = "particles/clock/red_furnace_activate_jakiro_ti10_macropyre.vpcf"
				thisEntity.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
				ParticleManager:SetParticleControl( thisEntity.pfx, 0, thisEntity.furnace_2 )
				ParticleManager:SetParticleControl( thisEntity.pfx, 1, thisEntity.furnace_2 )
				ParticleManager:ReleaseParticleIndex(thisEntity.pfx)

				thisEntity:EmitSound("Hero_OgreMagi.Fireblast.Target")

				-- return timer the cooldown
				return thisEntity.cool_down_between_furnaces

			end
		end

		for _, unit in pairs(units_f3) do
			if unit:GetUnitName() == "npc_clock" and thisEntity.furnace_3_unit.FURNACE_3 == false then
				thisEntity.furnace_3_unit.FURNACE_3 = true
				print("looking for units in f3")
				-- activate / play effect
				local particleName = "particles/clock/green_furnace_activate_jakiro_ti10_macropyre.vpcf"
				thisEntity.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
				ParticleManager:SetParticleControl( thisEntity.pfx, 0, thisEntity.furnace_3 )
				ParticleManager:SetParticleControl( thisEntity.pfx, 1, thisEntity.furnace_3 )
				ParticleManager:ReleaseParticleIndex(thisEntity.pfx)

				thisEntity:EmitSound("Hero_OgreMagi.Fireblast.Target")

				-- return timer the cooldown
				return thisEntity.cool_down_between_furnaces

			end
		end

		for _, unit in pairs(units_f4) do
			if unit:GetUnitName() == "npc_clock" and thisEntity.furnace_4_unit.FURNACE_4 == false then
				thisEntity.furnace_4_unit.FURNACE_4 = true
				print("looking for units in f4")
				-- activate / play effect
				local particleName = "particles/clock/orange_furnace_activate_jakiro_ti10_macropyre.vpcf"
				thisEntity.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
				ParticleManager:SetParticleControl( thisEntity.pfx, 0, thisEntity.furnace_4 )
				ParticleManager:SetParticleControl( thisEntity.pfx, 1, thisEntity.furnace_4 )
				ParticleManager:ReleaseParticleIndex(thisEntity.pfx)

				thisEntity:EmitSound("Hero_OgreMagi.Fireblast.Target")

				-- return timer the cooldown
				return thisEntity.cool_down_between_furnaces

			end
		end

		return 0.1
	end)
end
