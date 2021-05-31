tinker_ai = class({})

LinkLuaModifier("shield_effect", "bosses/tinker/modifiers/shield_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("phase_1_fog", "bosses/tinker/modifiers/phase_1_fog", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
	if thisEntity == nil then return end

	CreateUnitByName( "npc_crystal", Vector(-10673,11950,0), true, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)

	thisEntity:AddNewModifier( nil, nil, "shield_effect", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

	thisEntity.PHASE = 1
	thisEntity.stack_count = 0
	thisEntity.max_beam_stacks = 3 --3

	thisEntity.rearm = true

	thisEntity:SetHullRadius(100)

	_G.Crystal_Phase2_Spawns = {}
	_G.Crystal_Phase1_Spawns_Particles = {}

	thisEntity.chain_light_v2 = thisEntity:FindAbilityByName( "chain_light_v2" )
	thisEntity.chain_light_v2:StartCooldown(thisEntity.chain_light_v2:GetCooldown(thisEntity.chain_light_v2:GetLevel()))

	thisEntity.ice_shot_tinker = thisEntity:FindAbilityByName( "ice_shot_tinker" )
	thisEntity.ice_shot_tinker:StartCooldown(thisEntity.ice_shot_tinker:GetCooldown(thisEntity.ice_shot_tinker:GetLevel()))

	thisEntity.red_missile = thisEntity:FindAbilityByName( "red_missile" )
	thisEntity.red_missile:StartCooldown(thisEntity.red_missile:GetCooldown(thisEntity.red_missile:GetLevel()))

	thisEntity.tinker_teleport = thisEntity:FindAbilityByName( "tinker_teleport" )
	thisEntity.tinker_teleport:StartCooldown(thisEntity.tinker_teleport:GetCooldown(thisEntity.tinker_teleport:GetLevel()))

	thisEntity.tinker_teleport_beam_phase = thisEntity:FindAbilityByName( "tinker_teleport_beam_phase" )

	thisEntity.missile = thisEntity:FindAbilityByName( "missile" )

	thisEntity.laser = thisEntity:FindAbilityByName( "laser" )

	thisEntity.link_crystals_tinker = thisEntity:FindAbilityByName( "link_crystals_tinker" )

	thisEntity.health_drain_tinker = thisEntity:FindAbilityByName( "health_drain_tinker" )
	thisEntity.drain_lock = false

	thisEntity.march = thisEntity:FindAbilityByName( "march" )
	thisEntity.current_rearms_march = 0
	thisEntity.max_rearms_march = 3

	thisEntity.tinker_teleport_phase2 = thisEntity:FindAbilityByName( "tinker_teleport_phase2" )

	thisEntity.prisonbeam = thisEntity:FindAbilityByName( "prisonbeam" )

    thisEntity:SetContextThink( "TinkerThinker", TinkerThinker, 0.1 )

end
--------------------------------------------------------------------------------

function TinkerThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		thisEntity.stop_timers = true
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--print("tinker thisEntity.PHASE ", thisEntity.PHASE)

	-- handles the phase changes etc
	if thisEntity:HasModifier("beam_counter") then
		thisEntity.stack_count = thisEntity:FindModifierByName("beam_counter"):GetStackCount()
		--print("stack_count ", thisEntity.stack_count)
	end

	-- if this unit has the beam phase modiifier then phase == 2
	if thisEntity:HasModifier("beam_phase") then
		thisEntity.PHASE = 2
	elseif thisEntity.PHASE ~= 3 and thisEntity.PHASE ~= 4 then
		thisEntity.teleport_out = false
		thisEntity.PHASE = 1
	end

	if thisEntity.stack_count == thisEntity.max_beam_stacks then
		thisEntity:RemoveModifierByName("shield_effect")
		thisEntity:RemoveModifierByName("beam_counter")
		thisEntity:RemoveModifierByName("modifier_invulnerable")
		thisEntity.stack_count = 0
		thisEntity.PHASE = 3

		thisEntity.tinker_teleport:StartCooldown(20)

		-- transition to phase 3, fog reduce etc
		return Transition()
	end

	-- phase 1
	if thisEntity.PHASE == 1 then
		if thisEntity.tinker_teleport ~= nil and thisEntity.tinker_teleport:IsFullyCastable() and thisEntity.tinker_teleport:IsCooldownReady() and thisEntity.tinker_teleport:IsInAbilityPhase() == false then
			return CastTeleport()
		end

		if thisEntity.chain_light_v2 ~= nil and thisEntity.chain_light_v2:IsFullyCastable() and thisEntity.chain_light_v2:IsCooldownReady() and thisEntity.stack_count >= 2 and thisEntity.chain_light_v2:IsInAbilityPhase() == false then
			return CastChainLight()
		end

		if thisEntity.red_missile ~= nil and thisEntity.red_missile:IsFullyCastable() and thisEntity.red_missile:IsCooldownReady() and thisEntity.stack_count >= 1 and thisEntity.red_missile:IsInAbilityPhase() == false then
			return CastRedMissile()
		end

		if thisEntity.ice_shot_tinker ~= nil and thisEntity.ice_shot_tinker:IsFullyCastable() and thisEntity.ice_shot_tinker:IsCooldownReady() and thisEntity.ice_shot_tinker:IsInAbilityPhase() == false then
			return CastIceShot()
		end

	end

	-- crystal phase
	if thisEntity.PHASE == 2 then

		if thisEntity.teleport_out ~= true then

			thisEntity.teleport_out = true
	
			if thisEntity.tinker_teleport_beam_phase ~= nil and thisEntity.tinker_teleport_beam_phase:IsFullyCastable() and thisEntity.tinker_teleport_beam_phase:IsCooldownReady() and thisEntity.tinker_teleport_beam_phase:IsInAbilityPhase() == false then
				CastTeleportBeamPhase()
			end

			Timers:CreateTimer(15,function()
				if thisEntity.stop_timers == true then
					return false
				end

				thisEntity.tinker_teleport:EndCooldown()

				if thisEntity.tinker_teleport ~= nil and thisEntity.tinker_teleport:IsFullyCastable() and thisEntity.tinker_teleport:IsCooldownReady() and thisEntity.tinker_teleport:IsInAbilityPhase() == false then
					CastTeleport()
				end

				thisEntity.ice_shot_tinker:StartCooldown(RandomInt(5,10))
				thisEntity.red_missile:StartCooldown(RandomInt(10,25))
				thisEntity.chain_light_v2:StartCooldown(RandomInt(10,20))

				return false
			end)

		end
	end

	-- phase 2
	if thisEntity.PHASE == 4 and thisEntity:HasModifier("attack_interupt") == false and thisEntity.drain_lock == false then
		thisEntity.PHASE = 3
	end

	if thisEntity.PHASE == 3 then

		boss_frame_manager:SendBossName( )
		boss_frame_manager:UpdateManaHealthFrame( thisEntity )
		boss_frame_manager:ShowBossHpFrame( )
		boss_frame_manager:HideBossManaFrame()

		if thisEntity.march ~= nil and thisEntity.march:IsFullyCastable() and thisEntity.march:IsCooldownReady() and thisEntity.march:IsInAbilityPhase() == false then
			return CastMarch()
		end

		if thisEntity.laser ~= nil and thisEntity.laser:IsFullyCastable() and thisEntity.laser:IsCooldownReady() and thisEntity.laser:IsInAbilityPhase() == false then
			return CastLaser()
		end

		if thisEntity.link_crystals_tinker ~= nil and thisEntity.link_crystals_tinker:IsFullyCastable() and thisEntity.link_crystals_tinker:IsCooldownReady() and thisEntity.link_crystals_tinker:IsInAbilityPhase() == false then
			return CastLinkCrystals()
		end

		if thisEntity.tinker_teleport_phase2 ~= nil and thisEntity.tinker_teleport_phase2:IsFullyCastable() and thisEntity.tinker_teleport_phase2:IsCooldownReady() and thisEntity.tinker_teleport_phase2:IsInAbilityPhase() == false then
			return CastTeleportPhase2()
		end

	end

	if thisEntity.PHASE == 4 then

		if thisEntity.health_drain_tinker ~= nil and thisEntity.health_drain_tinker:IsFullyCastable() and thisEntity.health_drain_tinker:IsCooldownReady() and thisEntity.health_drain_tinker:IsInAbilityPhase() == false and thisEntity.health_drain_tinker:IsChanneling() == false then
			return CastHealthDrain()
		end

	end

	return 0.1
end
--------------------------------------------------------------------------------

function CastTeleport(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.tinker_teleport:entindex(),
        Queue = false,
	})

    return 3
end
--------------------------------------------------------------------------------

function CastTeleportBeamPhase(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.tinker_teleport_beam_phase:entindex(),
        Queue = false,
	})

    return 1
