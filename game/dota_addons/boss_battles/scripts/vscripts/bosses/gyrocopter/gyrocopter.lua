gyrocopter = class({})

local currentPhase = 1
local COOLDOWN_RADARSCAN = 5

--Global used in; gyrocopter.lua, homing_missile.lua, ...
_G.ScannedEnemyLocations = {}

function Spawn( entityKeyValues )
	print("Spawn called")

	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.rocket_barrage = thisEntity:FindAbilityByName( "rocket_barrage" )
	--TODO: if any of these are nil, we got a problem

	thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )

end

local tickCount = 0
function MainThinker()

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

	--COOLDOWNS, modulus the tickCount
	--if tickCount % COOLDOWN_RADARSCAN == 0 then --cast repeatedly
	if tickCount == 10 then --cast once
		print("calling NewRadarSweep()")
		--RadarSweep()	--radar sweep will scan for enemies, finding one it will shoot a homing rocket. 
		NewRadarSweep()
	end


	if _G.HOMING_MISSILE_HIT_TARGET ~= nil then
		local tempTarget = _G.HOMING_MISSILE_HIT_TARGET
		_G.HOMING_MISSILE_HIT_TARGET = nil
	end

	return 1 
end













-------------------------------------------------------------------------------
-- Radar Scan Abilities,
	-- Trying out different algos

-- Basically build up a list of targets through various methods
enemiesScanned = {}

function NewRadarSweep()
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
		--print("NewRadarSweep Timer tick")
		currentFrame = currentFrame +1
		if currentFrame >= totalFrames then
			print("NewRadarSweep Timer Finished. Returning")
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
					print("Enemy hit!")
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
					print("Casting homing missile")
					CastHomingMissile(enemy)
				end
			end

		end
		
		endAngle = endAngle - degreesPerFrame
		return frameDuration
	end) --end timer
end



-- TODO: make a new versionof this which only draws the line for 1 frame or whatever, then they all disapear and it draws the next set of frames... might be laggy?
function RadarSweep()
	--print("thisEntity:GetCaster():GetOrigin() = ", thisEntity:GetOrigin())
	local origin = thisEntity:GetAbsOrigin()

	local radius = 1800 
	local duration = 1 --seconds
	local tickDuration = 0.5 / 360 -- TK 
	local i = 1

	Timers:CreateTimer(function()
		origin = thisEntity:GetAbsOrigin()

		if i > 360 then
			Clear(enemiesScanned)
			return false
		end
		if i < -360 then
			Clear(enemiesScanned)
			return false
		end

		--draw n lines at once
		for j = 1, 3, 1 do
			--radians is needed not degrees
			local angle = i * 0.0174532925 
			local x = radius * math.cos(angle)
			local y = radius * math.sin(angle)
			DebugDrawLine(origin, Vector(x,y,0) + origin, 255,0,0, true, duration)

			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, origin, Vector(x,y,0) + origin, thisEntity, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
			for _,enemy in pairs(enemies) do
				if Contains(enemiesScanned, enemy) then
					-- already hit this enemy
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
			i = i-1
		end
		return tickDuration;
	end
	)

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