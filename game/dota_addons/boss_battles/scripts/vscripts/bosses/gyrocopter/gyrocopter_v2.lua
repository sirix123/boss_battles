gyrocopter = class({})

LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

--TODO: implement agro table...

local displayDebug = true
local initialZ = 0

-- On Spawn, init any vars, start MainThinker
function Spawn( entityKeyValues )
	--GLOBALS: setting these in spawn so each time gyro spawns they're reset
	--Others are used too... move em up here
	_G.IsGyroBusy = false

	_G.RadarPulseEnemies = {}
	_G.PulseAndCast = "dumb_homing_missile_v2"

	_G.RadarScanEnemies = {}
	_G.ScanAndCast = "smart_homing_missile_v2"
	
	_G.BaseAttackTargets = {}
	_G.FlakCannonTargets = {}
	_G.BarrageTargets = {}

	
	-- Not sure if I need two tables now, one for dumb_homing_missile and the other for smart_homing_missile
	_G.HomingMissileTargets = {}
	_G.ActiveHomingMissiles = {}

	thisEntity.flee = thisEntity:FindAbilityByName( "flee" )

	--TESTED and working in single player, TODO test with multiple players. 
	thisEntity.barrage = thisEntity:FindAbilityByName( "barrage" ) 
	thisEntity.barrage_radius_melee = thisEntity:FindAbilityByName( "barrage_radius_melee" )
	thisEntity.barrage_radius_ranged = thisEntity:FindAbilityByName( "barrage_radius_ranged" )
	thisEntity.barrage_radius_attack = thisEntity:FindAbilityByName( "barrage_radius_attack" )
	thisEntity.radar_scan = thisEntity:FindAbilityByName( "radar_scan" )
	thisEntity.radar_pulse = thisEntity:FindAbilityByName( "radar_pulse" )
	thisEntity.swoop = thisEntity:FindAbilityByName( "swoop" )
	thisEntity.absorbing_shell = thisEntity:FindAbilityByName( "absorbing_shell" )
	thisEntity.gyro_base_attack = thisEntity:FindAbilityByName( "gyro_base_attack" )	

	--BUG: self is not unique... each time I cast this spell self is identical to the previous cast and subsequent cast...
	--TODO: need a unique ID / to track each rocket. Probably just rewrite my code and use _G.ActiveHomingMissiles[i] instead of self.
	thisEntity.dumb_homing_missile = thisEntity:FindAbilityByName( "dumb_homing_missile_v2" )
	thisEntity.smart_homing_missile = thisEntity:FindAbilityByName( "smart_homing_missile_v2" )


	--UNTESTED: half implemented
	--TO IMPLEMENT: 
	--thisEntity.tracking_beacon = thisEntity:FindAbilityByName( "tracking_beacon" )
	thisEntity.rotating_flak_cannon = thisEntity:FindAbilityByName( "rotating_flak_cannon" )
	thisEntity.rotating_flak_cannon_attack = thisEntity:FindAbilityByName( "rotating_flak_cannon_attack" )	

	--still not sure the purpose of whirlwind...
	--maybe just suck players in, then stun em, and fly away to trigger a phase shift
	--thisEntity.whirlwind = thisEntity:FindAbilityByName( "whirlwind" )
	
	--abilityQueue thinker
	thisEntity:SetContextThink( "AbilityQueue", AbilityQueue, 0.1)
	thisEntity:SetContextThink( "MainLoop", MainLoop, 0.1 )

	--thisEntity:SetContextThink( "SwoopBuild", SwoopBuild, 0.1 )
	--disable attacks.
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
end


