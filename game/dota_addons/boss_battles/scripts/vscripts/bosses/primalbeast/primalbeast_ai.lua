primalbeast_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- general boss init
	boss_frame_manager:SendBossName()
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:ShowBossManaFrame()
	boss_frame_manager:ShowBossHpFrame()
	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:SetHullRadius(80)

	thisEntity:SetMana(0)
	thisEntity.mana_regen_normal = thisEntity:GetManaRegen()

	AddFOWViewer(DOTA_TEAM_GOODGUYS, thisEntity:GetAbsOrigin(), 8000, 9999, true)

	if SOLO_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "SOLO_MODE_modifier", { duration = -1 } )
    end

	thisEntity.rock_prison = thisEntity:FindAbilityByName( "primal_rock_prison" )
	thisEntity.rock_prison:StartCooldown(25)
	thisEntity.rock_prison_duration = thisEntity.rock_prison:GetLevelSpecialValueFor("duration_rock_fall", thisEntity.rock_prison:GetLevel())

	thisEntity.cone_smash_rocks = thisEntity:FindAbilityByName( "cone_smash_rocks" )
	thisEntity.cone_smash_rocks:StartCooldown(10)

	thisEntity.primal_cave_in = thisEntity:FindAbilityByName( "primal_cave_in" )
	thisEntity.primal_cave_in:StartCooldown(1)
	thisEntity.primal_cave_in_duration = thisEntity.primal_cave_in:GetLevelSpecialValueFor("duration", thisEntity.primal_cave_in:GetLevel())

	thisEntity.primal_beast_shaper_balls = thisEntity:FindAbilityByName( "primal_beast_shaper_balls" )
	thisEntity.primal_beast_shaper_balls:StartCooldown(5)

	thisEntity.spawn_adds = true
	thisEntity.PHASE = 1

	thisEntity:SetContextThink( "PrimalbeastThink", PrimalbeastThink, 0.1 )
end

function PrimalbeastThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity.spawn_adds == true then
		thisEntity.spawn_adds = false
		for i = 1, 1, 1 do
			-- print("thisEntity:GetAbsOrigin().x ", thisEntity:GetAbsOrigin().x)
			local x = RandomInt(thisEntity:GetAbsOrigin().x - 800, thisEntity:GetAbsOrigin().x + 800)
			local y = RandomInt(thisEntity:GetAbsOrigin().y - 800, thisEntity:GetAbsOrigin().y + 800)
			local point = Vector(x,y,thisEntity:GetAbsOrigin().z - 80)
			-- print(point)
			-- DebugDrawCircle(point,Vector(255,0,0),128,100,true,60)
			local golem = CreateUnitByName("npc_primalbeast_baby", point, false, thisEntity, thisEntity, thisEntity:GetTeamNumber())
			local randomVector = Vector( RandomFloat(-1.0,1.0), RandomInt(-1.0,1.0), 0)
			golem:SetForwardVector(randomVector)


		end
	end

	-- state transition
	if thisEntity.PHASE == 2 then
		thisEntity.PHASE = 1
		thisEntity:SetBaseManaRegen(thisEntity.mana_regen_normal)
	end

	if thisEntity:GetManaPercent() == 100 then
		thisEntity.PHASE = 2
		thisEntity:SetBaseManaRegen(0)
	end

	-- states
	-- normal state
    if thisEntity.PHASE == 1 then

		if thisEntity.rock_prison:IsFullyCastable() and thisEntity.rock_prison:IsCooldownReady() and thisEntity.rock_prison:IsInAbilityPhase() == false then
			return CastRockPrison()
		end

		if thisEntity.primal_beast_shaper_balls:IsFullyCastable() and thisEntity.primal_beast_shaper_balls:IsCooldownReady() and thisEntity.primal_beast_shaper_balls:IsInAbilityPhase() == false then
			return CastShaperBalls()
		end

		if thisEntity.cone_smash_rocks:IsFullyCastable() and thisEntity.cone_smash_rocks:IsCooldownReady() and thisEntity.cone_smash_rocks:IsInAbilityPhase() == false then
			return CastConeSmash()
		end

	end

	-- cave in state
	if thisEntity.PHASE == 2 then

		if thisEntity.primal_cave_in:IsFullyCastable() and thisEntity.primal_cave_in:IsCooldownReady() and thisEntity.primal_cave_in:IsInAbilityPhase() == false then
			return CastCaveIn()
		end

	end


	return 1
end

function CastShaperBalls()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.primal_beast_shaper_balls:entindex(),
		Queue = false,
	})

	return 1
end

function CastRockPrison()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.rock_prison:entindex(),
		Queue = false,
	})

	return thisEntity.rock_prison_duration
end

function CastConeSmash()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.cone_smash_rocks:entindex(),
		Queue = false,
	})

	return 1
end

function CastCaveIn()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.primal_cave_in:entindex(),
		Queue = false,
	})

	return thisEntity.primal_cave_in_duration
end