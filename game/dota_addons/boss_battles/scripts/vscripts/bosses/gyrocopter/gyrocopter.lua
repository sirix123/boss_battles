gyrocopter = class({})
--DR Gester uses this: not sure what/how to access/use those second two params. 
--gyrocopter = class({}, nil, Hero)

LinkLuaModifier( "flak_cannon_modifier", "bosses/gyrocopter/flak_cannon_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

--GLOBALS:
--Tracking variables across multiple gyro abilities:
_G.ActiveHomingMissiles = {}
_G.IsGyroBusy = false

local displayDebug = true
local initialZ = 0

-- On Spawn, init any vars, start MainThinker
function Spawn( entityKeyValues )
	--print("Spawn( entityKeyValues ) called")
	--NEW:
	thisEntity.barrage_radius_attack = thisEntity:FindAbilityByName( "barrage_radius_attack" )
	thisEntity.barrage_radius_melee = thisEntity:FindAbilityByName( "barrage_radius_melee" )
	thisEntity.barrage_radius_ranged = thisEntity:FindAbilityByName( "barrage_radius_ranged" )

	thisEntity.barrage_rotating = thisEntity:FindAbilityByName( "barrage_rotating" )
	thisEntity.barrage_rotating_attack = thisEntity:FindAbilityByName( "barrage_rotating_attack" )

	thisEntity.absorbing_shell = thisEntity:FindAbilityByName( "absorbing_shell" )


	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.gyro_base_attack = thisEntity:FindAbilityByName( "gyro_base_attack" )

	thisEntity.rocket_barrage_melee = thisEntity:FindAbilityByName( "rocket_barrage_melee" )
	thisEntity.rocket_barrage_ranged = thisEntity:FindAbilityByName( "rocket_barrage_ranged" )

	thisEntity.call_down = thisEntity:FindAbilityByName( "call_down" )
	
	thisEntity.whirlwind_attack = thisEntity:FindAbilityByName("whirlwind_attack")

	--abilityQueue thinker
	thisEntity:SetContextThink( "AbilityQueue", AbilityQueue, 0.1)

	--new AI: 
	thisEntity:SetContextThink( "NewAI", NewAI, 0.1 )

	--old AI:
	--thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )

	-- new AI v2 just barrage and rockets:
	--thisEntity:SetContextThink( "GyroAI1", GyroAI1, 1 )
	
	-- new AI v1: whole boss fight.
	--thisEntity:SetContextThink( "GyroAI2", GyroAI2, 1 )

	--disable attacks.
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
end


local abilityQueue = {}
local tickDelay = 0.01 -- TESTING: whirlwild needs to cast 10s of abilities every second
--abilityQueue structure:
--abilityQueue[1].ability = ability
--abilityQueue[1].orderType = DOTA_UNIT_ORDER_CAST_TARGET
--abilityQueue[1].target = target
-- OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
-- OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
function AbilityQueue()
	-- gyro should set isBusy flag whenever doing something you don't want
	if _G.IsGyroBusy and #abilityQueue > 0 then
		-- print("gyro is busy. #abilityQueue = ",#abilityQueue)
	end

	if _G.IsGyroBusy then
	 	
	 	return tickDelay * 50
	end

	--check if anything in the queue
	if #abilityQueue > 0 then
		local abilityToCast = abilityQueue[1].ability
		local orderType = abilityQueue[1].orderType
		--print("AbilityQueue(). About to cast ", abilityToCast:GetAbilityName())

		--with queue true. boss auto attacks will interupt and prevent spells. 
		--so make sure you've already set: thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.

		-- if order type == DOTA_UNIT_ORDER_CAST_POSITION then
		-- target is a Vector
		-- if order type == DOTA_UNIT_ORDER_CAST_TARGET then 
		-- target is a unit. 
		if abilityQueue[1].target ~= nil then
			local target = abilityQueue[1].target

			if abilityQueue[1].orderType == DOTA_UNIT_ORDER_CAST_POSITION then
				-- thisEntity:SetCursorPosition(target)
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = orderType,
					Position = target,
					AbilityIndex = abilityToCast:entindex(),
					Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
				})
			end
			if abilityQueue[1].orderType == DOTA_UNIT_ORDER_CAST_TARGET then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = orderType,
					TargetIndex = target:entindex(),
					AbilityIndex = abilityToCast:entindex(),
					Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
				})
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



