gyrocopter = class({})

LinkLuaModifier( "flak_cannon_modifier", "bosses/gyrocopter/flak_cannon_modifier", LUA_MODIFIER_MOTION_NONE )


--Global used in; gyrocopter.lua, homing_missile.lua, ...
_G.ScannedEnemyLocations = {}


local currentPhase = 1

local COOLDOWN_RADARSCAN = 100
local COOLDOWN_FLAKCANNON = 10
local CAST_CALLDOWN = false

local swooping = false
local swoopDuration = 0

local isHpBelow50Percent = false
local isHpBelow10Percent = false

--DOTA_UNIT_CAP_NO_ATTACK = 0
--DOTA_UNIT_CAP_RANGED_ATTACK = 2

--Gyro locoations
local gyroHideLocation1 = Vector(11697,12272,640)
local gyroHideLocation2 = Vector(15823,12264,640)

function Spawn( entityKeyValues )
	print("Gyrocopter Spawned!")
	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.rocket_barrage = thisEntity:FindAbilityByName( "rocket_barrage" )
	thisEntity.call_down = thisEntity:FindAbilityByName( "call_down" )
	--TODO: if any of these are nil, we got a problem

	thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )
end

local tickCount = 0

function MainThinker()
	--Enemies scanned, missiles should be chasing em.
	if _G.ScannedEnemyLocations ~= nil then
		--print("MainThinker. #_G.ScannedEnemyLocations = ", #_G.ScannedEnemyLocations)
	end

	tickCount = tickCount + 1

	-- Almost all code should not run when the game is paused. Keep this near the top so we return early.
	if GameRules:IsGamePaused() == true then
		return 0.5
	end
	if thisEntity == nil then
		return
	end

	--CALL DOWN:
	if CAST_CALLDOWN then
		CallDownOnEnemies()
		CAST_CALLDOWN = false
	end

	--check current HP to trigger events
	local healthPercent = (thisEntity:GetHealth() / thisEntity:GetMaxHealth()) * 100
	
	--Trigger event at 50% hp
	if not isHpBelow50Percent and healthPercent < 80 then 
		isHpBelow50Percent = true
		--TODO: trigger event
		HalfHealthPhase()
	end
	--Trigger event at 10% hp
	if not isHpBelow10Percent and healthPercent < 10 then 
		isHpBelow10Percent = true
		--TODO: trigger event
		NearlyDeadPhase()
	end

	--ABILITY COOLDOWNS, modulus the tickCount

	--RADAR, 
	if tickCount % COOLDOWN_RADARSCAN == 0 then --cast repeatedly
		RadarSweep()
		--RadarPulse()
	end

	-- FLAK CANNON,
	if tickCount % COOLDOWN_FLAKCANNON == 0 then --cast repeatedly
		--ApplyFlakCannonModifier()
	end
	
	--SWOOP:
	if swooping then
		swoopDuration = swoopDuration +1
		--Check if at destination, if so then thisEntity:SetBaseMoveSpeed(0)
		if swoopDuration > 5 then
			thisEntity:SetBaseMoveSpeed(300)
			swooping = false
		end	
	end

	
	-- If/when a missile hit's a target do this action:
	if _G.HOMING_MISSILE_HIT_TARGET ~= nil then
		local targetLocation = _G.HOMING_MISSILE_HIT_TARGET
		_G.HOMING_MISSILE_HIT_TARGET = nil
		thisEntity:SetBaseMoveSpeed(600)
		swooping = true

		--TODO: Ideally he doesn't move exactly onto the target, but moves toward them and stops just short
		--thisEntity:MoveToPosition(targetLocation)

	end

	return 1 
end


-- Fly gyro to location, once there set flag CAST_CALLDOWN to trigger cast down
function HalfHealthPhase()
 	--TODO: move to gyroHideLocation1
 	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
 	thisEntity:SetBaseMoveSpeed(900)
 	thisEntity:MoveToPosition(gyroHideLocation1)

    --A timer to trigger any actions for when gyro arrives at his destination
	Timers:CreateTimer(function()	
		local currentPos = thisEntity:GetAbsOrigin()
		local destination = gyroHideLocation1
		local distance = (gyroHideLocation1 - currentPos):Length2D()

		if distance < 100 then
			thisEntity:SetAttackCapability(2)	
			thisEntity:SetBaseMoveSpeed(0)
			CAST_CALLDOWN = true
			return
		end
		return 0.5
	end) --end timer
end


function NearlyDeadPhase()
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
	thisEntity:SetBaseMoveSpeed(900)
	thisEntity:MoveToPosition(gyroHideLocation2)

    --A timer to trigger any actions for when gyro arrives at his destination
	Timers:CreateTimer(function()	
		local currentPos = thisEntity:GetAbsOrigin()
		local destination = gyroHideLocation2
		local distance = (gyroHideLocation2 - currentPos):Length2D()

		print("Flying to gyroHideLocation2. Distance = ", distance)
		if distance < 100 then
			thisEntity:SetAttackCapability(2)	
			thisEntity:SetBaseMoveSpeed(0)
			return
		end
		return 0.5
	end) --end timer
end


-------------------------------------------------------------------------------
--ANIMATIONS:

function MissileTargetIndicator(location)


end


-------------------------------------------------------------------------------
-- Radar Scan Abilities,
	-- Trying out different algos

-- Basically build up a list of targets through various methods
enemiesScanned = {}
function RadarSweep()
	local origin = thisEntity:GetAbsOrigin()
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

	Timers:CreateTimer(function()	
		--print("RadarSweep Timer tick")
		currentFrame = currentFrame +1
		if currentFrame >= totalFrames then
			Clear(enemiesScanned)
			return
		end	

		startAngle = endAngle - pieSize
		-- if ( math.max(0, endAngle - pieSize) > 0 ) then
		-- 	startAngle = endAngle - pieSize
		-- end
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

			--If this uses too much processing then use 'if i % 5 == 0' to run this 4/5 times less frequently
			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, originZeroZ, point + originZeroZ, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
			for _,enemy in pairs(enemies) do
				if Contains(enemiesScanned, enemy) then -- already hit this enemy
					--do nothing
				else -- first time hitting this enemy
					DebugDrawCircle(enemy:GetAbsOrigin(), Vector(0,255,0), 128, 100, true, 5)
					enemiesScanned[enemy] = true --little hack so Contains works 

					scannedEnemy = {}
					scannedEnemy.Location = shallowcopy(enemy:GetAbsOrigin())
					scannedEnemy.Enemy = enemy

					-- check if this enemy is already in the list... we don't want to keep adding them we just want to update the location
					local isNewEnemy = true
					if #_G.ScannedEnemyLocations > 0 then 
						for i = 1, #_G.ScannedEnemyLocations, 1 do
							-- already scanned this enemy, update their location
							if enemy == _G.ScannedEnemyLocations[i].Enemy then
								_G.ScannedEnemyLocations[i].Location = shallowcopy(enemy:GetAbsOrigin())
								isNewEnemy = false
							end
						end
					end

					-- first time scanning this enemy, add a new entry for them
					if isNewEnemy then
						_G.ScannedEnemyLocations[#_G.ScannedEnemyLocations +1] = scannedEnemy	
					end
					
					--Shoot a homing missile at this target:
					CastHomingMissile(enemy)
				end
			end
		end
		
		endAngle = endAngle - degreesPerFrame
		return frameDuration
	end) --end timer
end

enemiesPulsed = {}
--Scan for CallDown targets
--Basically a growing circle, highlight players that get detected
function RadarPulse()
	local radius = 200
	local endRadius = 2500
	local radiusGrowthRate = 25

	local frameDuration = 0.1


	Timers:CreateTimer(function()	
		--update model
		local origin = thisEntity:GetAbsOrigin()
		if radius < endRadius then
			radius = radius + radiusGrowthRate
		end
		
		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius, true, frameDuration)		
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration)		


		--check for hits
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		for _,enemy in pairs(enemies) do
				if Contains(enemiesPulsed, enemy) then -- already hit this enemy
					--do nothing
				else -- first time hitting this enemy 
					DebugDrawCircle(enemy:GetAbsOrigin(), Vector(0,255,0), 128, 100, true, 5)
					enemiesPulsed[enemy] = true --little hack so Contains works 

					scannedEnemy = {}
					scannedEnemy.Location = shallowcopy(enemy:GetAbsOrigin())
					scannedEnemy.Enemy = enemy

					-- check if this enemy is already in the list... we don't want to keep adding them we just want to update the location
					local isNewEnemy = true
					if #_G.PulsedEnemyLocations > 0 then 
						for i = 1, #_G.PulsedEnemyLocations, 1 do
							-- already scanned this enemy, update their location
							if enemy == _G.PulsedEnemyLocations[i].Enemy then
								_G.PulsedEnemyLocations[i].Location = shallowcopy(enemy:GetAbsOrigin())
								isNewEnemy = false
							end
						end
					end

					-- first time scanning this enemy, add a new entry for them
					if isNewEnemy then
						_G.PulsedEnemyLocations[#_G.PulsedEnemyLocations +1] = scannedEnemy	
					end
					
					--Do a call down at this location?
					
				end
		end

		return frameDuration
	end) --end timer

end

-------------------------------------------------------------------------------
-- Call Down Ability animations
-- Will be several different versions of how the call down targets are decided.


-------------------------------------------------------------
-- Below code is for the pre-dmg indicator
	--Different types of indicators:
		-- Flash a fixed radius red circle, blinking lights fixed speed
		-- Flash a fixed radius red circle, blinking lights at increasing speed 
		-- Grow a circle from small radius to full radius over indicator_duration
		-- Show radius at increasing color intensity, increase/reduce opacity over duration

--------------
	-- Flash a fixed radius red circle, blinking lights fixed speed
	--vars needed: indicator duration, tick_interval, tick count, total_ticks, modulus_amount
	-- local current_tick = 0
	-- local total_flashes = 20
	-- local modulus_amount = total_ticks / total_flashes 
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	if current_tick % modulus_amount == 0 then
	-- 		DebugDrawCircle(location, Vector(255,0,0), 128, radius, true, tick_interval)		
	-- 	end
		
	-- return tick_interval
	-- end)

