gyrocopter = class({})

LinkLuaModifier( "flak_cannon_modifier", "bosses/gyrocopter/flak_cannon_modifier", LUA_MODIFIER_MOTION_NONE )

--Global used in; gyrocopter.lua, homing_missile.lua, ...
_G.ScannedEnemyLocations = {}



local COOLDOWN_RADARSCAN = 30
local COOLDOWN_RADARPULSE = 13

local COOLDOWN_FLAKCANNON = 100
local CAST_CALLDOWN = false

local isHpBelow50Percent = false
local isHpBelow10Percent = false

--Gyro locoations
local startLoc = Vector(13850,12272,256) 
local gyroHideLocation1 = Vector(11697,12272,640)
local gyroHideLocation2 = Vector(15823,12264,640)


-- On Spawn, init any vars, start MainThinker
function Spawn( entityKeyValues )
	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.rocket_barrage = thisEntity:FindAbilityByName( "rocket_barrage" )
	thisEntity.call_down = thisEntity:FindAbilityByName( "call_down" )
	--TODO: if any of these are nil, we got a problem
	thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )
end

--TESTING:
function CurrentTestCode()
	--Okay, lets do a swoop test?
	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 1400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	--test a swoop onto player...
	SwoopAbility(enemies[1])
end

local tickCount = 0
function MainThinker()
	--Enemies scanned, missiles should be chasing em.
	tickCount = tickCount + 1
	--print("MainThinker tick: ",tickCount)

	--TESTING:
	if (tickCount == 10) then
		--CurrentTestCode()
	end

	-- Almost all code should not run when the game is paused. Keep this near the top so we return early.
	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--on first tick: Move to starting location
	if tickCount == 1 then
		MoveToPosition(startLoc, 2000)
	end

	--CALL DOWN:
	if CAST_CALLDOWN then
		CallDownPattern()
		CAST_CALLDOWN = false

		-- Start a swoop across the screen... 
		thisEntity:SetBaseMoveSpeed(600)
		thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
		thisEntity:MoveToPosition(gyroHideLocation2)
	end

	--check current HP to trigger events
	local healthPercent = (thisEntity:GetHealth() / thisEntity:GetMaxHealth()) * 100
	
	--Trigger event at 50% hp
	if not isHpBelow50Percent and healthPercent < 50 then 
		isHpBelow50Percent = true
		CallDownPatternPhase()
	end
	--Trigger event at 10% hp
	if not isHpBelow10Percent and healthPercent < 10 then 
		isHpBelow10Percent = true
		--TODO: trigger event
		NearlyDeadPhase()
	end

	--ABILITY COOLDOWNS, modulus the tickCount

	--RADAR, reatedly alternate between RadarPulse and RadarScan every COOLDOWN_RADARSCAN / 2 seconds
	--TODO: implement bool to allow for interupts of this.
	if tickCount % COOLDOWN_RADARPULSE == 0 then --cast repeatedly
		RadarPulse()
	end

	if tickCount % COOLDOWN_RADARSCAN == 0 then --cast repeatedly
		RadarScan()
	end 

	-- If/when a missile hit's a target do this action:
	if _G.HOMING_MISSILE_HIT_TARGET ~= nil then
		local targetLocation = _G.HOMING_MISSILE_HIT_TARGET
		_G.HOMING_MISSILE_HIT_TARGET = nil
	end

	return 1 
end


-- ABILITIES: 
-----------------------------------------------------------------------------------


function FlyUp(height, velocity)
	local tick_interval = 0.05
	print("FlyUp before timer")
	Timers:CreateTimer(function()
		-- check if we've reached the height, Fly gyro up on the z axis.
		if thisEntity:GetAbsOrigin().z < height then
			thisEntity:SetAbsOrigin(Vector(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y, thisEntity:GetAbsOrigin().z +velocity))
			return tick_interval
		end	
		return --else return
	end)
	print("FlyUp after timer")

	--Calc how long it will take to fly up. return that
	local diff = height - thisEntity:GetAbsOrigin().z
	local stepsToReachHeight = diff / velocity
	local timeToReachHeight = stepsToReachHeight * tick_interval

	return timeToReachHeight
end

