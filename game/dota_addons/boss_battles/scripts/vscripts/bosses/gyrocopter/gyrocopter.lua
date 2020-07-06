gyrocopter = class({})

--Modifier examples:
LinkLuaModifier( "flak_cannon_modifier", "bosses/gyrocopter/flak_cannon_modifier", LUA_MODIFIER_MOTION_NONE )


	--Set modifier stacks:
	--bearWithBloodlust:SetModifierStackCount("bear_bloodlust_modifier", bearWithBloodlust, 0)

	--Has modifier: HasModifier("bear_bloodlust_modifier")

	--Add new modifier:
	-- self:GetCaster():AddNewModifier(
	-- self:GetCaster(), -- player source
	-- self, -- ability source
	-- "chain_modifier", -- modifier name
	-- {
	-- 	point_x = self.point.x,
	-- 	point_y = self.point.y,
	-- 	point_z = self.point.z,
	-- 	effect = ExtraData.effect,
	-- })


--Global used in; gyrocopter.lua, homing_missile.lua, ...
_G.ScannedEnemyLocations = {}


local currentPhase = 1
local COOLDOWN_RADARSCAN = 100
local COOLDOWN_FLAKCANNON = 10
local swooping = false
local swoopDuration = 0

local isHpBelow50Percent = false
local isHpBelow10Percent = false


--Gyro locoations
--gyroHideLocation1
--gyroHideLocation2


function Spawn( entityKeyValues )
	print("Gyrocopter Spawned!")
	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.rocket_barrage = thisEntity:FindAbilityByName( "rocket_barrage" )
	--TODO: if any of these are nil, we got a problem

	thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )
end

local COOLDOWN_RADARSCAN = 10
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


	--check current HP to trigger events
	local healthPercent = (thisEntity:GetMaxHealth() / thisEntity:GetHealth()) * 100
	print("healthPercent = ", healthPercent)
	--Trigger event at 50% hp
	if not isHpBelow50Percent && healthPercent < 50 then 
		isHpBelow50Percent = true
		--TODO: trigger event
		HalfHealthPhase()
	end
	--Trigger event at 10% hp
	if not isHpBelow10Percent && healthPercent < 10 then 
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
		print("FLAK CANNON!")
		ApplyFlakCannonModifier()
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
		thisEntity:MoveToPosition(targetLocation)

	end

	return 1 
end

--TODO: At half HP:
-- Fly gyro to fixed location
-- Initiate calldown ulti
-- Change costume/armor
-- Upgrade ability levels
function HalfHealthPhase()
 	print("HalfHealthPhase()")
end

function NearlyDeadPhase()
	print("NearlyDeadPhase()")
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
					
					--Do a call down at this location
					
				end
		end

		return frameDuration
	end) --end timer

end


-------------------------------------------------------------------------------
-- Call Down Abilities
-- Will be several different versions of how the call down targets are decided.

function CallDownPattern()


end


function CallDownOnEnemies()
	--TODO: Get all enemies in the arena.
	--Do a calldown on each one

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