--------------
	-- Flash a fixed radius red circle, blinking lights at increasing speed 
	-- local current_tick = 0
	-- local modulus_amount = total_ticks / 5
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	if current_tick % modulus_amount == 0 then
	-- 		DebugDrawCircle(location, Vector(255,0,0), 128, radius, true, tick_interval *2)		
	-- 		modulus_amount = modulus_amount - 1
	-- 	end
		
	-- return tick_interval
	-- end)

--------------
	-- Grow a circle from small radius to full radius over indicator_duration
	-- local start_radius = 20
	-- local end_radius = radius --or less...
	-- local current_radius = start_radius
	-- local growth_amount = end_radius / total_ticks
	-- --local growth_amount = (end_radius / total_ticks) - start_radius
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	current_radius = current_radius + growth_amount

	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	DebugDrawCircle(location, Vector(255,0,0), 128, current_radius, true, tick_interval)		
		
	-- return tick_interval
	-- end)

--------------
	-- Show radius at increasing color intensity, increase/reduce opacity over duration
	-- local current_alpha = 0
	-- local growth_amount = 256 / total_ticks
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	current_alpha = current_alpha + growth_amount

	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	DebugDrawCircle(location, Vector(255,0,0), current_alpha, current_radius, true, tick_interval)		
		
	-- return tick_interval
	-- end)