function FlyDown(height, velocity)
	local tick_interval = 0.05
	print("FlyUp before timer")
	Timers:CreateTimer(function()
		-- check if we've reached the height, Fly gyro up on the z axis.
		if thisEntity:GetAbsOrigin().z > height then
			thisEntity:SetAbsOrigin(Vector(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y, thisEntity:GetAbsOrigin().z -velocity))
			return tick_interval
		end	
		return --else return
	end)
	print("FlyUp after timer")

	--Calc how long it will take to fly up. return that
	local diff = height - thisEntity:GetAbsOrigin().z
	local stepsToReachHeight = diff / velocity
	local timeToReachHeight = stepsToReachHeight * tick_interval

	return timeToReachHeight
end



--Assumes gyro is in the air
--Swoop: swoops down onto target, activating rocket barrage upon arrival.
function SwoopAbility(target)


	DebugDrawCircle(target:GetAbsOrigin(), Vector(0,0,255), 128, 100, true, 5) -- blue circle
	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.	

	local velocity = 40
	local distanceThreshold = 150
	-- --Use a timer to fly gyro up into the air, after delay tick
	local delaySeconds = 0
	local tickCount = 0
	local tick_interval = 0.05
	Timers:CreateTimer(function()
		-- Fly gyro up on the z axis.
		if ( (tickCount * tick_interval) < delaySeconds) then
			--CHANGED: assume gyro is already in the air
			--thisEntity:SetAbsOrigin(Vector(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y, thisEntity:GetAbsOrigin().z +velocity/4))
		else
			--Check if gyro has arrived at destination then cast rocket_barrage and stop this timer
			local distance = (target:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()
			if (distance < distanceThreshold) then
				CastRocketBarrage()
				thisEntity:SetAttackCapability(2) 
				return
			end
			--Otherwise move gyro closer to destination
			local direction = (target:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Normalized()
			local moveAmount = direction * velocity
			thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + moveAmount)
		 end
		 tickCount = tickCount +1
		 return tick_interval
	end)
end


-- Fly gyro to location, once there set flag CAST_CALLDOWN to trigger cast down
function CallDownPatternPhase()
 	--TODO: move to gyroHideLocation1
 	thisEntity:SetAttackCapability(0) --set to DOTA_UNIT_CAP_NO_ATTACK.
 	thisEntity:SetBaseMoveSpeed(900)
 	thisEntity:MoveToPosition(gyroHideLocation1)

 	--Cast rocket_barrage?
 	CastRocketBarrage()

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



--TODO: write comment to explain what this is and how this works
enemiesScanned = {}

local shouldFlyUp = true
function RadarScan()

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
		--First fly up, then start scan...
		if shouldFlyUp then
			print("vshouldFlyUp. Flying up!")
			shouldFlyUp = false
			local flyUpDuration = FlyUp(600, 4)
			print("flyUpDuration = ", flyUpDuration)
			return flyUpDuration
		end

		local origin = thisEntity:GetAbsOrigin()
		currentFrame = currentFrame +1

		--Scan finished: Either, Swoop & Rocket barrage OR FlakCannon based on number of enemies scanned.
		if currentFrame >= totalFrames then

			if #_G.ScannedEnemyLocations == 1 then
				print("Only 1 enemy scanned. Should do rocket barrage")
				SwoopAbility(_G.ScannedEnemyLocations[1].Enemy)				
			end				

			if #_G.ScannedEnemyLocations > 1 then
				print("More than 1 enemy scanned. Should do flak cannon")
				ApplyFlakCannonModifier()
			end

			_G.ScannedEnemyLocations = {}
			Clear(enemiesScanned)
			return
		end	

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

				end
			end
		end
		
		endAngle = endAngle - degreesPerFrame
		return frameDuration
	end) --end timer



end


--TODO: write comment to explain what this is and how this works

