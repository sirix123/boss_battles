gyro_ai = class({})
LinkLuaModifier( "oil_ignite_fire_puddle_thinker", "bosses/gyrocopter/oil_ignite_fire_puddle_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flak_cannon", "bosses/gyrocopter/modifier_flak_cannon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disable_movement_abilities", "player/generic/modifier_generic_disable_movement_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disable_auto_attack", "core/modifier_generic_disable_auto_attack", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	_G.Oil_Puddles = {}
	_G.Fire_Puddles = {}

	-- general boss init
	boss_frame_manager:SendBossName()
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:HideBossManaFrame()
	boss_frame_manager:ShowBossHpFrame()
	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:SetHullRadius(80)

	--[[ spawn water gun on the ground left between players and gyro
	for _, hero in ipairs(HERO_LIST) do

		hero:AddItemByName("item_water_gun")

		--[[local newItem = CreateItem("item_water_gun", hero, nil)
		local obj = CreateItemOnPositionForLaunch( Vector(-13051,1045,131), newItem )
		obj:SetModelScale(1.3)

		local particle = "particles/techies/etherial_targetglow_repeat.vpcf"
		local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, obj)
		ParticleManager:SetParticleControl(nfx, 1, obj:GetAbsOrigin())
		obj:SetForwardVector( Vector( RandomFloat(-1, 1) , RandomFloat(-1, 1), RandomFloat(-1, 1) ) )]]
	--end

	AddFOWViewer(DOTA_TEAM_GOODGUYS, thisEntity:GetAbsOrigin(), 8000, 9999, true)

	-- spell init
	thisEntity.swoop = thisEntity:FindAbilityByName( "swoop_v2" )
	thisEntity.swoop:StartCooldown(10)
	thisEntity.swoop_speed = thisEntity.swoop:GetLevelSpecialValueFor("charge_speed", thisEntity.swoop:GetLevel())
	thisEntity.barrage_duration = thisEntity.swoop:GetLevelSpecialValueFor("barrage_duration", thisEntity.swoop:GetLevel())

	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.flak_cannon:StartCooldown(25)
	thisEntity.flak_cannon_duration = thisEntity.flak_cannon:GetLevelSpecialValueFor("duration", thisEntity.flak_cannon:GetLevel())
	thisEntity.circle_timer_running = false

	thisEntity.cannon_ball = thisEntity:FindAbilityByName( "cannon_ball" )
	thisEntity.cannon_ball:StartCooldown(5)

	thisEntity.flame_thrower = thisEntity:FindAbilityByName( "flame_thrower" )
	thisEntity.flame_thrower:StartCooldown(12)
	thisEntity.flame_thrower_duration = thisEntity.flame_thrower:GetLevelSpecialValueFor("duration", thisEntity.flame_thrower:GetLevel())

	thisEntity.gattling_gun = thisEntity:FindAbilityByName("gattling_gun")
	thisEntity.gattling_gun:StartCooldown(25)

	thisEntity.percent_total_health = thisEntity:GetBaseMaxHealth() / 4 -- 1/4 of max (50k if 200kmax)
	thisEntity.gyro_call_down_count_tracker = 0
	thisEntity.call_down_phase_over = false
	thisEntity.gyro_in_place = false
	thisEntity.creating_rocks = false

	thisEntity.flee = thisEntity:FindAbilityByName( "flee_v2" )
	thisEntity.flee:StartCooldown(15)
	thisEntity.flee_speed = thisEntity.flee:GetLevelSpecialValueFor("speed", thisEntity.flee:GetLevel())

	thisEntity.fire_gren = thisEntity:FindAbilityByName( "fire_cross_grenade" )
	thisEntity.fire_gren:StartCooldown(2)

	thisEntity.spawn_cleaning_bot = thisEntity:FindAbilityByName( "spawn_cleaning_bot" )

	thisEntity.intermission_flee = thisEntity:FindAbilityByName( "intermission_flee" )
	thisEntity.intermission_flee_return_value = thisEntity.intermission_flee:GetLevelSpecialValueFor("return_value", thisEntity.intermission_flee:GetLevel())
	thisEntity.gyro_call_down_ring_gap = thisEntity.intermission_flee:GetLevelSpecialValueFor("gap_between_rings", thisEntity.intermission_flee:GetLevel())
	thisEntity.max_rings = thisEntity.intermission_flee:GetLevelSpecialValueFor("max_rings", thisEntity.intermission_flee:GetLevel())

	thisEntity.homing_missile = thisEntity:FindAbilityByName( "gyro_intermission_homing_missile" )
	thisEntity.unexploded_rockets = {}

	thisEntity.tornado = thisEntity:FindAbilityByName( "tornado_intermission_phase" )

	BossHpMonitorCleaningBotSpawner()


	-- flee point calculations
	local ArenaTop = 2700
	local ArenaBot = 425
	local ArenaLeft = -13600
	local ArenaRight = -11000
	local AreanMiddle = Vector((ArenaLeft/2)+(ArenaRight/2), (ArenaTop/2) + (ArenaBot/2), 132) --MID POINT FORMULA: -- (ArenaTop / 2 ) + (ArenaBot / 2)
	thisEntity.GyroArenaLocations = {
		Vector(AreanMiddle.x,ArenaTop,132),
		Vector(ArenaRight,ArenaTop,132),
		Vector(ArenaRight,AreanMiddle.y,132),
		Vector(ArenaRight,ArenaBot,132),
		Vector(AreanMiddle.x,ArenaBot,132),
		Vector(ArenaLeft,ArenaBot,132),
		Vector(ArenaLeft,AreanMiddle.y,132),
		Vector(ArenaLeft,ArenaTop,132),
		Vector(ArenaLeft,ArenaTop,132),
		AreanMiddle,
	}

	--[[for _, point in pairs(thisEntity.GyroArenaLocations) do
		DebugDrawCircle(point,Vector(255,255,255),128,100,true,60)
	end]]

	thisEntity.GyroIntermissionLocations = {
		Vector(-13282,178,132),
		Vector(-13716,916,132),
		Vector(-13551,1932,132),
		Vector(-13495,2593,132),
		Vector(-12857,2991,132),
		Vector(-11795,2980,132),
		Vector(-11071,2720,132),
		Vector(-10966,1806,132),
		Vector(-11048,985,132),
		Vector(-10939,152,132),
		Vector(-12093,206,132),
	}

	-- phase init
	thisEntity.PHASE = 1

	-- elvel tracker
	thisEntity.level_tracker = 1

	thisEntity:SetContextThink( "GyroThink", GyroThink, 0.1 )
end

function GyroThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity:IsStunned() == true then
		return 2
	end

	--[[

	STATES HANDLERS

	phase 1 = normal phase
	phase 2 = flak cannon phase (fly around in circle)
	]]

	--print("phase ",thisEntity.PHASE)

	--[[

	LEVEL UP HANDLER / phase 3

	]]

	if thisEntity:HasModifier("modifier_rooted") then
		thisEntity:RemoveModifierByName("modifier_rooted")
	end

	if thisEntity:GetHealthPercent() < 75 and thisEntity:GetHealthPercent() > 50 and thisEntity.gyro_call_down_count_tracker == 0 and thisEntity.PHASE == 1 then
		thisEntity.gyro_call_down_count_tracker = thisEntity.gyro_call_down_count_tracker + 1
		thisEntity.level_tracker = 2
		LevelUpAbilities()
		thisEntity:AddNewModifier( nil, nil, "modifier_generic_disable_auto_attack", { duration = -1 })
		thisEntity.PHASE = 2
	elseif thisEntity:GetHealthPercent() < 50 and thisEntity:GetHealthPercent() > 25 and thisEntity.gyro_call_down_count_tracker == 1 and thisEntity.PHASE == 1 then
		thisEntity.gyro_call_down_count_tracker = thisEntity.gyro_call_down_count_tracker + 1
		thisEntity.level_tracker = 3
		LevelUpAbilities()
		thisEntity:AddNewModifier( nil, nil, "modifier_generic_disable_auto_attack", { duration = -1 })
		thisEntity.PHASE = 2
	elseif thisEntity:GetHealthPercent() < 25 and thisEntity:GetHealthPercent() > 0 and thisEntity.gyro_call_down_count_tracker == 2 and thisEntity.PHASE == 1 then
		thisEntity.gyro_call_down_count_tracker = thisEntity.gyro_call_down_count_tracker + 1
		thisEntity.level_tracker = 4
		LevelUpAbilities()
		thisEntity:AddNewModifier( nil, nil, "modifier_generic_disable_auto_attack", { duration = -1 })
		thisEntity.PHASE = 2
	end

	if thisEntity.PHASE == 2 and thisEntity.circle_timer_running == false then
		--print("phase 2 starting (intermission)")

		thisEntity:EmitSound("Hero_Gyrocopter.FlackCannon.Activate")

		-- spawn the rockets
		if thisEntity.homing_missile:IsFullyCastable() and thisEntity.homing_missile:IsCooldownReady() and thisEntity.homing_missile:IsInAbilityPhase() == false then
			CastMissile()
		end

		thisEntity:AddNewModifier(
            thisEntity, -- player source
            thisEntity.flak_cannon, -- ability source
            "modifier_flak_cannon", -- modifier name
            {
                duration = -1,
            })

		CricleTimer()

		thisEntity.PHASE = 3
	end


	if thisEntity.PHASE == 3 and thisEntity.circle_timer_running == false then
		--print("phase 1 starting")

		RandomiseCoolDowns( )

		if thisEntity:HasModifier("modifier_flak_cannon") then
			thisEntity:RemoveModifierByName("modifier_flak_cannon")
		end
		if thisEntity:HasModifier("modifier_generic_disable_auto_attack") then
			thisEntity:RemoveModifierByName("modifier_generic_disable_auto_attack")
		end
		if thisEntity:HasModifier("gyro_homing_missile_stun_check") then
			thisEntity:RemoveModifierByName("gyro_homing_missile_stun_check")
		end

		-- if there are un-exploded rockets, explode them,
		local rockets = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),
			thisEntity:GetAbsOrigin(),
			nil,
			5000,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false )

		if rockets ~= nil then
			--print("trying to find rockets")
			for _, rocket in pairs(rockets) do
				--print("unit name = ",rocket:GetUnitName())
				if rocket:GetUnitName() == "npc_dota_gyrocopter_homing_missile" then

					rocket:ForceKill(false)
				end
			end
		end

		thisEntity.PHASE = 1
	end

	if thisEntity.PHASE == 3 and thisEntity.circle_timer_running == true  then
		--print("check if im getting hit by the bombs")

		local stacks = 0
		if thisEntity:HasModifier("gyro_homing_missile_stun_check") then
			stacks = thisEntity:GetModifierStackCount("gyro_homing_missile_stun_check", thisEntity)
		end

		if stacks >= 3 then
			thisEntity.circle_timer_running = false
		end

		if thisEntity.tornado:IsFullyCastable() and thisEntity.tornado:IsCooldownReady() and thisEntity.tornado:IsInAbilityPhase() == false then
			return CastTornado()
		end

		if thisEntity.fire_gren:IsFullyCastable() and thisEntity.fire_gren:IsCooldownReady() and thisEntity.fire_gren:IsInAbilityPhase() == false then
			return CastFireGrenade()
		end

	end


	--[[

	STATES

	]]

	if thisEntity.PHASE == 1 then

		if thisEntity.fire_gren:IsFullyCastable() and thisEntity.fire_gren:IsCooldownReady() and thisEntity.fire_gren:IsInAbilityPhase() == false then
			return CastFireGrenade()
		end

		if thisEntity.swoop:IsFullyCastable() and thisEntity.swoop:IsCooldownReady() and thisEntity.swoop:IsInAbilityPhase() == false then
			return CastSwoop( FindFurthestPlayer() )
		end

		if thisEntity.gattling_gun:IsFullyCastable() and thisEntity.gattling_gun:IsCooldownReady() and thisEntity.gattling_gun:IsInAbilityPhase() == false and thisEntity.gattling_gun:IsChanneling() == false then
			return CastGattlingGun( )
		end

		if thisEntity.cannon_ball:IsFullyCastable() and thisEntity.cannon_ball:IsCooldownReady() and thisEntity.cannon_ball:IsInAbilityPhase() == false then
			local randomplayer = FindRandomPlayer()
			if randomplayer == nil then
				return 1
			else
				return CastCannonBall( randomplayer:GetAbsOrigin() )
			end
		end

		if thisEntity.flame_thrower:IsFullyCastable() and thisEntity.flame_thrower:IsCooldownReady() and thisEntity.flame_thrower:IsInAbilityPhase() == false then
			return CastFlameThrower()
		end

		if thisEntity.flee:IsFullyCastable() and thisEntity.flee:IsCooldownReady() and thisEntity.flee:IsInAbilityPhase() == false then
			return CastFlee( thisEntity.GyroArenaLocations[RandomInt(1,#thisEntity.GyroArenaLocations)] )
		end

	end

	return 1
end
--------------------------------------------------------------------------------

function CastSwoop( hTarget )

	if hTarget == nil then
		return 0.1
	end

	local distance = ( thisEntity:GetAbsOrigin() - hTarget:GetAbsOrigin() ):Length2D()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.swoop:entindex(),
		Queue = false,
	})

    local velocity = thisEntity.swoop_speed
    local time = ( distance / velocity ) + thisEntity.barrage_duration + 1

	thisEntity.cannon_ball:StartCooldown(RandomInt(10,15))

	return time
end
--------------------------------------------------------------------------------

function CastFlee( vLocation )
	if vLocation == nil then
		return 0.1
	end

	local distance = ( thisEntity:GetAbsOrigin() - vLocation ):Length2D()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.flee:entindex(),
		Position = vLocation,
		Queue = false,
	})

	local velocity = thisEntity.flee_speed
    local time = ( distance / velocity )

	return time + 3
