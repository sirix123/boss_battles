gyrocopter = class({})

LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

local initialZ = 0

--TODO: just get 4 coords, the rest is made of that. TOP, BOT, LEFT, RIGHT
local ArenaTop = 3025
local ArenaBot = 425
local ArenaLeft = -13600
local ArenaRight = -11000
local AreanMiddle = Vector((ArenaLeft/2)+(ArenaRight/2), (ArenaTop/2) + (ArenaBot/2), 132)
--MID POINT FORMULA:
-- (ArenaTop / 2 ) + (ArenaBot / 2)

local GyroArenaLocations = {}
GyroArenaLocations["N"] = Vector(AreanMiddle.x,ArenaTop,132)
GyroArenaLocations["NE"] = Vector(ArenaRight,ArenaTop,132)
GyroArenaLocations["E"] = Vector(ArenaRight,AreanMiddle.y,132)
GyroArenaLocations["SE"] = Vector(ArenaRight,ArenaBot,132)
GyroArenaLocations["S"] = Vector(AreanMiddle.x,ArenaBot,132)
GyroArenaLocations["SW"] = Vector(ArenaLeft,ArenaBot,132)
GyroArenaLocations["W"] = Vector(ArenaLeft,AreanMiddle.y,132)
GyroArenaLocations["NW"] = Vector(ArenaLeft,ArenaTop,132)
GyroArenaLocations["C"] = AreanMiddle

-- On Spawn, init any vars, start MainThinker
function Spawn( entityKeyValues )
	--TESTING:
	--SessionManager:SendSessionData()

	--disable attacks.
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.

	--GLOBALS: setting these in spawn so each time gyro spawns they're reset
	_G.IsGyroBusy = false
	_G.RadarPulseEnemies = {}
	_G.PulseAndCast = "call_down"
	_G.RadarScanEnemies = {}
	_G.ScanAndCast = "smart_homing_missile_v2"
	_G.ContinuousRadarScanEnemies = {}
	_G.BaseAttackTargets = {}
	_G.FlakCannonTargets = {}
	_G.BarrageTargets = {}
	_G.WhirlwindTargets = {}

	_G.HomingMissileTargets = {}

	--TODO: get the arena bounds for flee...
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
	thisEntity.dumb_homing_missile = thisEntity:FindAbilityByName( "dumb_homing_missile_v2" )
	thisEntity.smart_homing_missile = thisEntity:FindAbilityByName( "smart_homing_missile_v2" )
	thisEntity.dumb_rocket_waves = thisEntity:FindAbilityByName("dumb_rocket_waves")
	thisEntity.continuous_radar_scan = thisEntity:FindAbilityByName( "continuous_radar_scan" )

	thisEntity.whirlwind = thisEntity:FindAbilityByName( "whirlwind" )
	thisEntity.whirlwind_attack = thisEntity:FindAbilityByName( "whirlwind_attack" )

	--TO IMPLEMENT: 
	--thisEntity.tracking_beacon = thisEntity:FindAbilityByName( "tracking_beacon" )
	
	--abilityQueue thinker
	thisEntity:SetContextThink( "AbilityQueue", AbilityQueue, 0.1)

	--AI Files:
	if _G.GyroAI == nil then
		_G.GyroAI = "Main"
	end
	if _G.GyroAI == "Main" then
		thisEntity:SetContextThink( "MainLoop", MainLoop, 0.1 )
	end
	if _G.GyroAI == "Test" then
		thisEntity:SetContextThink("Test", Test, 1)
	end
	if _G.GyroAI == "Swoop" then
		thisEntity:SetContextThink( "Swoop", SwoopBuild, 0.1 )		
	end
	
end