_G.PulsedEnemyLocations = {}
function RadarPulse()
	local radius = 200
	local endRadius = 2000
	local radiusGrowthRate = 50

	--reset _G.PulsedEnemyLocations ?
	enemiesPulsed = {}
	--_G.PulsedEnemyLocations = {}

	local frameDuration = 0.1
	local currentAlpha = 10
	Timers:CreateTimer(function()	
		currentAlpha = currentAlpha + 1
		--update model
		local origin = thisEntity:GetAbsOrigin()
		if radius < endRadius then
			radius = radius + radiusGrowthRate
		else
			return
		end
		
		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), currentAlpha, radius, true, frameDuration)		
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
				if _G.PulsedEnemyLocations ~= nil then
					if #_G.PulsedEnemyLocations > 0 then 
						for i = 1, #_G.PulsedEnemyLocations, 1 do
							-- already scanned this enemy, update their location
							if enemy == _G.PulsedEnemyLocations[i].Enemy then
								_G.PulsedEnemyLocations[i].Location = shallowcopy(enemy:GetAbsOrigin())
								isNewEnemy = false
							end
						end
					end
				end
				-- first time scanning this enemy, add a new entry for them
				if isNewEnemy then
					_G.PulsedEnemyLocations[#_G.PulsedEnemyLocations +1] = scannedEnemy	
				end

				--Shoot a homing missile at this target:
				CastHomingMissile(enemy)
			end
		end

		return frameDuration
	end) --end timer

end


--TODO: write comment to explain what this is and how this works
--TODO: implement a call down spell which targets fixed locations on the ground
-- I want 2 rows of call downs, each row roughly taking a third of the arena, forcing players into the remaining third.
	-- gyro will then fly along this open path with FLAK CANNON
function CallDownPattern()
	local origin = thisEntity:GetAbsOrigin()
	local origin_z0 = Vector(origin.x,origin.y, 256)

	local topRowOrigin = origin_z0 + Vector(0,800,0)
	local botRowOrigin = origin_z0 + Vector(0,-800,0)
	local topRowCallDownLocs = {}
	local botRowCallDownLocs = {}

	local amount = 10
	local distanceBetween = 800

	for i = 1, amount, 1 do 
		topRowCallDownLocs[i] = topRowOrigin + Vector(distanceBetween*i,0,0)
		botRowCallDownLocs[i] = botRowOrigin + Vector(distanceBetween*i,0,0)

		CastCallDownAt(topRowCallDownLocs[i])
		CastCallDownAt(botRowCallDownLocs[i])
	end
end

--TODO: write comment to explain what this is and how this works
function CallDownOnEnemies()
	--Get enemies: either enemies in area or through some other scan..
	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	print("#enemies = ",  #enemies)

	--CAST CALLDOWN ON EACH ENEMY 
	if #enemies > 0 then
		--Loop over enemies and cast calldown on each one
		for _,enemy in pairs(enemies) do
			-- Cast call_down.lua ability
			-- NOTE: Couldn't get the position/target location within call_down.lua 
			-- thisEntity:SetCursorPosition(enemy:GetAbsOrigin())
			-- ExecuteOrderFromTable({
			-- 	UnitIndex = thisEntity:GetEntityIndex(),
			-- 	OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			-- 	AbilityIndex = thisEntity:FindAbilityByName( "call_down" ):entindex(),
			-- 	Position = shallowcopy(enemy:GetAbsOrigin()),
			-- })

			--Instead of using call_down.lua i've implemented the spell here:
			CastCallDownAt(enemy:GetAbsOrigin())
		end
	end

end


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

	--sounds: TODO
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

			local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, location, nil, current_radius,  DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
			for _,enemy in pairs(enemies) do
				local damageInfo = 
				{
					victim = enemy, attacker = thisEntity,
					damage = 5000, --TODO: calc this / get from somewhere
					damage_type = 4, -- TODO: get this from ability file ... 4 = DAMAGE_TYPE_PURE 
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


function ApplyFlakCannonModifier()
	local ability = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity:AddNewModifier(thisEntity, ability, "flak_cannon_modifier", {duration = 10})
	--AttackClosestPlayer()
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

--Moves thisEntity to position.
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

--TODO: how does homingMissile get it's target?
	--Surely I determine that here and 
function CastHomingMissile(target)
	print("CastHomingMissile(target)")
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.homing_missile:entindex(),
		Queue = false,
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
	thisEntity.rocket_barrage.test = 123;

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.rocket_barrage:entindex(),
		Queue = false,
	})
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