end
--------------------------------------------------------------------------------

function CastChainLight(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.chain_light_v2:entindex(),
        Queue = false,
    })
    return 0.5
end
--------------------------------------------------------------------------------

function CastIceShot(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.ice_shot_tinker:entindex(),
        Queue = false,
    })
    return 0.5
end
--------------------------------------------------------------------------------

function CastRedMissile(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.red_missile:entindex(),
        Queue = false,
    })
    return 0.5
end
--------------------------------------------------------------------------------

function Transition(  )

	-- expldoe crystal
	local particle_explode = "particles/tinker/rubick_invoker_emp.vpcf"
	thisEntity.particle_explode_nfx = ParticleManager:CreateParticle( particle_explode, PATTACH_WORLDORIGIN, thisEntity )
	ParticleManager:SetParticleControl(thisEntity.particle_explode_nfx, 0, FindCrystal():GetAbsOrigin() )

	EmitSoundOn( "Hero_Invoker.EMP.Cast", FindCrystal() )
	EmitSoundOn( "Hero_Invoker.EMP.Charge", FindCrystal() )

	Timers:CreateTimer(5, function()

		ParticleManager:DestroyParticle(thisEntity.particle_explode_nfx, false)
		StopSoundOn("Hero_Invoker.EMP.Charge", FindCrystal())
		EmitSoundOn( "Hero_Invoker.EMP.Discharge", FindCrystal())

		Timers:CreateTimer(0.2, function()

			-- find all players, reduce vision to something small
			local units = FindUnitsInRadius(
				thisEntity:GetTeamNumber(),	-- int, your team number
				thisEntity:GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)

			if units ~= nil and #units ~= 0 then
				for _, unit in pairs(units) do
					unit:AddNewModifier(thisEntity, nil, "phase_1_fog", {duration = 7})

					if unit:GetUnitName() == "npc_charge_bot" then
						unit:ForceKill(false)
					end

					if unit:GetUnitName() == "npc_rubick" then
						unit:RemoveSelf()
					end

				end
			end

			-- calculate postions inside arena and put into a table npc_phase2_rock and npc_phase2_crystal

			-- Crystal_Phase2_Spawns
			-- Crystal_Phase1_Spawns_Particles


			-- rock spawning
			local numRocks = 4
			local tRocks = {}
			local centre_point = Vector(-10633,11918,130.33)
			local radius = 1800

			for i = 1, numRocks, 1 do
				local x = RandomInt(centre_point.x - radius, centre_point.x + radius)
				local y = RandomInt(centre_point.y - radius, centre_point.y + radius)
				local spawn_pos = Vector(x,y,131)
				table.insert(tRocks, spawn_pos)
			end

			-- create swirls on the ground
			for _, rock in pairs(tRocks) do
				local particle_rock_spawn = "particles/custom/swirl/dota_swirl.vpcf"
				local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, thisEntity )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, rock )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 1, Vector(5,0,0) )
				ParticleManager:ReleaseParticleIndex(particle_effect_rock_spawn)
			end

			-- crystal spawnin (OLD)
			local numCrystals = 4
			local tRockCrystals = {}

			for i = 1, numCrystals, 1 do
				local x = RandomInt(centre_point.x - radius, centre_point.x + radius)
				local y = RandomInt(centre_point.y - radius, centre_point.y + radius)
				local spawn_pos = Vector(x,y,131)
				table.insert(tRockCrystals, spawn_pos)
			end

			for _, crystal in pairs(tRockCrystals) do
				local particle_rock_spawn = "particles/custom/swirl/dota_swirl.vpcf"
				local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, thisEntity )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, crystal )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 1, Vector(5,0,0) )
				ParticleManager:ReleaseParticleIndex(particle_effect_rock_spawn)
			end

			Timers:CreateTimer(10, function ()
				if Crystal_Phase1_Spawns_Particles ~= 0 then
					for _, crystal_particle in pairs(Crystal_Phase1_Spawns_Particles) do
						ParticleManager:DestroyParticle(crystal_particle,true)
					end
				end
				return false
			end)

			-- play a couple of voice lines from rubick?
			EmitGlobalSound("rubick_rub_arc_respawn_10")

			-- then spawn rocks and crystals inside the arena
			Timers:CreateTimer(5, function()

				-- play a couple of voice lines from tinker?
				EmitGlobalSound("tinker_tink_spawn_05")

				for _, rock in pairs(tRocks) do
					local rock_unit = CreateUnitByName("npc_phase2_rock", rock, true, nil, nil, DOTA_TEAM_BADGUYS)
					rock_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
					rock_unit:SetHullRadius(80)
					--DebugDrawCircle(rock,Vector(0,0,255),128,120,true,360)
					--RandomInt(-1,1)
					--local randomVector = Vector( RandomInt(-1,1), RandomInt(-1,1), 0)
					--rock_unit:SetForwardVector(randomVector)
					KillUnits( rock )
				end

				--for _, crystal in pairs(tRockCrystals) do --Crystal_Phase2_Spawns (OLD)
				if Crystal_Phase2_Spawns ~= 0 then
					for _, crystal in pairs(Crystal_Phase2_Spawns) do
						local crystal_unit = CreateUnitByName("npc_phase2_crystal", crystal, true, nil, nil, DOTA_TEAM_BADGUYS)
						FindClearSpaceForUnit(crystal_unit, crystal, true)
						crystal_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
						crystal_unit:SetHullRadius(80)
						--DebugDrawCircle(crystal,Vector(255,0,0),128,100,true,360)
						-- RandomInt(-1,1)
						--local randomVector = Vector( RandomInt(-1,1), RandomInt(-1,1), 0 )
						--crystal_unit:SetForwardVector(randomVector)
						KillUnits( crystal )
					end
				end

				for _, crystal in pairs(tRockCrystals) do
					local crystal_unit = CreateUnitByName("npc_phase2_crystal", crystal, true, nil, nil, DOTA_TEAM_BADGUYS)
					FindClearSpaceForUnit(crystal_unit, crystal, true)
					crystal_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
					crystal_unit:SetHullRadius(80)
					--DebugDrawCircle(crystal,Vector(255,0,0),128,100,true,360)
					-- RandomInt(-1,1)
					--local randomVector = Vector( RandomInt(-1,1), RandomInt(-1,1), 0 )
					--crystal_unit:SetForwardVector(randomVector)
					KillUnits( crystal )
				end

				return false
			end)

			return false
		end)

		FindCrystal():RemoveSelf()

		return false
	end)

	return 15