function CallDownPattern()


end


function CallDownOnEnemies()
	--Particles to try:
	local particle1 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_sparks.vpcf"
	local particle2 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion.vpcf"
	local particle3 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_flash_c.vpcf"
	local particle4 = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_second.vpcf"
	local particle5 = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_flash_g.vpcf"

	--Get enemies: either enemies in area or through some other scan..
	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )


	-- TESTING PARTICLES:
 	if #enemies > 0 then
 		print("thisEntity = ", thisEntity:GetAbsOrigin())
 		print("enemies[1] = ", enemies[1]:GetAbsOrigin())

		local p1Index1 = ParticleManager:CreateParticle(particle4, PATTACH_CUSTOMORIGIN, thisEntity)
		ParticleManager:SetParticleControl(p1Index1, 0, enemies[1]:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex( p1Index1 )

		local p1Index2 = ParticleManager:CreateParticle(particle4, PATTACH_ABSORIGIN, thisEntity)
		 ParticleManager:SetParticleControl(p1Index2, 0, enemies[1]:GetAbsOrigin())
		 ParticleManager:ReleaseParticleIndex( p1Index2 )


		local p1Index3 = ParticleManager:CreateParticle(particle5, PATTACH_ABSORIGIN, enemies[1])
		 ParticleManager:SetParticleControl(p1Index3, 0, enemies[1]:GetAbsOrigin())
		 ParticleManager:ReleaseParticleIndex( p1Index3 )
		--local p1Index3 = ParticleManager:CreateParticle(particle1, PATTACH_ABSORIGIN_FOLLOW, enemies[0])
		--local p1Index4 = ParticleManager:CreateParticle(particle1, PATTACH_WORLDORIGIN, thisEntity)
		--ParticleManager:SetParticleControlEnt( nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false )
	end
	-- END TEST

	if #enemies > 0 then
		--Loop over enemies and cast calldown on each one
		for _,enemy in pairs(enemies) do
			-- DEBUG			
			--DebugDrawCircle(enemy:GetAbsOrigin(), Vector(255,0,0), 128, 250, true, 3) -- red = enemy:GetAbsOrigin() 		

			-- Cast call_down.lua ability
			-- NOTE: Couldn't get the position/target location within call_down.lua 
			-- thisEntity:SetCursorPosition(enemy:GetAbsOrigin())
			-- ExecuteOrderFromTable({
			-- 	UnitIndex = thisEntity:GetEntityIndex(),
			-- 	OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			-- 	AbilityIndex = thisEntity:FindAbilityByName( "call_down" ):entindex(),
			-- 	Position = shallowcopy(enemy:GetAbsOrigin()),
			-- })

			local indicator_duration = 3
			local tick_interval = 0.1
			local total_ticks = indicator_duration / tick_interval
			local current_tick = 0

			local radius = 600
			local current_alpha = 0
			local growth_amount = 5
			print("growth_amount =", growth_amount)


			--Call down ability: 
			--Start a timer, while counting up display indicator animation. After indicator_duration seconds, apply particle effects, dmg enemies in radius

			Timers:CreateTimer(function()	

			current_tick = current_tick +1
			current_alpha = current_alpha + growth_amount

			-- TODO: call down effect, particles effects and dmg to enemies in radius
			if current_tick >= total_ticks then
				DebugDrawCircle(enemy:GetAbsOrigin(), Vector(255,0,0), current_alpha, radius, true, tick_interval * 4) --remove this once particles are in
				--TODO: Particle effects here
				--TODO: Dmg enemie
				return	--stop the timer 
			end
			-- Display indicator warning players spell is coming
			if current_tick <= total_ticks then
				DebugDrawCircle(enemy:GetAbsOrigin(), Vector(255,0,0), current_alpha, radius, true, tick_interval)	
			end

		return tick_interval
		end)
		end

	end

end


function ApplyFlakCannonModifier()
	local ability = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity:AddNewModifier(thisEntity, ability, "flak_cannon_modifier", {duration = 10})

	AttackClosestPlayer()
	
end

function AttackClosestPlayer()
	print("AttackClosestPlayer!")
	-- find closet player
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )
	if #enemies == 0 then
		return 0.5
	end
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		TargetIndex = enemies[1]:entindex(),
		Queue = 0,
	})
	return 0.5
end



-----------------------------------------------------------------------------------------------
--Table/Set/List functions

-- Remove/Clear the whole set
function Clear(set)
	for k,v in pairs(set) do
		set[k] = nil
	end
end

-- Remove this key from the set
function Remove(set, key)
	set[key] = nil
end

-- Check if the set contains this key
function Contains(set, key)
    return set[key] ~= nil
end

--TODO: how does homingMissile get it's target?
	--Surely I determine that here and 
function CastHomingMissile(target)
	print("CastHomingMissile(target)")
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.homing_missile:entindex(),
		Queue = true,
	})
end

function CastFlakCannon()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.flak_cannon:entindex(),
		Queue = true,
	})
end

function CastRocketBarrage()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.rocket_barrage:entindex(),
		Queue = true,
	})
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end