--Gyro moves upwards toward altitude, in 10 increments over 1 second 
--MoveToPosition doesn't work with Z index so to change a units height I have to directly modified its AbsOrigin
--TODO: this should be a blocking function... otherwise it will get interupted and gyro won't reach height
function FlyUp(altitude)
	local duration = 1
	local tickAmount = 20
	local delayAmount = duration / tickAmount
	local zIncrement = (altitude - thisEntity:GetAbsOrigin().z) / 10

	Timers:CreateTimer(function()
		thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(0,0,zIncrement))
		-- stop once reaching altitude
		if thisEntity:GetAbsOrigin().z >= altitude then return end 
		return delayAmount
	end)
end

--Gyro moves down to altitude, in 10 increments over 1 second 
--MoveToPosition doesn't work with Z index so to change a units height I have to directly modified its AbsOrigin
--TODO: this should be a blocking function... otherwise it will get interupted and gyro won't reach height
function FlyDown(altitude)
	local duration = 1
	local tickAmount = 20
	local delayAmount = duration / tickAmount
	local zIncrement = (thisEntity:GetAbsOrigin().z - altitude) / tickAmount

	Timers:CreateTimer(function()
		thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(0,0,-zIncrement))
		-- stop once reaching altitude
		if thisEntity:GetAbsOrigin().z <= altitude then return end 
		return delayAmount
	end)
end

--UNTESTED:
--Gyro rapidly flies toward target. Crashing into it. 
	--Make a timer and track gyros position. Upon arrival do:
		-- explode and dmg enemies
		-- stun enemies, stun gyro
		-- reset MS
-- BUG: if gyro is at z 400, he'll immediately reset to z 132 after MoveToPosition is called
function Swoop(location)
	print("Swoop() location = ", location )
	print("Gyro z = ", thisEntity:GetAbsOrigin().z)
	local swoopSpeed = 1200
	local originalMs = thisEntity:GetBaseMoveSpeed()
	thisEntity:SetBaseMoveSpeed(swoopSpeed)

	local radius = 500
	local dmg = 200
	local stunDuration = 2.5
	local collisionDist = 70 --stop the timer and apply effects once gyro is within this distance of target

	local distance = (location - thisEntity:GetAbsOrigin()):Length2D()
	local travelTime = distance / thisEntity:GetBaseMoveSpeed()

	--tilt gyro's nose 25 degrees down, so he aiming at the ground
	thisEntity:SetAngles(25,0,0)
	thisEntity:MoveToPosition(location)


	Timers:CreateTimer(function()
		print("Gyro z = ", thisEntity:GetAbsOrigin().z)

		local distance = (location - thisEntity:GetAbsOrigin()):Length2D()
		--don't need to this this... valve automatically does it
		if (thisEntity:GetAbsOrigin().z > initialZ) then
			--reduce z by a little 
			--thisEntity:SetAbsOrigin(Vector(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y, thisEntity:GetAbsOrigin().z - 10))
		end

		if (distance <= collisionDist) then
			thisEntity:SetBaseMoveSpeed(originalMs)

			--DEBUG
			DebugDrawCircle(thisEntity:GetAbsOrigin(), Vector(255,0,0), 128, 100, true, 1)

			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

			for _,enemy in pairs(enemies) do 
	            local dmgTable =
	            {
	                victim = enemy,
	                attacker = thisEntity,
	                damage = dmg,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	            }
	            ApplyDamage(dmgTable)
	        end

        	-- stun
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(
					self:GetParent(), -- player source
					nil, -- ability source
					"modifier_generic_stunned", -- modifier name
					{ duration = self.base_stun } -- kv
				)
			end

        	--example from stun_druid_zap.lua
        	-- LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )


        	return
		end

		return 0.05
	end)