end
--------------------------------------------------------------------------------

function KillUnits( pos )

	-- find units
	local units = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),	-- int, your team number
		pos,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		105,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	thisEntity.ability = thisEntity:FindAbilityByName("spawn_rocks")

	-- apply modifier
	if units ~= nil and #units ~= 0 then
		for _, unit in pairs(units) do
			if thisEntity.ability and thisEntity then
                unit:Kill(thisEntity.ability,thisEntity)
            end
		end
	end

end
--------------------------------------------------------------------------------

function FindCrystal()

    local units = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),	-- int, your team number
        thisEntity:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_crystal" then
            return unit
        end
    end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- phase 2 spells
--------------------------------------------------------------------------------

function CastMarch()

	ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.march:entindex(),
        Queue = false,
	})

	return 2
end
--------------------------------------------------------------------------------

function CastLaser()

	local units = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),	-- int, your team number
		thisEntity:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		FIND_FARTHEST,	-- int, order filter
		false	-- bool, can grow cache
	)

	if units == nil or #units == 0 then
		return 1
	else
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = units[RandomInt(1,#units)]:entindex(),
			AbilityIndex = thisEntity.laser:entindex(),
			Queue = false,
		})
		return 4
	end
end
--------------------------------------------------------------------------------

function CastMissile()

	ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.missile:entindex(),
        Queue = false,
	})

	return 2
