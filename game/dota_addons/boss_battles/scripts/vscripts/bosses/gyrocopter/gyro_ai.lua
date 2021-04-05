gyro_ai = class({})
LinkLuaModifier( "oil_ignite_fire_puddle_thinker", "bosses/gyrocopter/oil_ignite_fire_puddle_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "whirlwind_phase_handler", "bosses/gyrocopter/whirlwind_phase_handler", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "gyro_bubble", "bosses/gyrocopter/gyro_bubble", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flak_cannon", "bosses/gyrocopter/modifier_flak_cannon", LUA_MODIFIER_MOTION_NONE )

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

	-- spawn water gun on the ground left between players and gyro
	for _, hero in ipairs(HERO_LIST) do

		hero:AddItemByName("item_water_gun")

		--[[local newItem = CreateItem("item_water_gun", hero, nil)
		local obj = CreateItemOnPositionForLaunch( Vector(-13051,1045,131), newItem )
		obj:SetModelScale(1.3)

		local particle = "particles/techies/etherial_targetglow_repeat.vpcf"
		local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, obj)
		ParticleManager:SetParticleControl(nfx, 1, obj:GetAbsOrigin())
		obj:SetForwardVector( Vector( RandomFloat(-1, 1) , RandomFloat(-1, 1), RandomFloat(-1, 1) ) )]]
	end

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

	thisEntity.whirlwind = thisEntity:FindAbilityByName( "whirlwind_v2" )
	thisEntity.percent_total_health = thisEntity:GetBaseMaxHealth() / 4 -- 1/4 of max (50k if 200kmax)
	thisEntity.whirlwind_count_tracker = 1
	thisEntity.phase_2_count = 0
	thisEntity.createParticleOnce = true
	thisEntity.bubble_kill_time = 20

	thisEntity.gyro_call_down = thisEntity:FindAbilityByName( "gyro_call_down" )

	thisEntity.flee = thisEntity:FindAbilityByName( "flee_v2" )
	thisEntity.flee:StartCooldown(15)
	thisEntity.flee_speed = thisEntity.flee:GetLevelSpecialValueFor("speed", thisEntity.flee:GetLevel())

	-- flee point calculations
	local ArenaTop = 3025
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

	--[[

	LEVEL UP HANDLER

	]]

	if thisEntity:GetHealthPercent() < 75 and thisEntity:GetHealthPercent() > 50 then
		thisEntity.level_tracker = 2
		LevelUpAbilities()
	elseif thisEntity:GetHealthPercent() < 50 and thisEntity:GetHealthPercent() > 25 then
		thisEntity.level_tracker = 3
		LevelUpAbilities()
	elseif thisEntity:GetHealthPercent() < 25 and thisEntity:GetHealthPercent() > 0 then
		thisEntity.level_tracker = 4
		LevelUpAbilities()
	end

	--[[

	STATES HANDLERS

	-- whirldwind modifier removed in whirlwind spell when its finished

	phase 1 = normal phase
	phase 2 = whirlwind attack
	phase 3 = bubble after phase 2
	phase 4 = flak cannon phase (fly around in circle)

	]]

	--print("phase ",thisEntity.PHASE)

	if thisEntity.PHASE == 3 and thisEntity:HasModifier("gyro_bubble") == false then
		print("phase 1 starting")

		if thisEntity:HasModifier("modifier_generic_disable_auto_attack") == true then
			thisEntity:RemoveModifier("modifier_generic_disable_auto_attack")
		end

		thisEntity:RemoveModifierByName("modifier_rooted")
		thisEntity.gyro_call_down:EndCooldown()
		thisEntity.PHASE = 1
	end

	if thisEntity:GetHealthDeficit() > thisEntity.percent_total_health then
		print("phase 2 starting")
		thisEntity.createParticleOnce = true
		thisEntity.whirlwind_count_tracker = thisEntity.whirlwind_count_tracker + 1
		thisEntity.percent_total_health = thisEntity.percent_total_health * thisEntity.whirlwind_count_tracker
		thisEntity:AddNewModifier( nil, nil, "modifier_generic_disable_auto_attack", { duration = -1 })
		thisEntity.PHASE = 2
	end

	if thisEntity.phase_2_count == 3 then
		print("phase 3 starting")
		thisEntity:AddNewModifier( nil, nil, "gyro_bubble", { duration = -1 } )
		thisEntity.phase_2_count = 0
		thisEntity.PHASE = 3
	end

	if thisEntity.flak_cannon:IsFullyCastable() and thisEntity.flak_cannon:IsCooldownReady() and thisEntity.flak_cannon:IsInAbilityPhase() == false and thisEntity.PHASE == 1 and thisEntity.circle_timer_running == false then
		print("phase 4 starting")

		thisEntity:EmitSound("Hero_Gyrocopter.FlackCannon.Activate")

		thisEntity:AddNewModifier(
            thisEntity, -- player source
            thisEntity.flak_cannon, -- ability source
            "modifier_flak_cannon", -- modifier name
            {
                duration = thisEntity.flak_cannon_duration,
            })

		CricleTimer()
		thisEntity.PHASE = 4
	end

	if thisEntity.flak_cannon:IsCooldownReady() == false and thisEntity.PHASE == 4 and thisEntity.circle_timer_running == false then
		print("phase 1 starting")
		thisEntity.PHASE = 1
	end

	--[[

	STATES

	]]

	if thisEntity.PHASE == 1 then
		if thisEntity.swoop:IsFullyCastable() and thisEntity.swoop:IsCooldownReady() and thisEntity.swoop:IsInAbilityPhase() == false then
			return CastSwoop( FindFurthestPlayer() )
		end

		if thisEntity.flee:IsFullyCastable() and thisEntity.flee:IsCooldownReady() and thisEntity.flee:IsInAbilityPhase() == false then
			return CastFlee( thisEntity.GyroArenaLocations[RandomInt(1,#thisEntity.GyroArenaLocations)])
		end

		if thisEntity.cannon_ball:IsFullyCastable() and thisEntity.cannon_ball:IsCooldownReady() and thisEntity.cannon_ball:IsInAbilityPhase() == false then
			if FindRandomPlayer():GetAbsOrigin() == nil then
				return 1
			else
				return CastCannonBall( FindRandomPlayer():GetAbsOrigin() )
			end
		end

		if thisEntity.flame_thrower:IsFullyCastable() and thisEntity.flame_thrower:IsCooldownReady() and thisEntity.flame_thrower:IsInAbilityPhase() == false then
			return CastFlameThrower()
		end

	end

	if thisEntity.PHASE == 2 then
		if thisEntity.whirlwind:IsFullyCastable() and thisEntity.whirlwind:IsCooldownReady() and thisEntity.whirlwind:IsInAbilityPhase() == false then
			thisEntity.phase_2_count = thisEntity.phase_2_count + 1
			return CastWhirlwind()
		end
	end

	if thisEntity.PHASE == 3 then
		if thisEntity.createParticleOnce == true then
			thisEntity.createParticleOnce = false

			thisEntity.particle_bubble = ParticleManager:CreateParticle("particles/timber/timber_abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
			local common_vector = Vector(250,0,250)
			ParticleManager:SetParticleControl(thisEntity.particle_bubble , 1, common_vector)
			ParticleManager:SetParticleControl(thisEntity.particle_bubble , 5, Vector(250,0,0))
			ParticleManager:SetParticleControlEnt(thisEntity.particle_bubble , 0, thisEntity, PATTACH_POINT_FOLLOW, "attach_hitloc", thisEntity:GetAbsOrigin(), true)

			local bubble = 5000
			thisEntity.gyroHP = thisEntity:GetHealth()
			thisEntity.gyroHP_bubble_expire = thisEntity.gyroHP - bubble

			-- remove attack and start a calldown timer
			CallDownTimer() -- at the end of this timer he will cast calldown
			thisEntity:AddNewModifier( nil, nil, "modifier_generic_disable_auto_attack", { duration = -1 })

		end

		-- if players hurt him enough do this...
		if thisEntity:GetHealth() < thisEntity.gyroHP_bubble_expire then

			if thisEntity.call_down_timer ~= nil then
				Timers:RemoveTimer(thisEntity.call_down_timer)
			end

			if thisEntity:HasModifier("modifier_generic_disable_auto_attack") then
				thisEntity:RemoveModifier("modifier_generic_disable_auto_attack")
			end

			-- destroy particle if exists
			if thisEntity.particle_bubble then
				ParticleManager:DestroyParticle(thisEntity.particle_bubble ,true)
				thisEntity:RemoveModifierByName("gyro_bubble")
			end
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

	return time + 1
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

	return thisEntity.flame_thrower_duration + 1
end
--------------------------------------------------------------------------------

function CastWhirlwind()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.whirlwind:entindex(),
		Queue = false,
	})

	return 20 -- reutrn the whirlwind duration 20?
end
--------------------------------------------------------------------------------

function CastCallDown()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.gyro_call_down:entindex(),
		Queue = false,
	})

	return 1
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
		return enemies[#enemies]
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

function CallDownTimer()

	thisEntity.call_down_timer = Timers:CreateTimer(20,function()
		if IsValidEntity(thisEntity) == false then return false end

			-- starts channeling calldown
			if thisEntity.gyro_call_down:IsFullyCastable() and thisEntity.gyro_call_down:IsCooldownReady() and thisEntity.gyro_call_down:IsChanneling() == false then
				return CastCallDown()
			end

		return false
	end)
end
--------------------------------------------------------------------------------

function CricleTimer()
    thisEntity.circle_timer_running = true
    local currentAngle = 0
    local angleIncrement = 15
    local length = 1000
    local tickInterval = 0.5
	local max_duration = thisEntity.flak_cannon_duration
	local count = 0

    Timers:CreateTimer(function()
        if IsValidEntity(thisEntity) == false then return false end

        if thisEntity.PHASE ~= 4 or thisEntity == nil or count >= max_duration then
            thisEntity.circle_timer_running = false
            return false
        end

        -- calculate a position length units away, rotating by currentAngle
        currentAngle =  currentAngle + angleIncrement
        local radAngle = currentAngle * 0.0174532925 --angle in radians
        local point = Vector(length * math.cos(radAngle), length * math.sin(radAngle), 0)
        local endPoint = point + Vector(-12204.878662, 1552.228516, 131.128906)
        thisEntity:MoveToPosition(endPoint)
		count = count + tickInterval
        return tickInterval
    end)
end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	thisEntity.swoop:SetLevel(thisEntity.level_tracker)
	thisEntity.flak_cannon:SetLevel(thisEntity.level_tracker)
	thisEntity.cannon_ball:SetLevel(thisEntity.level_tracker)
	thisEntity.flame_thrower:SetLevel(thisEntity.level_tracker)
	thisEntity.whirlwind:SetLevel(thisEntity.level_tracker)
	thisEntity.gyro_call_down:SetLevel(thisEntity.level_tracker)
	thisEntity.flee:SetLevel(thisEntity.level_tracker)

end
--------------------------------------------------------------------------------