function CurrentTestCode()
	print("CurrentTestCode()")
	-- Test any abilities that need a target:
	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000,
	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	for _,enemy in pairs(enemies) do
		--TEST HOMING MISSILE
		_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = {}
		_G.HomingMissileTargets[#_G.HomingMissileTargets] = enemy
		AddToAbilityQueue(thisEntity.dumb_homing_missile, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		--AddToAbilityQueue(thisEntity.smart_homing_missile, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)

		--AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, enemy:GetAbsOrigin(), false, nil)
	end

	--thisEntity.smart_homing_missile:SetLevel(thisEntity.smart_homing_missile:GetLevel() +1)
	thisEntity.dumb_homing_missile:SetLevel(thisEntity.dumb_homing_missile:GetLevel() +1)

	--Test any abilities that don't need a target
	
	--AddToAbilityQueue(thisEntity.absorbing_shell, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	--AddToAbilityQueue(thisEntity.barrage_rotating, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
end


local dt = 0.1
local tickCount = 0

local timeOfLastSwoop = 0
local isHpAbove75Percent = true
local isHpAbove50Percent = true

function MainLoop()
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1
	--print("tickCount = "..tickCount.. " IsGyroBusy? ".. tostring(IsGyroBusy))

	--TESTING:
	if (tickCount % 30 == 0) then
	--if (tickCount == 50) then
		--CurrentTestCode()
	end	

	--TESTING:
	if tickCount == 90 then
		--AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, thisEntity:GetAbsOrigin() + Vector(0,2000,0), false, nil)
		--AddToAbilityQueue(thisEntity.zoom, DOTA_UNIT_ORDER_CAST_POSITION, thisEntity:GetAbsOrigin() + Vector(0,-2000,0), false, nil)
	end
	
	--init:
	if tickCount == 1 then
		initialZ = thisEntity:GetAbsOrigin().z
		--Swoop players immediately
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_FARTHEST, false )
		if #enemies > 0 then
			AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, enemies[1]:GetAbsOrigin(), false, nil)
		end
		timeOfLastSwoop = tickCount
	end



	--UNTESTED:
	if (isHpAbove75Percent and thisEntity:GetHealthPercent() <= 75) then
		isHpAbove75Percent = false
		--print("hp below 75%. Time to zoom")

		--UNTESTED: zoom away... need better algo to decide where to zoom to....
		AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, thisEntity:GetAbsOrigin() + Vector(0,2500,0), false, nil)

		thisEntity.dumb_homing_missile:SetLevel(thisEntity.dumb_homing_missile:GetLevel() +1)
		thisEntity.smart_homing_missile:SetLevel(thisEntity.smart_homing_missile:GetLevel() +1)
	end

	if (isHpAbove50Percent and thisEntity:GetHealthPercent() <= 50) then
		isHpAbove50Percent = false
		--print("hp below 50%. Time to zoom")
	end

	--at 5th second and every 15 seconds afterwards. 
	if (tickCount >= 50 and (tickCount-50) % 150 == 0  ) then
		--print("queueing radarPulse. call_down or dumb_homing_missile")
		-- alternate between casting call_down and dhm
		if (_G.PulseAndCast == "call_down") then
			_G.PulseAndCast = "dumb_homing_missile_v2"
		else
			_G.PulseAndCast = "call_down"
		end
		AddToAbilityQueue(thisEntity.radar_pulse, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	end

	--at 10th second and every 30 seconds afterwards, cast barrage
	if (tickCount >= 100 and (tickCount-100) % 300 == 0  ) then
		--print("queueing  barrage")
		AddToAbilityQueue(thisEntity.barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	end

	--at 30th second and every 60 seconds afterwards, cast shm
	if (tickCount >= 300 and (tickCount-300) % 600 == 0  ) then
		--print("queueing  radarScan and smart_homing_missile")
		_G.ScanAndCast = "smart_homing_missile_v2"
		AddToAbilityQueue(thisEntity.radar_scan, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	end

	if (tickCount % 550 == 0 ) then
		--print("55 seconds, queueing  Absorbing Shell")
		AddToAbilityQueue(thisEntity.absorbing_shell, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	end

	-- swoop every 30 seconds, or 30 seconds since last swoop.
	--UNTESTED: might overlap some other abilities but hopefully abilityQueue handles this
	if (tickCount > (timeOfLastSwoop+300) ) then
		--print("queueing swoop!")
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #enemies > 0 then
			AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, enemies[1]:GetAbsOrigin(), false, nil)
		end
		timeOfLastSwoop = tickCount
	end

	--TODO: rotating_flak_cannon
	--TODO implement agro table
	--Auto attack closest enemy is no other action is happening:
	if not _G.IsGyroBusy and (tickCount % 7) == 0 then
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #enemies > 0 then
			_G.BaseAttackTargets[#_G.BaseAttackTargets +1] = enemies[1]
			AddToAbilityQueue(thisEntity.gyro_base_attack, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)			
		end
	end
	
	return dt
end



-- AI / sequence. SwoopBuild is a swoop first and swoop often build. Gyro uses swoop as a priority. Casting abilities in between. 
-- Every ability 
local dt = 0.1
local tickCount = 0

local timeOfLastSwoop = 0
local isHpAbove75Percent = true
local isHpAbove50Percent = true

function SwoopBuild()
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1
	--print("tickCount = "..tickCount.. " IsGyroBusy? ".. tostring(IsGyroBusy))


	--plan...
	-- every 10ish seconds gyro swoops to a target, then uses one of his spells (barrage)

	-- todo; make missiles and call_down happen for ranged only.
	--implement whirlwind where gyro spins, after 3 seconds it gets too strong and starts sucking nearby players in... 
		--it's just a melee aoe?

	--TESTING:
	if (tickCount % 80 == 0) then
	--if (tickCount == 50) then
		CurrentTestCode()
	end	

	--TESTING:
	if tickCount == 90 then
		--AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, thisEntity:GetAbsOrigin() + Vector(0,2000,0), false, nil)
		--AddToAbilityQueue(thisEntity.zoom, DOTA_UNIT_ORDER_CAST_POSITION, thisEntity:GetAbsOrigin() + Vector(0,-2000,0), false, nil)
	end
	
	--init:
	-- if tickCount == 1 then
	-- 	initialZ = thisEntity:GetAbsOrigin().z
	-- 	--Swoop players immediately
	-- 	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_FARTHEST, false )
	-- 	if #enemies > 0 then
	-- 		AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, enemies[1]:GetAbsOrigin(), false, nil)
	-- 	end
	-- 	timeOfLastSwoop = tickCount
	-- end



	-- --UNTESTED:
	-- if (isHpAbove75Percent and thisEntity:GetHealthPercent() <= 75) then
	-- 	isHpAbove75Percent = false
	-- 	--print("hp below 75%. Time to zoom")

	-- 	--UNTESTED: zoom away... need better algo to decide where to zoom to....
	-- 	AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, thisEntity:GetAbsOrigin() + Vector(0,2500,0), false, nil)

	-- 	thisEntity.dumb_homing_missile:SetLevel(thisEntity.dumb_homing_missile:GetLevel() +1)
	-- 	thisEntity.smart_homing_missile:SetLevel(thisEntity.smart_homing_missile:GetLevel() +1)
	-- end

	-- if (isHpAbove50Percent and thisEntity:GetHealthPercent() <= 50) then
	-- 	isHpAbove50Percent = false
	-- 	--print("hp below 50%. Time to zoom")
	-- end

	-- --at 5th second and every 15 seconds afterwards. 
	-- if (tickCount >= 50 and (tickCount-50) % 150 == 0  ) then
	-- 	--print("queueing radarPulse. call_down or dumb_homing_missile")
	-- 	-- alternate between casting call_down and dhm
	-- 	if (_G.PulseAndCast == "call_down") then
	-- 		_G.PulseAndCast = "dumb_homing_missile_v2"
	-- 	else
	-- 		_G.PulseAndCast = "call_down"
	-- 	end
	-- 	AddToAbilityQueue(thisEntity.radar_pulse, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- end

	-- --at 10th second and every 30 seconds afterwards, cast barrage
	-- if (tickCount >= 100 and (tickCount-100) % 300 == 0  ) then
	-- 	--print("queueing  barrage")
	-- 	AddToAbilityQueue(thisEntity.barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- end

	-- --at 30th second and every 60 seconds afterwards, cast shm
	-- if (tickCount >= 300 and (tickCount-300) % 600 == 0  ) then
	-- 	--print("queueing  radarScan and smart_homing_missile")
	-- 	_G.ScanAndCast = "smart_homing_missile_v2"
	-- 	AddToAbilityQueue(thisEntity.radar_scan, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- end

	-- if (tickCount % 550 == 0 ) then
	-- 	--print("55 seconds, queueing  Absorbing Shell")
	-- 	AddToAbilityQueue(thisEntity.absorbing_shell, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- end

	-- -- swoop every 30 seconds, or 30 seconds since last swoop.
	-- --UNTESTED: might overlap some other abilities but hopefully abilityQueue handles this
	-- if (tickCount > (timeOfLastSwoop+300) ) then
	-- 	--print("queueing swoop!")
	-- 	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	-- 	if #enemies > 0 then
	-- 		AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, enemies[1]:GetAbsOrigin(), false, nil)
	-- 	end
	-- 	timeOfLastSwoop = tickCount
	-- end

	-- --TODO: rotating_flak_cannon
	-- --TODO implement agro table
	-- --Auto attack closest enemy is no other action is happening:
	-- if not _G.IsGyroBusy and (tickCount % 7) == 0 then
	-- 	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000,
	-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	-- 	if #enemies > 0 then
	-- 		_G.BaseAttackTargets[#_G.BaseAttackTargets +1] = enemies[1]
	-- 		AddToAbilityQueue(thisEntity.gyro_base_attack, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)			
	-- 	end
	-- end
	
	return dt
end






-- Generic boss agro table functions
--------------------------------------------------------------------


--TODO; how do I track dmg taken and who it comes from






-- Generic boss ability queue functions
--------------------------------------------------------------------

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
	if _G.IsGyroBusy then
		--print("Gyro is busy. Waiting.")
	 	return tickDelay
	 else
	 	--print("Gyro not busy.")
	end

	--check if anything in the queue
	if #abilityQueue > 0 then
		local abilityToCast = abilityQueue[1].ability
		local orderType = abilityQueue[1].orderType
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
		--play a sound if set
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

	if _G.IsGyroBusy then
		--print("AddToAbilityQueue. Gyro is busy. ".. ability:GetAbilityName() .. " added to queue at index " .. #abilityQueue )
	end
end


-- Gyro Movement Functions
--------------------------------------------------------------------


--Gyro moves upwards toward altitude, in 10 increments over 1 second 
--MoveToPosition doesn't work with Z index so to change a units height I have to directly modified its AbsOrigin
--TODO: this should be a blocking function... otherwise it will get interupted and gyro won't reach height
function FlyUp(altitude, duration)
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
function FlyDown(altitude, duration)
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