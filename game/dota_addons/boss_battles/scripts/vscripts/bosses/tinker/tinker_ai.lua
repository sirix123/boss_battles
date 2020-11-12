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
	thisEntity.stack_count = 1
	thisEntity.max_beam_stacks = 1

	thisEntity.rearm = true

	thisEntity:SetHullRadius(100)

	thisEntity.chain_light_v2 = thisEntity:FindAbilityByName( "chain_light_v2" )
	thisEntity.chain_light_v2:StartCooldown(thisEntity.chain_light_v2:GetCooldown(thisEntity.chain_light_v2:GetLevel()))

	thisEntity.ice_shot_tinker = thisEntity:FindAbilityByName( "ice_shot_tinker" )
	thisEntity.ice_shot_tinker:StartCooldown(thisEntity.ice_shot_tinker:GetCooldown(thisEntity.ice_shot_tinker:GetLevel()))

	thisEntity.summon_bird = thisEntity:FindAbilityByName( "summon_bird" )
	thisEntity.summon_bird:StartCooldown(thisEntity.summon_bird:GetCooldown(thisEntity.summon_bird:GetLevel()))

	thisEntity.tinker_teleport = thisEntity:FindAbilityByName( "tinker_teleport" )
	thisEntity.tinker_teleport:StartCooldown(thisEntity.tinker_teleport:GetCooldown(thisEntity.tinker_teleport:GetLevel()))

	thisEntity.missile = thisEntity:FindAbilityByName( "missile" )
	thisEntity.laser = thisEntity:FindAbilityByName( "laser" )
	thisEntity.march = thisEntity:FindAbilityByName( "march" )
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
	elseif thisEntity.PHASE ~= 3 then
		thisEntity.PHASE = 1
	end

	if thisEntity.stack_count == thisEntity.max_beam_stacks then
		thisEntity:RemoveModifierByName("shield_effect")
		thisEntity:RemoveModifierByName("beam_counter")
		thisEntity:RemoveModifierByName("modifier_invulnerable")
		thisEntity.stack_count = 0
		thisEntity.PHASE = 3

		-- transition to phase 3, fog reduce etc
		return Transition()
	end

	-- phase 1
	if thisEntity.PHASE == 1 then
		if thisEntity.tinker_teleport ~= nil and thisEntity.tinker_teleport:IsFullyCastable() and thisEntity.tinker_teleport:IsCooldownReady() then
			return CastTeleport()
		end

		if thisEntity.chain_light_v2 ~= nil and thisEntity.chain_light_v2:IsFullyCastable() and thisEntity.chain_light_v2:IsCooldownReady() and thisEntity.stack_count >= 3 then
			return CastChainLight()
		end

		if thisEntity.ice_shot_tinker ~= nil and thisEntity.ice_shot_tinker:IsFullyCastable() and thisEntity.ice_shot_tinker:IsCooldownReady() then
			return CastIceShot()
		end

		if thisEntity.summon_bird ~= nil and thisEntity.summon_bird:IsFullyCastable() and thisEntity.summon_bird:IsCooldownReady() and thisEntity.stack_count >= 1 then
			return CastSummonBird()
		end

	end

	-- crystal phase
	if thisEntity.PHASE == 2 then

		Timers:CreateTimer(12,function()
			if thisEntity.stop_timers == true then
				return false
			end

			if thisEntity.tinker_teleport ~= nil and thisEntity.tinker_teleport:IsFullyCastable() and thisEntity.tinker_teleport:IsCooldownReady() then
				return CastTeleport()
			end

			return false
		end)
	end

	-- phase 2
	if thisEntity.PHASE == 3 then

		if thisEntity.march ~= nil and thisEntity.march:IsFullyCastable() and thisEntity.march:IsCooldownReady() and thisEntity.march:IsInAbilityPhase() == false then
			return CastMarch()
		end

		--print("laser cd is? ", thisEntity.laser:GetCooldownTimeRemaining())
		if thisEntity.laser ~= nil and thisEntity.laser:IsFullyCastable() and thisEntity.laser:IsCooldownReady() and thisEntity.laser:IsInAbilityPhase() == false then
			--print("casting laser")
			--return CastLaser()
		end

		if thisEntity.prisonbeam ~= nil and thisEntity.prisonbeam:IsFullyCastable() and thisEntity.prisonbeam:IsCooldownReady() and thisEntity.prisonbeam:IsInAbilityPhase() == false then
			return CastPrisonBeam()
		end

		if thisEntity.missile ~= nil and thisEntity.missile:IsFullyCastable() and thisEntity.missile:IsCooldownReady() and thisEntity.missile:IsInAbilityPhase() == false then
			return CastMissile()
		end

	end

	return 0.5
end
--------------------------------------------------------------------------------