end


--UNTESTED
--Gyro flies to location, and leaves a trail of destruction behind him (think batrider firepath)
--Maybe leave behind a sticky napalm goo, then ignite it afterwards?
	-- like he's spilling oil as he flies away?
function Zoom(location)


end



function CurrentTestCode()
	
	--the circle "tightness" / radius is dictated by the yaw_velocity and the distance..
	--not sure extactly how to calculate the radius based on those two vars though..
	--or if I start with a radius. how do I calculate those two vars?

	
	--pitch incrementing pitch makes the model face downwards. decrementing would tilt upwards
	--yaw incrementing yaw makes the model rotate counter-clockwise. decrementing would rotate clockwise
	--roll. does nothing. Thanks valve.
	-- local pitch = 0.0
	-- local yaw = 0.0
	-- local roll = 0.0 -- does nothing, with the gyro model? or in general?
	-- --thisEntity:SetAngles(pitch, yaw, roll)

	-- local pitch_velocity = 0.0
	-- local yaw_velocity = -3.0


 --    local distance = 30
 --    local travelTime = distance / thisEntity:GetBaseMoveSpeed()
 --    print("distance of "..distance.. "will take gyro "..travelTime.." to travel with a movespeed of "..thisEntity:GetBaseMoveSpeed() )


 --    local delayAmount = travelTime - (travelTime / 4 ) --delay by the time it would take gyro to move to the location, minus some amount, so he never arrives and stops.
	-- Timers:CreateTimer(function()	
	-- 	--pitch = pitch + pitch_velocity
	-- 	yaw = yaw + yaw_velocity
	-- 	thisEntity:SetAngles(pitch, yaw, roll)
	-- 	local moveTo = (thisEntity:GetForwardVector() * distance) + thisEntity:GetAbsOrigin()
	-- 	thisEntity:MoveToPosition(moveTo)


	-- 	distance = distance + 0.1
	-- 	travelTime = distance / thisEntity:GetBaseMoveSpeed()
	-- 	delayAmount = travelTime - (travelTime / 4 )

	-- 	return delayAmount 
	-- end) --end timer



	--AddToAbilityQueue(thisEntity.absorbing_shell, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	--AddToAbilityQueue(thisEntity.barrage_rotating, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)

end

local dt = 0.1
local tickCount = 0
function NewAI()
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1

	--init:
	if tickCount == 2 then
		initialZ = thisEntity:GetAbsOrigin().z
	end

	if (tickCount % 50 == 0) then
		CurrentTestCode()
	end	

	if (tickCount == 40) then
		FlyUp(400)
	end
	if (tickCount == 60) then
		Swoop(thisEntity:GetAbsOrigin() + Vector(500,900,0))
	end
	
	return dt
end


local dt = 1
local tickCount = 0
local cooldownStepTime = 7 -- seconds
local cooldownStepCount = 0
-- gyro AI1 does 
function GyroAI1()
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1

	-- every cooldownStepTime seconds, check if we should cast an ability
	-- cooldownStepTime-1 so this fires immediately, then every cooldownStepTime'th (e.g 7th) second
	if (tickCount + (cooldownStepTime-1)) % cooldownStepTime == 0 then
		cooldownStepCount = cooldownStepCount +1
		print("cooldown. Step ", cooldownStepCount)

		-- BARRAGE. Happens every 3rd tick so use % 3.
		-- want this to happen on the first tick, so (cooldownStepCount+2) so that modulus check fires on first tick
		if (cooldownStepCount + 2 ) % 3 == 0 then
			print("casting barrage")
			Barrage()
		end
		
		-- PULSE rockets. Happens every 2nd tick. use % 2
		-- but I want this to first fire on the third tick. so cooldownStepCount -1, 
		-- > 2 prevents firing early when cooldownStepCount -1 == 0. whats 0 % 2?
		if cooldownStepCount > 2 and (cooldownStepCount -1) % 2 == 0 then
			print("casting NewRadarPulse")
			NewRadarPulse()
		end
	end

	--Auto attack closest enemy is no other action is happening:
	if not _G.IsGyroBusy then
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #enemies > 0 then
			_G.whirlwindTargets[#_G.whirlwindTargets +1] = enemies[1]
			AddToAbilityQueue(thisEntity.gyro_base_attack, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)			
		end
	end

	return dt
end


local dt = 1
local tickCount = 0
local sevenCount = 0
local didJustScan = false
local isContinuousScanRunning = false
function GyroAI2()
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1

	--TESTING:
	if tickCount % 5 == 0 then
	-- if tickCount == 2 then
		CurrentTestCode()
	else
		return dt
	end


	-- if tickCount % 10 == 0 then
	-- 	CurrentTestCode()
	-- end


	-- queue up several ability, IsGyroBusy and abilityQueue should handle when to cast em
	-- if tickCount == 2 then
	-- 	WhirlWind()		
	-- end
	-- if tickCount == 15 then
	-- 	Barrage()
	-- end

	-- every 7 seconds, check if we need to cast an ability
	if tickCount % 7 == 0 then
		sevenCount = sevenCount +1
		--barrage every 28 seconds
		if sevenCount % 4 == 0 then
			Barrage()
		end
		--rocket every 21 seconds
		if sevenCount % 3 == 0 then
			NewRadarPulse()
		end
		--TODO at 25% enable ContinuousRadarScan() and then no longer do radarScan
		--every 6 do either scan or whirlwind. 
		if sevenCount % 6 == 0 then
			if not didJustScan and not isContinuousScanRunning then
				RadarScan()
				didJustScan = true
			else
				NewWhirlWind()
				didJustScan = false
			end

			--lvl up rocket:
			if thisEntity.homing_missile:GetLevel() < 4 then 
				thisEntity.homing_missile:SetLevel(thisEntity.homing_missile:GetLevel() +1)
			end
		end
	end



	--Auto attack closest enemy is no other action is happening:
	if not _G.IsGyroBusy then
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #enemies > 0 then
			_G.whirlwindTargets[#_G.whirlwindTargets +1] = enemies[1]
			AddToAbilityQueue(thisEntity.gyro_base_attack, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)			
		end
	end

	--ENRAGE PHASE
	--if hp below % then start ContinuousRadarScan
	if thisEntity:GetHealthPercent() < 25 and not isContinuousScanRunning then
		ContinuousRadarScan()
		isContinuousScanRunning = true
	end


	return dt
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

	--Fight initial sequence:
		--suck players in. 
		-- then Barrage
		-- then rockets. 
		-- begin main loop

	-- main loop; spells ( barrage, newWW, rocketPulse, calldownScan)
	--cooldown / frequency:
		-- barrage, semi freq, it lasts for 7ish seconds, so maybe every 21 seconds
		-- newWW, less freq, lasts 10-20 seconds, so maybe every 60 seconds
		--rocketPulse, freq (become less freq with lvlUp, it's easy to dodge early and fast to cast. Cast time 2-3 seconds, cooldown 14s?
		--calldownScan less freq, takes maybe 5-10 seconds for spell to scan and then calldown, cast maybe every 60 seconds

	if tickCount == 2 then
		WhirlWind()
	end




	--TESTING:
	-- if (tickCount % 10 == 0) then
	-- --if (tickCount == 5) then
	-- 	CurrentTestCode()
	-- 	--ContinuousRadarScan()
	-- end
	--Script the first x seconds to introduce the spells, then use CDs..

	
	-- start this loop after the introductory sequence.
	-- rockets, followed by Barrage or Whirlwind
	-- if tickCount > 4 + whirlWindDuration + radarPulseDuration + barrageDuration + whirlWindDuration + radarPulseDuration + radarScanDuration then 
	-- 	waitAmount = waitAmount - 1
	-- 	if waitAmount < 1 then
	-- 		--level up rocket. 
	-- 		if thisEntity.homing_missile:GetLevel() < 4 then 
	-- 			thisEntity.homing_missile:SetLevel(thisEntity.homing_missile:GetLevel() +1)
	-- 		end

	-- 		--cast barrage and then x seconds afterwards cast the next ability
	-- 		NewRadarPulse()

	-- 		--pick a spell and cast it.
	-- 		local spellNum = RandomInt(1,2) 
	-- 		if spellNum == 1 then
	-- 			waitAmount = waitAmount + radarPulseDuration + barrageDuration

	-- 			Timers:CreateTimer({
	-- 				endTime = radarPulseDuration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	-- 				callback = function()
	-- 					Barrage()
	-- 				end
	-- 			})
	-- 		end
	-- 		if spellNum == 2 then
	-- 			waitAmount = waitAmount + radarPulseDuration + whirlWindDuration
	-- 			Timers:CreateTimer({
	-- 				endTime = radarPulseDuration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	-- 				callback = function()
	-- 					NewWhirlWind()
	-- 				end
	-- 			})
	-- 		end
	-- 	end
	-- end

	--ENRAGE PHASE
	--if hp below % then start ContinuousRadarScan
	-- if thisEntity:GetHealthPercent() < 50 and not continuousRadarScanStarted then
	-- 	--print("Casting ContinuousRadarScan()")
	-- 	ContinuousRadarScan()
	-- 	continuousRadarScanStarted = true
	-- end

	--initial delay isn't working how I think it is... need to debug this in excel.
	-- local initialDelay = 2
	-- if ( (tickCount - initialDelay ) % COOLDOWN_RADARSCAN ) == 0 then --cast repeatedly
	-- 	--Each scan spell will be responsible for creating
	-- 	if RADAR_SPELL == RADAR_SCAN then
	-- 		--todo: add particle effect from stefan, still use my code to control the 'model' of the spell. replace DebugDraw with particle
	-- 		--RadarScan()
	-- 		--alternate between scan and pulse
	-- 		RADAR_SPELL = RADAR_PULSE
	-- 		return dt
	-- 	end
	-- 	if RADAR_SPELL == RADAR_PULSE then
	-- 		--todo: add particle effect from stefan, still use my code to control the 'model' of the spell. replace DebugDraw with particle
	-- 		--NewRadarPulse()
	-- 		--alternate between scan and pulse
	-- 		--RADAR_SPELL = RADAR_SCAN
	-- 		return dt
	-- 	end
	-- end

	-- initialDelay = 5
	-- local rbRadius = 500
	-- --Cast either RocketBarrage (RB) or FlakCannon(FC) based on how many units are within rbRadius range
	-- if ( (tickCount - initialDelay) % COOLDOWN_RB_FC ) == 0 then --cast repeatedly
 -- 		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, rbRadius,
 -- 		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

 -- 		if #enemies > 0 then
 -- 			--print("Enemies nearby, casting RocketBarrage")
	-- 		--AddToAbilityQueue(thisEntity.rocket_barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, "gyrocopter_gyro_attack_01")
	-- 		--AddToAbilityQueue(thisEntity.rocket_barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- 	else
	-- 		--print("No Enemies nearby, casting FlakCannon")
	-- 		--AddToAbilityQueue(thisEntity.flak_cannon, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, "gyrocopter_gyro_attack_01")
	-- 		--AddToAbilityQueue(thisEntity.flak_cannon, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- 	end
	-- end

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


--TODO: check if I still use this and if not remove it
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
	--melee first and then ranged.
	AddToAbilityQueue(thisEntity.rocket_barrage_melee, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	--2.5 seconds delayed, run once
	Timers:CreateTimer({
		endTime = 3.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			AddToAbilityQueue(thisEntity.rocket_barrage_ranged, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		end
	})
end	

local wwsuckDuration = 7
local whirlWindDuration = 10
_G.whirlwindTargets = {}
function NewWhirlWind()
	_G.IsGyroBusy = true

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

	-- "gyrocopter_gyro_move_07" "Rotating!"
	-- "gyrocopter_gyro_attack_05" "gyrocopter: Turn and burn!"
	thisEntity:EmitSound("gyrocopter_gyro_attack_05")

	Timers:CreateTimer(function()
		currentTick = currentTick + 1
		if currentTick >= totalTicks then
			_G.IsGyroBusy = false
			return
		end

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
		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, originZeroZ, endPoint, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )

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

			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.whirlwind_attack:entindex(),
				Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
			})

			--AddToAbilityQueue(thisEntity.gyro_base_attack, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)			
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
	_G.IsGyroBusy = true

	-- "gyrocopter_gyro_attack_15" "gyrocopter: C'mere you!"
	thisEntity:EmitSound("gyrocopter_gyro_attack_15")

	--print("WhirlWind() called")
	thisEntity:SetBaseMoveSpeed(flyingMs)
	
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
		currentTick = currentTick +1

		-- during whirlwind play these:
		-- "gyrocopter_gyro_move_29" "gyrocopter: Meeeeoooooooowwwwnnn!"
		-- "gyrocopter_gyro_move_30" "gyrocopter: Eeeooooownnn!"
		-- "gyrocopter_gyro_move_31" "gyrocopter: Sshhhhhhzzzoooo!"
		-- "gyrocopter_gyro_move_32" "gyrocopter: Mmmmmw!"
		if (totalTicks / 4) == currentTick then
			thisEntity:EmitSound("gyrocopter_gyro_move_29")
		end
		--HACK: coz totalTicks / 3 isn't a whole number. it's 46.666666667
		--if (totalTicks / 3) == currentTick then
		if currentTick == 47 then
			thisEntity:EmitSound("gyrocopter_gyro_move_30")
		end
		if (totalTicks / 2) == currentTick then
			thisEntity:EmitSound("gyrocopter_gyro_move_31")
		end
		if currentTick == 100 then 
			thisEntity:EmitSound("gyrocopter_gyro_move_32")
		end


		--start casting CallDown before the end of whirlwind
		local cooldownLeadTime = 3 / tickInterval --ticks in 3 seconds
		if currentTick + cooldownLeadTime == totalTicks then
			if not pushEnemyAway then
				--calldown on gyros current position
				CastCallDownAt(thisEntity:GetAbsOrigin())
				--InstantlyCastCallDownAt(thisEntity:GetAbsOrigin())
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
					--wait a second in case still moving then unset IsGyroBusy
					Timers:CreateTimer({
						endTime = 0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
						callback = function()
							_G.IsGyroBusy = false 
							return
						end
					})
					return
				end
			end)
			return 
		end

		--update ability model
		length = length + lengthIncrement
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


-- TODO: stop using this and start using call_down ability	
function CastCallDownAt(location)
	AddToAbilityQueue(thisEntity.call_down, DOTA_UNIT_ORDER_CAST_POSITION, location, false, nil)
end

--TODO: remove this method and implement a better abilityQueue
function InstantlyCastCallDownAt(location)
	--AddToAbilityQueue(thisEntity.call_down, DOTA_UNIT_ORDER_CAST_POSITION, location, false, nil)

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = location,
		AbilityIndex = thisEntity.call_down:entindex(),
		Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
	})

end



local enemiesScannedThisRevolution = {}
function ContinuousRadarScan()
	local revolutionDuration = 5
	local frameDuration = 0.05

	local pieSize = 5
	local angleIncrement = 2
	local endAngle = pieSize
	local startAngle = 0
	local currentAngle = startAngle


	local radius = 1800
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
					-- if displayDebug then
					-- 	DebugDrawCircle(enemy:GetAbsOrigin(), Vector(0,255,0), 128, 100, true, frameDuration)
					-- end
					enemiesScannedThisRevolution[enemy] = true --little hack so Contains works 
					CastCallDownAt(enemy:GetAbsOrigin())
					--InstantlyCastCallDownAt(thisEntity:GetAbsOrigin())
				end
			end

		end

		endAngle = endAngle - angleIncrement
		return frameDuration
		--when to stop?
	end)

end



newEnemiesScanned = {}
function NewRadarScan()
    local particleName = "particles/gyrocopter/red_phoenix_sunray.vpcf"
    local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )	

    Clear(enemiesScanned)

	local radius = 2500
	local spellDuration = 3 --seconds
	local currentFrame = 1
	local totalFrames = 120
	local frameDuration = spellDuration / totalFrames -- 2 / 120 = 0.016?
	local totalDegreesOfRotation = 360
	local degreesPerFrame = totalDegreesOfRotation / totalFrames
	
	local currentAngle = 0

	Timers:CreateTimer(function()	
		local origin = thisEntity:GetAbsOrigin()
		currentFrame = currentFrame +1
		currentAngle = currentAngle +degreesPerFrame
		
		--print("currentAngle = ", currentAngle)		

		--Scan finished: any cleanup or actions on the last frame... 
		if currentFrame >= totalFrames then
			ParticleManager:DestroyParticle(pfx, true)			
			return
		end	

		local radAngle = currentAngle * 0.0174532925 --angle in radians
		local endPoint = Vector(radius * math.cos(radAngle), radius * math.sin(radAngle), 0) + origin

		ParticleManager:SetParticleControl(pfx, 0, origin + Vector(0,0,100))
		ParticleManager:SetParticleControl(pfx, 1, endPoint)

		--If this uses too much processing then use 'if i % 5 == 0' to run this 4/5 times less frequently
		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), endPoint, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
		for _,enemy in pairs(enemies) do
			if Contains(enemiesScanned, enemy) then -- already hit this enemy
				--do nothing
			else -- first time hitting this enemy
				enemiesScanned[enemy] = true --little hack so Contains works 
				CastCallDownAt(enemy:GetAbsOrigin())
			end
		end

		return frameDuration
	end)