end
--------------------------------------------------------------------------------

function CastPrisonBeam()

	ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.prisonbeam:entindex(),
        Queue = false,
	})

	return 4
end
--------------------------------------------------------------------------------

function CastLinkCrystals()

	ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.link_crystals_tinker:entindex(),
        Queue = false,
	})

	return 1
end
--------------------------------------------------------------------------------

function CastTeleportPhase2(  )

	local tCrystalsPhase2 = {}

	local units = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),	-- int, your team number
		thisEntity:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		FIND_FARTHEST,	-- int, order filter
		false	-- bool, can grow cache
	)

	if units == nil or #units == 0 then
		return 1
	else

		for _, crystal in pairs(units) do
			if crystal:GetUnitName() == "npc_phase2_crystal" then
				table.insert(tCrystalsPhase2,crystal)
			end
		end

		if tCrystalsPhase2 ~= nil and #tCrystalsPhase2 ~= 0 then

			thisEntity.crystal_health_drain = tCrystalsPhase2[1]

			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity.crystal_health_drain:entindex(),
				AbilityIndex = thisEntity.tinker_teleport_phase2:entindex(),
				Queue = false,
			})

			thisEntity.drain_lock = true
			thisEntity.health_drain_tinker:EndCooldown()

			thisEntity.PHASE = 4
			return 4
		end
	end
end
--------------------------------------------------------------------------------

function CastHealthDrain( )

	if thisEntity.crystal_health_drain == nil then
		thisEntity.PHASE = 3
		return 1
	else
		thisEntity.drain_lock = false
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity.crystal_health_drain:entindex(),
			AbilityIndex = thisEntity.health_drain_tinker:entindex(),
			Queue = false,
		})

		return 4
	end
end
--------------------------------------------------------------------------------