function CastTeleport(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.tinker_teleport:entindex(),
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
    return 1
end
--------------------------------------------------------------------------------

function CastIceShot(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.ice_shot_tinker:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastSummonBird(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_bird:entindex(),
        Queue = false,
    })
    return 1
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
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)

			if units ~= nil and #units ~= 0 then
				for _, unit in pairs(units) do
					unit:AddNewModifier(thisEntity, nil, "phase_1_fog", {duration = 7})
				end
			end

			-- calculate postions inside arena and put into a table npc_phase2_rock and npc_phase2_crystal
			local numRocks = 10
			local numCrystals = 5
			local tRockCrystals = {}
			local tRocks = {}

			local centre_point = Vector(-10633,11918,130.33)
			local radius = 1800

			for i = 1, numRocks, 1 do
				local x = RandomInt(centre_point.x - radius, centre_point.x + radius)
				local y = RandomInt(centre_point.y - radius, centre_point.y + radius)
				local spawn_pos = Vector(x,y,131)
				table.insert(tRocks, spawn_pos)
			end

			for i = 1, numCrystals, 1 do
				local x = RandomInt(centre_point.x - radius, centre_point.x + radius)
				local y = RandomInt(centre_point.y - radius, centre_point.y + radius)
				local spawn_pos = Vector(x,y,131)
				table.insert(tRockCrystals, spawn_pos)
			end

			-- create swirls on the ground
			for _, rock in pairs(tRocks) do
				local particle_rock_spawn = "particles/custom/swirl/dota_swirl.vpcf"
				local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, thisEntity )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, rock )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 1, Vector(5,0,0) )
				ParticleManager:ReleaseParticleIndex(particle_effect_rock_spawn)
			end

			for _, crystal in pairs(tRockCrystals) do
				local particle_rock_spawn = "particles/custom/swirl/dota_swirl.vpcf"
				local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, thisEntity )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, crystal )
				ParticleManager:SetParticleControl(particle_effect_rock_spawn, 1, Vector(5,0,0) )
				ParticleManager:ReleaseParticleIndex(particle_effect_rock_spawn)
			end

			-- play a couple of voice lines from rubick?
			EmitGlobalSound("rubick_rub_arc_respawn_10")

			-- then spawn rocks and crystals inside the arena
			Timers:CreateTimer(5, function()

				-- play a couple of voice lines from tinker?
				EmitGlobalSound("tinker_tink_spawn_05")

				for _, rock in pairs(tRocks) do
					local rock_unit = CreateUnitByName("npc_phase2_rock", rock, true, nil, nil, DOTA_TEAM_BADGUYS)
					rock_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
					rock_unit:SetHullRadius(160)
					DebugDrawCircle(rock,Vector(0,0,255),128,160,true,360)
					--RandomInt(-1,1)
					--local randomVector = Vector( RandomInt(-1,1), RandomInt(-1,1), 0)
					--rock_unit:SetForwardVector(randomVector)
					KillUnits( rock )
				end

				for _, crystal in pairs(tRockCrystals) do
					local crystal_unit = CreateUnitByName("npc_phase2_crystal", crystal, true, nil, nil, DOTA_TEAM_BADGUYS)
					crystal_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
					crystal_unit:SetHullRadius(50)
					--DebugDrawCircle(crystal_unit,Vector(0,0,255),128,50,true,360)
					-- RandomInt(-1,1)
					local randomVector = Vector( RandomInt(-1,1), RandomInt(-1,1), 0 )
					crystal_unit:SetForwardVector(randomVector)
					KillUnits( crystal )
				end

				return false
			end)

			return false
		end)

		FindCrystal():RemoveSelf()

		return false
	end)

	return 10
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

	-- apply modifier
	if units ~= nil and #units ~= 0 then
		for _, unit in pairs(units) do
			unit:ForceKill(false)
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
function CastRearm(spell)
	-- reset cd
	spell:EndCooldown()

	-- voiceline
	EmitGlobalSound("tinker_tink_ability_rearm_01")

	-- sound
	EmitSoundOn("Hero_Tinker.Rearm",thisEntity)

	-- animation
	thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_TINKER_REARM1, 1.0)

	-- particle
	local particle = "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"
	local particle_rearm = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, thisEntity )
	ParticleManager:SetParticleControl(particle_rearm, 0, thisEntity:GetAbsOrigin() )

	-- debugg
	print("rearming")
	print("spell name ", spell:GetAbilityName())
	print("spell cd ", spell:GetCooldownTimeRemaining())

	return 4
end
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
	ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.laser:entindex(),
        Queue = false,
	})

	Timers:CreateTimer(thisEntity.laser:GetCastPoint() + 0.5, function() -- use the spells castpoint here + buffer?
	local rearmChance = RandomInt(1,2)

		if rearmChance == 2 then
			CastRearm(thisEntity.laser)
		end

		return false
	end)

	return 4
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




	return 2
end
--------------------------------------------------------------------------------