end
--------------------------------------------------------------------------------

function CastCannonBall( vLocation )

	if vLocation == nil then
		return 0.1
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.cannon_ball:entindex(),
		Position = vLocation,
		Queue = false,
	})

	return 2
end 
--------------------------------------------------------------------------------

function CastFlameThrower()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.flame_thrower:entindex(),
		Queue = false,
	})

	IgniteOil()

	return thisEntity.flame_thrower_duration + 2
end
--------------------------------------------------------------------------------

function CastMissile()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.homing_missile:entindex(),
		Queue = false,
	})

	return 1
end
--------------------------------------------------------------------------------

function CastTornado()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.tornado:entindex(),
		Queue = false,
	})

	return 1
end
--------------------------------------------------------------------------------

function CastCleaner()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.spawn_cleaning_bot:entindex(),
		Queue = false,
	})

	return 1
end
--------------------------------------------------------------------------------

function CastFireGrenade()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.fire_gren:entindex(),
		Queue = false,
	})

	thisEntity.fire_gren:StartCooldown(2)

	return 0.5
end
--------------------------------------------------------------------------------

function CastGattlingGun()

	-- root self in place
	thisEntity:AddNewModifier( nil, nil, "modifier_rooted", { duration = -1 })

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.gattling_gun:entindex(),
		Queue = 0,
	})

	return thisEntity.gattling_gun:GetChannelTime()