end


enemiesScanned = {}
function RadarScan()
	-- print("RadarScan(), setting IsGyroBusy true")
	-- _G.IsGyroBusy = true
	--print("RadarScan() called")

	--TESTING Particles:
	--play stefan's particle:
	
	--Scan particle rotates counter-clockwise. RadarScan goes clockwise
	-- local effectName = "particles/custom/sirix/scan.vpcf"	
 --  	local p1Index = ParticleManager:CreateParticle(effectName, PATTACH_POINT, thisEntity)
 --  	ParticleManager:SetParticleControl(p1Index, 0, thisEntity:GetAbsOrigin())
 --  	ParticleManager:ReleaseParticleIndex(p1Index )

	-- alternatively use tinkers green sunray. lots of parts...
	--UNTESTED: code copied from tinker/green_beam.lua
    local particleName = "particles/gyrocopter/red_phoenix_sunray.vpcf"
    local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )


 --    self.end_pos = ( RotatePosition(caster:GetAbsOrigin(), QAngle(0,currentAngle,0), beam_point ) )
	-- self.end_pos = GetGroundPosition( self.end_pos, nil )
	-- self.end_pos.z = caster:GetAbsOrigin().z + 100
 --    --DebugDrawCircle(self.end_pos, Vector(0,155,0),128,50,true,60)

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

		--TODO: redo this method without the lines perDegree. that's a debug draw concept..





		local linesPerDegree = 10
		local totalLines = linesPerDegree * (endAngle - startAngle)
		--spell model 
		for i = 0, totalLines, 1 do
			currentAngle =  currentAngle + ( 1 / linesPerDegree )
			local radAngle = currentAngle * 0.0174532925 --angle in radians
			local point = Vector(radius * math.cos(radAngle), radius * math.sin(radAngle), 0)
			--print("Calculated point = ", point)
			local originZeroZ = Vector(origin.x, origin.y,0)
			local originPlusExtraZ = Vector(origin.x, origin.y, origin.z +100)
			
			ParticleManager:SetParticleControl(pfx, 0, originPlusExtraZ)
			ParticleManager:SetParticleControl( pfx, 1, point + originPlusExtraZ)
			

			--DEBUG draw:
			DebugDrawLine(originZeroZ, point + originZeroZ, 255,0,0, true, frameDuration)
			--DebugDrawLine_vCol(originZeroZ, point + originZeroZ, Vector(255,0,0), true, 128, frameDuration)

			--If this uses too much processing then use 'if i % 5 == 0' to run this 4/5 times less frequently
			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, originZeroZ, point + originZeroZ, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
			for _,enemy in pairs(enemies) do
				if Contains(enemiesScanned, enemy) then -- already hit this enemy
					--do nothing
				else -- first time hitting this enemy
					-- if displayDebug then
					-- 	DebugDrawCircle(enemy:GetAbsOrigin(), Vector(0,255,0), 128, 100, true, frameDuration * 8)
					-- end

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
						--InstantlyCastCallDownAt(enemy:GetAbsOrigin())

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
	local sound1 = "gyrocopter_gyro_attack_09" -- "gyrocopter_gyro_attack_09" "gyrocopter: I have visual!"
	local sound2 = "gyrocopter_gyro_attack_10" -- "gyrocopter_gyro_attack_10" "gyrocopter: Hostile identified."

	local radius = 0
	local endRadius = 2000
	local radiusGrowthRate = 25
	local frameDuration = 0.02


	--Particle: currently using razor plasmafield as an indicator. 
	--TODO: figure out how this speed relates to radiusgrowth rate. I tweaked the values manually to get them to align
	-- it's like speed per second?
	local particleSpeed = 700
    local nfx = ParticleManager:CreateParticle("particles/gyrocopter/gyro_razor_plasmafield.vpcf", PATTACH_POINT_FOLLOW, thisEntity)
    ParticleManager:SetParticleControl(nfx, 0, thisEntity:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 1, Vector(particleSpeed, endRadius, 1))

    -- do this at the end: (this makes it return?, maybe I can just destroy particle once max range)
	-- ParticleManager:SetParticleControl(nfx, 1, Vector(-speed, maxRadius, 1))

	--If unable to get it perfectly just do some aoe particle to indicate this spell has been cast.

	-- print("NewRadarPulse(), setting IsGyroBusy true")
	-- _G.IsGyroBusy = true	

	local enemiesDetected = {}

	
	local currentAlpha = 10
	Timers:CreateTimer(function()	
		currentAlpha = currentAlpha + 1
		--update model
		local origin = thisEntity:GetAbsOrigin()
		if radius < endRadius then
			radius = radius + radiusGrowthRate
		else --else, last frame. Flash the circle one last time with higher alpha
			DebugDrawCircle(origin, Vector(255,0,0), 128, radius, true, frameDuration*2)
			_G.IsGyroBusy = false	
			print("End frame. Releasing particle")
			--UNTESTED:
			ParticleManager:DestroyParticle(nfx, true)
			ParticleManager:ReleaseParticleIndex(nfx)
			return
		end
		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), currentAlpha, radius, true, frameDuration*2)		
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) --draw same thing, radius-1, for double thick line/circle edge

		--HACK: to implement some delay, play this sound after a second or two of the spell starting
		if currentAlpha == 50 then
			thisEntity:EmitSound(sound2)
		end

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
					AddToAbilityQueue(thisEntity.homing_missile, DOTA_UNIT_ORDER_CAST_TARGET, enemy, false, nil)
			end
		end
		return frameDuration
		--TODO: implement deltaTime for consistent time frames, don't delay by x, delay by x - timeTakenToProcess		
	end)
end