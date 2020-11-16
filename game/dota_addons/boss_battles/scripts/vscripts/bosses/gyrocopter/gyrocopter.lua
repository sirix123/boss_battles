gyrocopter = class({})
--DR Gester uses this: not sure what/how to access/use those second two params. 
--gyrocopter = class({}, nil, Hero)

LinkLuaModifier( "flak_cannon_modifier", "bosses/gyrocopter/flak_cannon_modifier", LUA_MODIFIER_MOTION_NONE )

--GLOBALS:
--Tracking variables across multiple gyro abilities:
_G.ActiveHomingMissiles = {}

--Cooldowns:
--no longer used in current impl
local COOLDOWN_RADARSCAN = 8 --change this variable as he learns new radar scans 
local COOLDOWN_RB_FC = 13 --RocketBarrage or FlakCannon cooldown. They share a cooldown, he does one or the other. 
local COOLDOWN_WHIRLWIND = 75

-- Setup vars for tracking which Radar Spell to use. 
local RADAR_SPELL = 2 
local RADAR_SCAN = 1
local RADAR_PULSE = 2
local RadarPulse2 = 3
local RocketRadarPulse = 4

local displayDebug = true

local whirlWindDuration = 20 -- seconds
local radarPulseDuration = 6
local barrageDuration = 4
local radarScanDuration = 8

-- On Spawn, init any vars, start MainThinker
function Spawn( entityKeyValues )
	--print("Spawn( entityKeyValues ) called")

	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.gyro_base_attack = thisEntity:FindAbilityByName( "gyro_base_attack" )

	thisEntity.rocket_barrage_melee = thisEntity:FindAbilityByName( "rocket_barrage_melee" )
	thisEntity.rocket_barrage_ranged = thisEntity:FindAbilityByName( "rocket_barrage_ranged" )

	thisEntity.call_down = thisEntity:FindAbilityByName( "call_down" )
	--TODO: if any of these are nil, we got a problem
	thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )
	thisEntity:SetContextThink( "AbilityQueue", AbilityQueue, 0.1)

	--disable attacks.
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
end


local abilityQueue = {}
local tickDelay = 1 -- was working good on 1, but whirlwind needs way faster
local tickDelay = 0.01 -- TESTING: whirlwild needs to cast 10s of abilities every second
local isBusy = false
--abilityQueue structure:
--abilityQueue[1].ability = ability
--abilityQueue[1].orderType = DOTA_UNIT_ORDER_CAST_TARGET
--abilityQueue[1].target = target
-- OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
-- OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
function AbilityQueue()
	-- gyro should set isBusy flag whenever doing something you don't want
	if isBusy then return end

	--check if anything in the queue
	if #abilityQueue > 0 then
		local abilityToCast = abilityQueue[1].ability
		local orderType = abilityQueue[1].orderType
		--print("AbilityQueue(). About to cast ", abilityToCast:GetAbilityName())

		--with queue true. boss auto attacks will interupt and prevent spells. 
		--so make sure you've already set: thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
		
		if abilityQueue[1].target ~= nil then
			local target = abilityQueue[1].target
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = orderType,
				TargetIndex = target:entindex(),
				AbilityIndex = abilityToCast:entindex(),
				Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
			})
			--print("abilityToCast:GetAbilityName() = ", abilityToCast:GetAbilityName())
			if abilityToCast:GetAbilityName() == "homing_missile" then
				--print("AbilityToCast == homing_missile")
				-- TODO: add to. HomingMissileTargets
				--_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = target
				--TODO: later with scans, update this target?
			end
		else
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = orderType,
				AbilityIndex = abilityToCast:entindex(),
				Queue = false,
			})	
		end

		if abilityQueue[1].sound ~= nil then
			thisEntity:EmitSound(abilityQueue[1].sound)
		end


		--reorder the array to make it a queue
		if abilityQueue[2] ~= nill then
			for i=1,#abilityQueue do
				abilityQueue[i] = abilityQueue[i+1]
			end
		else
			abilityQueue[1] = nil
		end
	else
		--print("no abilities in queue to cast")
	end
	return tickDelay