end
--------------------------------------------------------------------------------

function FindFurthestPlayer()

	-- find random player
	local enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #enemies ~= 0 and enemies ~= nil then
		return 	enemies[RandomInt(1,#enemies)]			--enemies[#enemies]
	else
		return nil
	end
end
--------------------------------------------------------------------------------

function FindRandomPlayer()

	-- find random player
	local enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #enemies ~= 0 and enemies ~= nil then
		return enemies[RandomInt(1,#enemies)]
	else
		return nil
	end
end
--------------------------------------------------------------------------------

function IgniteOil()

	Timers:CreateTimer(2,function()
		if IsValidEntity(thisEntity) == false then return false end
		for _, oilThinker in ipairs(_G.Oil_Puddles) do
			if oilThinker and not oilThinker:IsNull() then

				local fire_puddle = CreateModifierThinker(
					thisEntity,
					self,
					"oil_ignite_fire_puddle_thinker",
					{
						target_x = oilThinker:GetAbsOrigin().x,
						target_y = oilThinker:GetAbsOrigin().y,
						target_z = oilThinker:GetAbsOrigin().z,
					},
					oilThinker:GetAbsOrigin(),
					thisEntity:GetTeamNumber(),
					false
					)

					table.insert(_G.Fire_Puddles, fire_puddle)

				oilThinker:RemoveSelf()
			end
		end

		_G.Oil_Puddles = {}

	end)
end
--------------------------------------------------------------------------------

function CricleTimer()
    thisEntity.circle_timer_running = true
	local count = 0
	local max_duration = 35

	-- start countdown
	if thisEntity.particle ~= nil then
		ParticleManager:DestroyParticle(thisEntity.particle,true)
	end

    thisEntity.movement_timer = Timers:CreateTimer(function()
        if IsValidEntity(thisEntity) == false then return false end

        if thisEntity == nil or count >= max_duration or thisEntity.circle_timer_running == false  then
            return false
        end

		-- pick two random spots from this table that are x units away from each other
		local caster_location = thisEntity:GetAbsOrigin()
		local spot_1 = thisEntity.GyroArenaLocations[RandomInt(1,#thisEntity.GyroArenaLocations)]

		while (caster_location - spot_1):Length2D() < 800 do
			spot_1 = thisEntity.GyroArenaLocations[RandomInt(1,#thisEntity.GyroArenaLocations)]
		end

        thisEntity:MoveToPosition(spot_1)

		local distance = ( thisEntity:GetAbsOrigin() - spot_1 ):Length2D()
		local velocity = thisEntity:GetIdealSpeed()
		local time = distance / velocity

		count = count + 1

        return time
    end)

	-- particle timer count
	thisEntity.particle_count = 35
	thisEntity.particle_timer = ParticleManager:CreateParticle("particles/gyrocopter/gyro_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, thisEntity)
	Timers:CreateTimer(function()
        if IsValidEntity(thisEntity) == false then return false end

        if thisEntity == nil or thisEntity.particle_count <= 0 or thisEntity.circle_timer_running == false then
			--print("circle timer ending")
			if thisEntity.movement_timer ~= nil then
				Timers:RemoveTimer(thisEntity.movement_timer)
			end
            thisEntity.circle_timer_running = false

			if thisEntity.particle_timer ~= nil then
				ParticleManager:DestroyParticle(thisEntity.particle_timer,true)
			end

            return false
        end

		-- update the timer particle
		if thisEntity.particle_count >= 10 and thisEntity.particle_count < 20 then
			thisEntity.digitX = 1
		elseif thisEntity.particle_count >= 20 and thisEntity.particle_count < 30 then
			thisEntity.digitX = 2
		elseif thisEntity.particle_count >= 30 and thisEntity.particle_count < 40 then
			thisEntity.digitX = 3
		elseif thisEntity.particle_count >= 40 and thisEntity.particle_count < 50 then
			thisEntity.digitX = 4
		else 
			thisEntity.digitX = 0
		end

		local digitY = thisEntity.particle_count % 10

		ParticleManager:SetParticleControl(thisEntity.particle_timer, 0, thisEntity:GetAbsOrigin())
		ParticleManager:SetParticleControl(thisEntity.particle_timer, 1, Vector( thisEntity.digitX, digitY, 0 ))

		thisEntity.particle_count = thisEntity.particle_count - 1

        return 1
    end)

end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	thisEntity.swoop:SetLevel(thisEntity.level_tracker)
	thisEntity.cannon_ball:SetLevel(thisEntity.level_tracker)
	thisEntity.flame_thrower:SetLevel(thisEntity.level_tracker)
	thisEntity.flee:SetLevel(thisEntity.level_tracker)
	thisEntity.intermission_flee:SetLevel(thisEntity.level_tracker)

	thisEntity.intermission_flee_return_value = thisEntity.intermission_flee:GetLevelSpecialValueFor("return_value", thisEntity.intermission_flee:GetLevel())
	thisEntity.gyro_call_down_ring_gap = thisEntity.intermission_flee:GetLevelSpecialValueFor("gap_between_rings", thisEntity.intermission_flee:GetLevel())
	thisEntity.max_rings = thisEntity.intermission_flee:GetLevelSpecialValueFor("max_rings", thisEntity.intermission_flee:GetLevel())
	thisEntity.flame_thrower_duration = thisEntity.flame_thrower:GetLevelSpecialValueFor("duration", thisEntity.flame_thrower:GetLevel())
	thisEntity.swoop_speed = thisEntity.swoop:GetLevelSpecialValueFor("charge_speed", thisEntity.swoop:GetLevel())
	thisEntity.barrage_duration = thisEntity.swoop:GetLevelSpecialValueFor("barrage_duration", thisEntity.swoop:GetLevel())

end
--------------------------------------------------------------------------------

function RandomiseCoolDowns( )
	thisEntity.swoop:StartCooldown(RandomInt(1,5))
	thisEntity.cannon_ball:StartCooldown(RandomInt(5,10))
	thisEntity.flame_thrower:StartCooldown(RandomInt(10,20))
	thisEntity.flee:StartCooldown(RandomInt(20,30))
end
------------------------------------------------------------------------------------------------------------------------------

function BossHpMonitorCleaningBotSpawner()

	local count = 0
	local bot_counter = 0
	local percent_hp_missing_to_summon = 0.09
	local hp_amount_to_summon = thisEntity:GetMaxHealth() * percent_hp_missing_to_summon

	-- this timer checks the boss hp very freq and increments a count everytime %5 of the health missing
	Timers:CreateTimer(function()
		if IsValidEntity(thisEntity) ==  false then
			return false
		end

		--print("thisEntity:GetHealth(): ",thisEntity:GetHealth(),"( hp_amount_to_summon * bot_counter ) - thisEntity:GetMaxHealth(): ",( hp_amount_to_summon * bot_counter ) - thisEntity:GetMaxHealth())

		if thisEntity:GetHealth() < ( thisEntity:GetMaxHealth() - ( hp_amount_to_summon * bot_counter )  ) then
			--print("bot_counter ",bot_counter)
			bot_counter = bot_counter + 1
			count = count + 1
		end

		return 0.01
	end)

	-- this timer handles summoning the cleaning bots, decrements the count every time one is summoned
	Timers:CreateTimer(function()
		if IsValidEntity(thisEntity) ==  false then
			return false
		end

		--print("count ", count)

		if count > 0 then
			--print("summoning bot")
			if thisEntity.spawn_cleaning_bot:IsFullyCastable() and thisEntity.spawn_cleaning_bot:IsCooldownReady() and thisEntity.spawn_cleaning_bot:IsInAbilityPhase() == false then
				CastCleaner()
			end

			count = count - 1
		end

		return 2.0
	end)
end
------------------------------------------------------------------------------------------------------------------------------