function CurrentTestCode()
	print("CurrentTestCode()")

	--local furthestLoc = FindLocationFurtherFromPlayers()
	--print("furthestLoc = ", furthestLoc)
	--AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, furthestLoc, false, nil)

	AddToAbilityQueue(thisEntity.whirlwind, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)


	-- local endPoint = thisEntity:GetAbsOrigin() + (thisEntity:GetForwardVector() * 2000)
	-- local duration = 5

	-- Working Jakiro macropyre
	-- local particleName = "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf"
	-- local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
	-- ParticleManager:SetParticleControl( pfx, 0, thisEntity:GetAbsOrigin() )
	-- ParticleManager:SetParticleControl( pfx, 1, endPoint )
	-- ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )

	--TESTING my macropyre
	-- local particleName = "particles/gyrocopter/macropyre.vpcf"
	-- local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
	-- ParticleManager:SetParticleControl( pfx, 0, thisEntity:GetAbsOrigin() )
	-- ParticleManager:SetParticleControl( pfx, 1, endPoint )
	-- ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )	




	
	-- Test any abilities that need a target:
	-- local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000,
	-- DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	-- for _,enemy in pairs(enemies) do
	-- 	--TEST HOMING MISSILE
	-- 	_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = {}
	-- 	_G.HomingMissileTargets[#_G.HomingMissileTargets] = enemy
	-- 	--AddToAbilityQueue(thisEntity.dumb_homing_missile, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- 	--AddToAbilityQueue(thisEntity.smart_homing_missile, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- 	--AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, enemy:GetAbsOrigin(), false, nil)
	-- end

	--thisEntity.smart_homing_missile:SetLevel(thisEntity.smart_homing_missile:GetLevel() +1)

	--Test any abilities that don't need a target
	--AddToAbilityQueue(thisEntity.absorbing_shell, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	--AddToAbilityQueue(thisEntity.dumb_rocket_waves, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	--AddToAbilityQueue(thisEntity.rotating_flak_cannon, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	--AddToAbilityQueue(thisEntity.whirlwind, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
end


function Test()
	CurrentTestCode()
	return 1000
end

local dt = 0.1
local tickCount = 0
local timeOfLastSwoop = 0
local isHpAbove75Percent = true
local isHpAbove50Percent = true


local spellCdMin = 10
local spellCdMax = 15
local nextSpellAtTick = 0

--COMBAT SEQUENCE: 
-- Swoop to a ranged player.
-- Shoot rockets (alternate smart/dumb) at ranged targets
-- Do barrage? / calldown?
local nextSpellIndex = 1
local spellSequence = {}


local nextHp10PercentThreshold = 90  --TODO: skip 50%, 
	--or maybe 15% is better than 10% for this. 85, 70, 55, 40, 25! skip, 10 

local nextHp25PercentThreshold = 75

function MainLoop()
	--Check certain game states and return early if needed
	if not IsServer() then return end
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 0.5 end

	tickCount = tickCount+1
	--TESTING:
	if (tickCount % 50 == 0) then
	--if (tickCount == 50) then
		--CurrentTestCode()
	end	

	--init: combat sequence and then perform opening sequence
	--Opening sequence: swoop(to South), barrage, zoom(to Center), missile dumb waves
	if tickCount == 1 then
		--COMBAT SEQUENCE: for after this initial sequence
		-- Swoop to a ranged player.
		-- Shoot rockets (alternate smart/dumb) at ranged targets
		-- Do barrage? / calldown?
		spellSequence[1] = thisEntity.swoop
		spellSequence[2] = thisEntity.dumb_rocket_waves
		spellSequence[3] = thisEntity.barrage

		--openning sequence:
		initialZ = thisEntity:GetAbsOrigin().z
		--Swoop players immediately
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_FARTHEST, false )
		if #enemies > 0 then
			AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, GyroArenaLocations["S"], false, nil)
		end
		AddToAbilityQueue(thisEntity.barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, GyroArenaLocations["C"], false, nil)
		AddToAbilityQueue(thisEntity.dumb_rocket_waves, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	-- The openning sequences finishes after: 175 ticks
	-- the macropyre dissapears after 250 ticks
	-- BUGISH: risky to hardcode this... what if spell durations change?
	--TODO: calc the wait period based on spell durations from kvp file
		nextSpellAtTick = 250 --TODO: actually calc this based on the above spell durations
	end

	-- Every 10% hp loss, flee, to a distant location. (TODO: algo to calc/get location to flee)
	if (thisEntity:GetHealthPercent() <= nextHp10PercentThreshold) then
		print("gyro hp crossed ".. nextHp10PercentThreshold .. " threshold. ")
		nextHp10PercentThreshold = nextHp10PercentThreshold - 10
		
		AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, FindLocationFurtherFromPlayers(), false, nil)
		--TODO new calldown targetting?
			-- new calldown should: get each players pos, wait 0.2 seconds, get each players pos, calculate the direction they're heading. 
			--cast calldown x units ahead of them in the direction they're heading. 
			--so it's not centered of exactly, but infront of them, they have to change direction to avoid

		nextSpellAtTick = nextSpellAtTick + RandomInt(spellCdMin, spellCdMax) 		
	end

	-- Every 25% hp loss, fly/flee to center. And do whirlwind
		-- Afterwards, do absorbing shell. 
	if (thisEntity:GetHealthPercent() <= nextHp25PercentThreshold) then
		print("gyro hp crossed ".. nextHp25PercentThreshold .. " threshold. ")
		nextHp25PercentThreshold = nextHp25PercentThreshold - 10

		--I don't really want to flee, just flyTo?
		AddToAbilityQueue(thisEntity.flee, DOTA_UNIT_ORDER_CAST_POSITION, GyroArenaLocations["C"], false, nil)
		AddToAbilityQueue(thisEntity.whirlwind, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		AddToAbilityQueue(thisEntity.absorbing_shell, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
	end


	if tickCount == nextSpellAtTick then
		local spellCastThisCycle = false
		--print("tickCount == nextSpellAtTick. casting")
		nextSpellAtTick = nextSpellAtTick + (RandomInt(spellCdMin, spellCdMax)  / dt)
		--print("next spell up : ".. spellSequence[nextSpellIndex]:GetAbilityName())

		-- cast this spell: spellSequence[nextSpellIndex]
		if spellSequence[nextSpellIndex] == thisEntity.swoop then
			AddToAbilityQueue(thisEntity.swoop, DOTA_UNIT_ORDER_CAST_POSITION, FindFurthestPlayer():GetAbsOrigin(), false, nil)			

		end

		--dumb rocket or smart rocket, alternate between the two.
		--cast dumb, then set so the next time it casts smart
		if spellSequence[nextSpellIndex] == thisEntity.dumb_rocket_waves then
			AddToAbilityQueue(thisEntity.dumb_rocket_waves, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
			spellSequence[nextSpellIndex] = thisEntity.smart_homing_missile
			spellCastThisCycle = true --to stop the next if instantly getting triggered
		end
		--cast smart, then set so the next time it casts dumb
		if spellSequence[nextSpellIndex] == thisEntity.smart_homing_missile and not spellCastThisCycle then
			--TODO: one missile or one for each ranged target?
			_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = {}
			_G.HomingMissileTargets[#_G.HomingMissileTargets] = FindFurthestPlayer()
			AddToAbilityQueue(thisEntity.smart_homing_missile, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
			spellSequence[nextSpellIndex] = thisEntity.dumb_rocket_waves
		end

		if spellSequence[nextSpellIndex] == thisEntity.barrage then
			AddToAbilityQueue(thisEntity.barrage, DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, false, nil)
		end

		--print("nextSpellAtTick = ", nextSpellAtTick)
		nextSpellIndex = nextSpellIndex +1
		if nextSpellIndex > #spellSequence then
			nextSpellIndex = 1
		end
	end

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


-- Generic boss agro table functions
--------------------------------------------------------------------
--TODO; how do I track dmg taken and who it comes from




-- Generic boss ability queue functions
--------------------------------------------------------------------

local abilityQueue = {}
--BUG? when tickDelay is too low you can't queue multiple abilities, some will get skipped
--local tickDelay = 0.01 
local tickDelay = 0.1

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
		--print(#abilityQueue.. " abilities in queue")
		local abilityToCast = abilityQueue[1].ability
		--print("casting ".. abilityQueue[1].ability:GetAbilityName())

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
--TODO: delete these if unused

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


-- Util AI algos
------------------------------------

-- check where all players are, and then compare against GyroArenaLocations, find the most distant one.
-- algo: sum the distance of each player to that loc.
function FindLocationFurtherFromPlayers()
	local furthestLoc = GyroArenaLocations["N"] --set a temp value
	local furthestDist = 0
	local arenaLocationDistanceMap = {}

	-- loop over the arena locations and determine which one is furthests from all players
	for i, GyroArenaLocation in pairs(GyroArenaLocations) do
		local distanceSum =0
		-- Get all players, then calc dist for each one and add to distanceSum
		for j, hero in pairs(HERO_LIST) do
			local distance = (hero:GetAbsOrigin() - GyroArenaLocation):Length2D()
			distanceSum = distanceSum + distance
		end
		arenaLocationDistanceMap[GyroArenaLocation] = distanceSum
		--print("players distance to " .. i .. " = " .. distanceSum)
	end

	--now iterate arenaLocationDistanceMap to find the max
	for arenaLoc, playersDistance in pairs(arenaLocationDistanceMap) do
		if playersDistance > furthestDist then
			furthestDist = playersDistance
			furthestLoc = arenaLoc
		end
	end
	return furthestLoc
end

function FindFurthestPlayer()
	local furthestDist = 0 
	local furthestPlayer = HERO_LIST[1] 

	for j, hero in pairs(HERO_LIST) do
		local distance = (hero:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()

		if distance > furthestDist then
			furthestDist = distance
			furthestPlayer = hero
		end
	end
	return furthestPlayer
end