end

-- usage: addToAbilityQueue(thisEntity.homing_missile, DOTA_UNIT_ORDER_CAST_TARGET, target, true)  
-- Can use this for abilities but also any action. like DOTA_UNIT_ORDER_MOVE_TO_TARGET or DOTA_UNIT_ORDER_HOLD_POSITION
-- castAsap : means, castNext, castImmediately, skipQueue, frontOfQueue, 
function AddToAbilityQueue(ability, orderType, target, castAsap, sound)
	--either add ability to abilityQueue at position [1] or at the end, position [#abilityQueue+1]

	--if castAsap, make pos 1
	if castAsap then
		--TODO: start at the end of the array and move it to n+1, then work backwards through the array until [1] is empty and put this ability in it
	else
		--Create a new table at count+1, but then set vals at count, because you've just increased the count
		abilityQueue[#abilityQueue+1] = {}
		abilityQueue[#abilityQueue].ability = ability
		abilityQueue[#abilityQueue].orderType = orderType
		abilityQueue[#abilityQueue].target = target
		abilityQueue[#abilityQueue].sound = sound
	end
end

function CurrentTestCode()
	--ContinuousRadarScan()	
	--Barrage()
	NewWhirlWind()

-- effectName = "particles/custom/sirix/scan.vpcf"	
 --  	local p1Index = ParticleManager:CreateParticle(effectName, PATTACH_POINT, thisEntity)
 --  	ParticleManager:SetParticleControl(p1Index, 0, thisEntity:GetAbsOrigin())
 --  	ParticleManager:ReleaseParticleIndex(p1Index )

	--thisEntity:SetAttackCapability(2) -- range attack
	--thisEntity:SetAttackCapability(0) -- no attack

	--sound effect test:
	--this format also works:
	--thisEntity:EmitSound("Hero_Gyrocopter.FlackCannon")
	--thisEntity:EmitSound("Hero_Gyrocopter.CallDown.Fire")
	--this works now that i've precached the write file in addon_game_mode.lua:
	--thisEntity:EmitSound("gyrocopter_gyro_attack_01")

	-- Whirlwind-in: sucks players toward gyro, like vacuum but slower, just changing their movement vector
	-- Whirlwind-out:
	 --WhirlWind()
end

local continuousRadarScanStarted = false
local tickCount = 0
local dt = 1
--Main AI for Gyrocopter:
local waitAmount = 0
function MainThinker()
	--print ("MainThinker called")
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1	


	--TESTING:
	--if (tickCount % 2 == 0) then
	if (tickCount == 2) then
		--CurrentTestCode()
		--ContinuousRadarScan()
	end
	--Script the first x seconds to introduce the spells, then use CDs..

	-- Whirlwind at the start of the fight:
	if (tickCount == 2) then 
		NewWhirlWind() 
	end
	--after newWhirlWind, radarPulse to send rockets
	if tickCount == 4 + whirlWindDuration then 
		NewRadarPulse() 
	end
	--after rockets, do barrage
	if tickCount == 4 +whirlWindDuration + radarPulseDuration then
		Barrage()
	end
	-- after barrage. do whirlwind, newRadarPulse combo again, then finally calldown scan
	if tickCount == 4 + whirlWindDuration + radarPulseDuration + barrageDuration then 
		NewWhirlWind()
	end
	
	if tickCount == 4 + whirlWindDuration + radarPulseDuration + barrageDuration + whirlWindDuration then 
		thisEntity.homing_missile:SetLevel(thisEntity.homing_missile:GetLevel() +1)
		NewRadarPulse()
	end
	if tickCount == 4 + whirlWindDuration + radarPulseDuration + barrageDuration + whirlWindDuration + radarPulseDuration then 
		RadarScan()
	end

	-- start this loop after the introductory sequence.
	-- rockets, followed by Barrage or Whirlwind
	if tickCount > 4 + whirlWindDuration + radarPulseDuration + barrageDuration + whirlWindDuration + radarPulseDuration + radarScanDuration then 
		waitAmount = waitAmount - 1
		if waitAmount < 1 then
			--level up rocket. 
			if thisEntity.homing_missile:GetLevel() < 4 then 
				thisEntity.homing_missile:SetLevel(thisEntity.homing_missile:GetLevel() +1)
			end

			--cast barrage and then x seconds afterwards cast the next ability
			NewRadarPulse()

			--pick a spell and cast it.
			local spellNum = RandomInt(1,2) 
			if spellNum == 1 then
				waitAmount = waitAmount + radarPulseDuration + barrageDuration

				Timers:CreateTimer({
					endTime = radarPulseDuration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
					callback = function()
						Barrage()
					end
				})
			end
			if spellNum == 2 then
				waitAmount = waitAmount + radarPulseDuration + whirlWindDuration
				Timers:CreateTimer({
					endTime = radarPulseDuration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
					callback = function()
						NewWhirlWind()
					end
				})
			end
		end
	end

	--ENRAGE PHASE
	--if hp below % then start ContinuousRadarScan
	if thisEntity:GetHealthPercent() < 50 and not continuousRadarScanStarted then
		--print("Casting ContinuousRadarScan()")
		ContinuousRadarScan()
		continuousRadarScanStarted = true
	end

	--initial delay isn't working how I think it is... need to debug this in excel.
	local initialDelay = 2
	if ( (tickCount - initialDelay ) % COOLDOWN_RADARSCAN ) == 0 then --cast repeatedly
		--Each scan spell will be responsible for creating
		if RADAR_SPELL == RADAR_SCAN then
			--todo: add particle effect from stefan, still use my code to control the 'model' of the spell. replace DebugDraw with particle
			--RadarScan()
			--alternate between scan and pulse
			RADAR_SPELL = RADAR_PULSE
			return dt
		end
		if RADAR_SPELL == RADAR_PULSE then
			--todo: add particle effect from stefan, still use my code to control the 'model' of the spell. replace DebugDraw with particle
			--NewRadarPulse()
			--alternate between scan and pulse
			--RADAR_SPELL = RADAR_SCAN
			return dt
		end
	end

	initialDelay = 5
	local rbRadius = 500
	--Cast either RocketBarrage (RB) or FlakCannon(FC) based on how many units are within rbRadius range
	if ( (tickCount - initialDelay) % COOLDOWN_RB_FC ) == 0 then --cast repeatedly
 		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, rbRadius,
 		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

 		if #enemies > 0 then
 			--print("Enemies nearby, casting RocketBarrage")
			--AddToAbilityQueue(thisEntity.rocket_barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, "gyrocopter_gyro_attack_01")
			--AddToAbilityQueue(thisEntity.rocket_barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		else
			--print("No Enemies nearby, casting FlakCannon")
			--AddToAbilityQueue(thisEntity.flak_cannon, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, "gyrocopter_gyro_attack_01")
			--AddToAbilityQueue(thisEntity.flak_cannon, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		end
	end

	return dt
end	


function AttackClosestPlayer()
	-- thisEntity:EmitSound('gyrocopter_gyro_attack_01')
	-- EmitSound('sounds/vo/gyrocopter/gyro_attack_01.vsnd', thisEntity)

	-- find closet player
	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	
	if #enemies >0 then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			TargetIndex = enemies[1]:entindex(),
			Queue = 0,
		})
	end
end

function MoveToPosition(position, movespeed )
	--get initial values to restore later
	local ms = thisEntity:GetBaseMoveSpeed()
	local attackCapability = thisEntity:GetAttackCapability() 

	--move gyro to position
	thisEntity:SetBaseMoveSpeed(movespeed)
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
	thisEntity:MoveToPosition(position)

	--wait until arrived, then reset values:
    --A timer to trigger any actions for when gyro arrives at his destination
	Timers:CreateTimer(function()	
		local currentPos = thisEntity:GetAbsOrigin()
		local destination = position
		local distance = (position - currentPos):Length2D()
		if distance < 80 then
			--after arriving, reset values
			thisEntity:SetBaseMoveSpeed(ms)
			thisEntity:SetAttackCapability(attackCapability)
			return
		end
		return 0.5
	end) --end timer
end


--BARRAGE ability:
--rocket barrage all melee units, then rocket barrage all ranged units. 


function Barrage()
	--print("Barrage() called")
	--TODO: need to know the duration of these spells somehow...
	--currently it's just 3.5s for each spell.
	--mele first and then ranged.
	AddToAbilityQueue(thisEntity.rocket_barrage_melee, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, "gyrocopter_gyro_attack_01")
	--2.5 seconds delayed, run once
	Timers:CreateTimer({
		endTime = 3.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			AddToAbilityQueue(thisEntity.rocket_barrage_ranged, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, "gyrocopter_gyro_attack_01")
		end
	})
end	

local wwsuckDuration = 7
_G.whirlwindTargets = {}
function NewWhirlWind()
	--print("NewWhirlWind() called")
	--thisEntity:SetAttackCapability(0)
	local length = 1200
	
	local timerDelay = 0.1
	local totalTicks = whirlWindDuration / timerDelay
	local currentTick = 0

	--could rename all this; 
	local currentRotation = 0
	local rotationVelocity = 2

	local minSpeed = 0.05
	local maxSpeed = 45
	local rotationSpeed = minSpeed

	Timers:CreateTimer(function()
		currentTick = currentTick + 1
		if currentTick >= (totalTicks - (wwsuckDuration / timerDelay) ) then return end

		-- Calculate a new position based on an angle and length
		currentRotation =  currentRotation + rotationVelocity
		local radAngle = currentRotation * 0.0174532925 --angle in radians
		local point = Vector(length * math.cos(radAngle), length * math.sin(radAngle), 0)
		local endPoint = point + thisEntity:GetAbsOrigin()

		--rotate gyro:
		local newForwardVector = Vector(0,0,0)
		local rotated = RotatePosition(Vector(0,0,0), QAngle(0,currentRotation,0), Vector(1,0,0))  
		thisEntity:SetForwardVector(rotated)

		local originZeroZ = Vector(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y, 0)

		if displayDebug then
			DebugDrawLine_vCol(originZeroZ, endPoint, Vector(255,0,0), true, timerDelay)
		end

		--check if unit in line from forward vector to length
		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, originZeroZ, endPoint, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )

		--each tick, if no enemies detected, speed up rotation rate
		if #enemies == 0 then
			--perhaps do a linear increase by n until you hit x, then increase by 2n until you hit 2x, then 3n etc
			--rotationVelocity = rotationVelocity * 1.02

			--slowly build up rotation speed. acceleration curve...
			if rotationVelocity < (maxSpeed / 8) then				
				rotationSpeed = rotationSpeed + 0.02
			end
			if (rotationVelocity > (maxSpeed / 8)) and (rotationVelocity < (maxSpeed / 4)) then
				rotationSpeed = rotationSpeed + 0.03
			end
			if (rotationVelocity > (maxSpeed / 4)) and (rotationVelocity < (maxSpeed / 2)) then
				rotationSpeed = rotationSpeed + 0.04
			end
			if (rotationVelocity > (maxSpeed / 2)) and (rotationVelocity < maxSpeed) then
				rotationSpeed = rotationSpeed + 0.05
			end			
			--print("rotationSpeed = ", rotationSpeed)

			rotationVelocity = rotationVelocity + rotationSpeed

			--figure out what ... function i want for rotationVelocity. figure out the line i want, linear increase, exponential?
		else
			--print("enemies found slowing down! ")
			--slow down by half, instead of subtracting fixed amount
			rotationVelocity = rotationVelocity / 1.5
			rotationSpeed = minSpeed
			-- never slow below minimum speed
			if rotationVelocity < minSpeed then
				rotationVelocity = minSpeed
			end
		end

		--print("rotationVelocity = " , rotationVelocity )
		if rotationVelocity > maxSpeed then
			--print("rotationVelocity greater than 45! Should do tornadoes and suck players in?")
			WhirlWind()
			return
		end

		--if enemies detected, slow down rotation rate and shoot at enemy.
		for _,enemy in pairs(enemies) do
			-- add the enemy to the target list
			_G.whirlwindTargets[#_G.whirlwindTargets +1] = enemy
			AddToAbilityQueue(thisEntity.gyro_base_attack, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)			
			--or.. cast it instantly because this will be happening often and fast. faster than abilityQueue
			-- ExecuteOrderFromTable({
			-- 	UnitIndex = thisEntity:entindex(),
			-- 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			-- 	AbilityIndex = thisEntity.whirlwind:entindex(),
			-- 	Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
			-- })
		end

		return timerDelay
	end)
end

--Whirlwind ability:
-- Gyro spins around rapidly using his copter to create a whirlwind, sucking enemys toward gyro.
-- param pushEnemyAway if true, pushes enemies away instead of pulling them in
local flyingMs = 600
local normalMs = 300

function WhirlWind(pushEnemyAway)
	--print("WhirlWind() called")
	thisEntity:SetBaseMoveSpeed(flyingMs)
	
	local maxHeight = 2000
	local radius = 9999

	local duration = wwsuckDuration -- seconds
	local tickInterval = 0.05
	local totalTicks = duration / tickInterval
	local currentTick = 1

	local velocity = 0
	local velocityIncrement = 200 * tickInterval

	local currentAngle = 0
	local angleIncrement = 200 * tickInterval
	local zIncrement = 50 * tickInterval

	local length = 200
	local lengthIncrement = 2

	-- print("angleIncrement = ", angleIncrement)
	-- print("velocityIncrement = ", velocityIncrement)
	-- print("totalTicks = ", totalTicks)

	Timers:CreateTimer(function()
		--start casting CallDown before the end of whirlwind
		local cooldownLeadTime = 3 / tickInterval --ticks in 3 seconds
		if currentTick + cooldownLeadTime == totalTicks then
			if not pushEnemyAway then
				--calldown on gyros current position
				CastCallDownAt(thisEntity:GetAbsOrigin())
			else 
				--calldown in ring/aoe around gyro, but not immediately on him
				--TODO: calldown pattern of some sort..
			end
		end

		--At the end of whirlwind, return gyro to ground level.
		if currentTick == totalTicks then
			thisEntity:SetBaseMoveSpeed(normalMs)
			Timers:CreateTimer(function()
				if thisEntity:GetAbsOrigin().z > 300 then
					thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(0,0 -30))
					return 0.05
				else 
					return
				end
			end)
			return 
		end

		--update ability model
		length = length + lengthIncrement
		currentTick = currentTick +1
		velocity = velocity + velocityIncrement
		thisEntity:SetBaseMoveSpeed(flyingMs+velocity)

		-- Calculate a new position based on an angle and length
		currentAngle =  currentAngle + angleIncrement
		local radAngle = currentAngle * 0.0174532925 --angle in radians
		local point = Vector(length * math.cos(radAngle), length * math.sin(radAngle), 0)
		local endPoint = point + thisEntity:GetAbsOrigin()

		-- increment z.. doesn't seem to work. Unit can't move to z axis.
		--endPoint = endPoint + Vector(0,0,1000)
		thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(0,0,zIncrement)) --force increase on z axis
		thisEntity:MoveToPosition(endPoint)
		
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		--Pull all units toward gyro:
		for _,enemy in pairs(enemies) do
			local diff = thisEntity:GetAbsOrigin() - enemy:GetAbsOrigin()
			if pushEnemyAway then
				--Push the unit away from gyro:
				diff = enemy:GetAbsOrigin() - thisEntity:GetAbsOrigin()
			end
			local diffIncr = diff:Normalized() * 25
			enemy:SetAbsOrigin(enemy:GetAbsOrigin() + diffIncr)
		end
		return tickInterval
	end)
end

--TODO make the call_down.lua spell do this...
function CastCallDownAt(location)
	--spell model:
	local indicator_duration = 2
	local tick_interval = 0.1
	local total_ticks = indicator_duration / tick_interval
	local current_tick = 0
	local radius = 600
	local current_alpha = 0
	local alpha_growth_amount = 2
	local current_radius = 200
	local radius_growth_amount = (radius - current_radius) / total_ticks

	--particles:	
	local p1 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf"
	local p2 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf"
	local p3 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_second.vpcf"
	--Initial marker indicator particle
	local p1Index = ParticleManager:CreateParticle(p1, PATTACH_POINT, thisEntity)
	ParticleManager:SetParticleControl(p1Index, 0, location)
	ParticleManager:SetParticleControl(p1Index, 1, Vector(radius,radius,-radius))
	ParticleManager:ReleaseParticleIndex( p1Index )
	--first and second explosion particles
	local calldown_first_particle = ParticleManager:CreateParticle(p2, PATTACH_WORLDORIGIN, thisEntity)
	ParticleManager:SetParticleControl(calldown_first_particle, 0, location)
	ParticleManager:SetParticleControl(calldown_first_particle, 1, location)
	ParticleManager:SetParticleControl(calldown_first_particle, 5, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(calldown_first_particle)
	local calldown_second_particle = ParticleManager:CreateParticle(p3, PATTACH_WORLDORIGIN, thisEntity)
	ParticleManager:SetParticleControl(calldown_second_particle, 0, location)
	ParticleManager:SetParticleControl(calldown_second_particle, 1, location)
	ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(calldown_second_particle)

	--TODO: sounds: 
	--EmitSoundOnClient("gyrocopter_gyro_call_down_1"..RandomInt(1, 2), self:GetCaster():GetPlayerOwner())

	--TODO: extract the logic with DebugDraw in there and keep it somewhere...
	--Call down ability: 
	--Start a timer, while counting up display indicator animation. After indicator_duration seconds, apply particle effects, dmg enemies in radius
	Timers:CreateTimer(function()	
		current_tick = current_tick +1
		current_alpha = current_alpha + alpha_growth_amount
		current_radius = current_radius + radius_growth_amount
		-- TODO: call down particles effects and dmg to enemies in radius
		if current_tick >= total_ticks then
			--TODO: particle effect on landing...
			--DebugDrawCircle(location, Vector(255,0,0), 255, radius, true, tick_interval * 4) --remove this once particles are in

			local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, location, nil, current_radius,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
			for _,enemy in pairs(enemies) do
				local damageInfo = 
				{
					victim = enemy, attacker = thisEntity,
					damage = 100, --TODO: calc this / get from somewhere
					damage_type = 4, -- TODO: get this from ability file ... 4 = DAMAGE_TYPE_PURE 
					ability = self,
				}
				local dmgDealt = ApplyDamage(damageInfo)
			end
			return	--stop the timer 

		end
		-- Display indicator warning players spell is coming
		--if current_tick <= total_ticks then
			--DebugDrawCircle(location, Vector(255,0,0), current_alpha, current_radius, true, tick_interval)	
			--DebugDrawCircle(location, Vector(255,0,0), 0, current_radius, true, tick_interval)	
		--end
	return tick_interval
	end)

end



local enemiesScannedThisRevolution = {}
function ContinuousRadarScan()
	print("ContinuousRadarScan() called")
	local revolutionDuration = 5
	local frameDuration = 0.05

	local pieSize = 5
	local angleIncrement = 2
	local endAngle = pieSize
	local startAngle = 0
	local currentAngle = startAngle


	local radius = 1200
	Timers:CreateTimer(function()
		local origin = thisEntity:GetAbsOrigin()

		startAngle = endAngle - pieSize
		currentAngle = startAngle

		if currentAngle % 360 == 0 then
			--print("New revolution started")
			Clear(enemiesScannedThisRevolution)
			--Reset enemies scanned
		end

		 -- print("currentAngle = ", currentAngle)
		 -- print("startAngle = ", startAngle)
		 -- print("endAngle = ", endAngle)
		local linesPerDegree = 20	
		local totalLines = linesPerDegree * (endAngle - startAngle)
		-- print ("totalLines = ", totalLines)
		--Draw a pie for startAngle to endAngle
		--iterate and draw from startAngle to endAngle
		local color = Vector(255,0,0)
		for i = 0, totalLines, 1 do
			currentAngle =  currentAngle + ( angleIncrement / linesPerDegree )
			color.x = color.x -1
			--color.y = color.y -2
			--color.z = color.z -2

			local radAngle = currentAngle * 0.0174532925 --angle in radians
			local point = Vector(radius * math.cos(radAngle), radius * math.sin(radAngle), 0)
			--print("Calculated point = ", point)
			local originZeroZ = Vector(origin.x, origin.y,0)
			DebugDrawLine_vCol(originZeroZ, point + originZeroZ, color, true, frameDuration + frameDuration)


			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, originZeroZ, point + originZeroZ, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
			for _,enemy in pairs(enemies) do
				if Contains(enemiesScannedThisRevolution, enemy) then -- already hit this enemy
					--do nothing
				else -- first time hitting this enemy
					if displayDebug then
						DebugDrawCircle(enemy:GetAbsOrigin(), Vector(0,255,0), 128, 100, true, frameDuration)
					end
					enemiesScannedThisRevolution[enemy] = true --little hack so Contains works 
					CastCallDownAt(enemy:GetAbsOrigin())
				end
			end

		end

		endAngle = endAngle - angleIncrement
		return frameDuration
		--when to stop?
	end)

end


enemiesScanned = {}
function RadarScan()
	--print("RadarScan() called")
	--play stefan's particle:
	-- content/dota_addons/boss_battles/particles/custom/sirix/scan.vpcf
	-- effectName = "particles/custom/sirix/scan.vpcf"	
 -- 	local p1Index = ParticleManager:CreateParticle(effectName, PATTACH_POINT, thisEntity)
 -- 	ParticleManager:SetParticleControl(p1Index, 0, thisEntity:GetAbsOrigin())
 -- 	ParticleManager:ReleaseParticleIndex(p1Index )

	--Not sure example when I want to reset these 
	Clear(enemiesScanned)

	local spellDuration = 3 --seconds
	local radius = 1500

	local currentFrame = 1
	local totalFrames = 120
	local frameDuration = spellDuration / totalFrames -- 2 / 120 = 0.016?

	local totalDegreesOfRotation = 360
	local degreesPerFrame = totalDegreesOfRotation / totalFrames
	
	local pieSize = 30 --degrees. Max allowable difference between startAngle and endAngle
	local endAngle = pieSize
	local startAngle = 0
	local currentAngle = startAngle

	Timers:CreateTimer(function()	

		local origin = thisEntity:GetAbsOrigin()
		currentFrame = currentFrame +1

		--Scan finished: any cleanup or actions on the last frame... 
		if currentFrame >= totalFrames then
			-- Clear(enemiesScanned)
			return
		end	

		--Most of this code is for the animation/drawing portion. but also checks for enemies hit bit the scan
		startAngle = endAngle - pieSize
		currentAngle = startAngle
		local linesPerDegree = 10
		local totalLines = linesPerDegree * (endAngle - startAngle)
		for i = 0, totalLines, 1 do
			currentAngle =  currentAngle + ( 1 / linesPerDegree )
			local radAngle = currentAngle * 0.0174532925 --angle in radians
			local point = Vector(radius * math.cos(radAngle), radius * math.sin(radAngle), 0)
			--print("Calculated point = ", point)
			local originZeroZ = Vector(origin.x, origin.y,0)
			DebugDrawLine(originZeroZ, point + originZeroZ, 255,0,0, true, frameDuration)
			--DebugDrawLine_vCol(originZeroZ, point + originZeroZ, Vector(255,0,0), true, 128, frameDuration)

			--If this uses too much processing then use 'if i % 5 == 0' to run this 4/5 times less frequently
			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, originZeroZ, point + originZeroZ, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
			for _,enemy in pairs(enemies) do
				if Contains(enemiesScanned, enemy) then -- already hit this enemy
					--do nothing
				else -- first time hitting this enemy
					if displayDebug then
						DebugDrawCircle(enemy:GetAbsOrigin(), Vector(0,255,0), 128, 100, true, frameDuration * 8)
					end

					enemiesScanned[enemy] = true --little hack so Contains works 
					scannedEnemy = {}
					scannedEnemy.Location = shallowcopy(enemy:GetAbsOrigin())
					scannedEnemy.Enemy = enemy

					-- check if this enemy is already in the list... we don't want to keep adding them we just want to update the location
					local isNewEnemy = true

					-- if #_G.HomingMissileTargets > 0 then 
					-- 	for i = 1, #_G.HomingMissileTargets, 1 do
					-- 		-- already scanned this enemy, update their location
					-- 		if enemy == _G.HomingMissileTargets[i].Enemy then
					-- 			--_G.HomingMissileTargets[i].Location = shallowcopy(enemy:GetAbsOrigin())
					-- 			isNewEnemy = false
					-- 		end
					-- 	end
					-- end
					-- first time scanning this enemy, add a new entry for them
					if isNewEnemy then
						--print("radarScan hit new enemy. casting calldown at them")
						--CALL DOWN ABILITY: un/comment if you want to use homing missile via radarScan
						CastCallDownAt(enemy:GetAbsOrigin())

						--HOMING MISSILE ABILITY: un/comment if you want to use homing missile via radarPulse
						--Create a new entry in ActiveHomingMissiles:
						-- Want to only create one missile per enemy? then loop and check if enemy not exists
						-- _G.ActiveHomingMissiles[#_G.ActiveHomingMissiles+1] = {}
						-- _G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Enemy = enemy
						-- _G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Location = shallowcopy(enemy:GetAbsOrigin())	
						-- --Shoot a homing missile at this target:
						-- AddToAbilityQueue(thisEntity.homing_missile, DOTA_UNIT_ORDER_CAST_TARGET, enemy, false, "gyrocopter_gyro_attack_01")
					end
				end
			end
		end
		
		endAngle = endAngle - degreesPerFrame
		return frameDuration
	end) --end timer
end


function NewRadarPulse()
	local radius = 200
	local endRadius = 2000
	local radiusGrowthRate = 25

	local enemiesDetected = {}

	local frameDuration = 0.02
	local currentAlpha = 10
	Timers:CreateTimer(function()	
		currentAlpha = currentAlpha + 1
		--update model
		local origin = thisEntity:GetAbsOrigin()
		if radius < endRadius then
			radius = radius + radiusGrowthRate
		else --else, last frame. Flash the circle one last time with higher alpha
			DebugDrawCircle(origin, Vector(255,0,0), 128, radius, true, frameDuration*2)
			return
		end
		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), currentAlpha, radius, true, frameDuration*2)		
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) --draw same thing, radius-1, for double thick line/circle edge

		--check for hits. Maybe don't do this every single tick... but every nth to reduce compute
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		for _,enemy in pairs(enemies) do -- if this enemy has already been hit. only "hit" each enemy once
			if Contains(enemiesDetected, enemy) then -- do nothing. this gets called every tick after the first tick that detects an enemy
			else
				-- enemy detected for the first time this pulse. Gets called once for this Timer
				enemiesDetected[enemy] = true --little hack so Contains(enemiesDetected,enemy) works 
				--Update any existing missiles with this new location.
				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Enemy == enemy then
						_G.ActiveHomingMissiles[i].Location = shallowcopy(enemy:GetAbsOrigin())	
					end
				end	
					--CALL DOWN ABILITY: un/comment if you want to use homing missile via radarScan
					--CastCallDownAt(enemy:GetAbsOrigin())

					--HOMING MISSILE ABILITY: un/comment if you want to use homing missile via radarPulse
					-- Create a new entry in ActiveHomingMissiles:
					-- Want to only create one missile per enemy? then loop and check if enemy not exists
					_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles+1] = {}
					_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Enemy = enemy
					_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Location = shallowcopy(enemy:GetAbsOrigin())	
					--Shoot a homing missile at this target:
					AddToAbilityQueue(thisEntity.homing_missile, DOTA_UNIT_ORDER_CAST_TARGET, enemy, false, "gyrocopter_gyro_attack_01")
			end
		end
		return frameDuration
		--TODO: implement deltaTime for consistent time frames, don't delay by x, delay by x - timeTakenToProcess		
	end)
end