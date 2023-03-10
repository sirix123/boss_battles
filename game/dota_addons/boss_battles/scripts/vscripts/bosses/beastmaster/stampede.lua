--require('libraries/timers')
stampede = class({})

--GLOBAL VARS:
-- --TODO pick locations based on map
-- CHANNELING_LOC = Vector(0,0,0) --The location the hero teleports to before/while casting stampede 
-- STAMPEDE_START_LOC Vector(0,0,0) --The location the stampede units spawn at. Actually their spwan pos is calced from this, not exactly at this 
-- STAMPEDE_END_LOC Vector(0,0,0) --The location the stampede run toward. Actually the loc is calced from this, not exactly at this 

STAMPEDE_ORIENTATION = "HORIZ" --"HORIZ" or "VERT". The orientation the wave is spread along. HORIZ for waves going north/south, VERT for east/west
STAMPEDE_DURATION = 30 --seconds
WAVES_AMOUNT = 2 --
WAVE_INTERVAL = STAMPEDE_DURATION / WAVES_AMOUNT --seconds between waves
UNIT_SPACING = 300 -- The amount of distance between units in a stampede wave. 
UNITS_PER_WAVE = 10

-- START_SPAWN_LOCS = calculateSpawnLocations(STAMPEDE_START_LOC, STAMPEDE_ORIENTATION, UNIT_SPACING, UNITS_PER_WAVE)
-- END_SPAWN_LOCS = calculateSpawnLocations(STAMPEDE_END_LOC, STAMPEDE_ORIENTATION, UNIT_SPACING, UNITS_PER_WAVE)

function stampede:OnSpellStart()
	print("\t stampede OnSpellStart()")
	--TODO: teleport hero to location
	--TODO: sound event and animation
	--TODO invul hero

	--Spawn the stampede units 1000px to the south of the caster
	origin = self:GetCaster():GetOrigin() + Vector(0,-1000,0)

	--TODO: add comments to explain this...
	local start1 = self:calculateSpawnLocations(origin, STAMPEDE_ORIENTATION, UNIT_SPACING, UNITS_PER_WAVE)
	local start2 = self:calculateSpawnLocations(origin + Vector(UNIT_SPACING/2,0,0), STAMPEDE_ORIENTATION, UNIT_SPACING, UNITS_PER_WAVE)
	local end1 = self:calculateSpawnLocations(origin + Vector(0,2000,0), STAMPEDE_ORIENTATION, UNIT_SPACING, UNITS_PER_WAVE)
	local end2 = self:calculateSpawnLocations(origin + Vector(UNIT_SPACING/2,2000,0), STAMPEDE_ORIENTATION, UNIT_SPACING, UNITS_PER_WAVE)

	--Start stampede:
	count = 1
	Timers:CreateTimer(function()
		--alternate between waves so they are staggered
		if count % 2 == 0 then
			self:spawnWave(start1, end1, UNITS_PER_WAVE)
		else
			self:spawnWave(start2, end2, UNITS_PER_WAVE)
		end
		count = count + 1
		return WAVE_INTERVAL
	end
	)
end


 --Given a location, returns an array of Vectors centered on that location, spaced and aligned along an orientation
 function stampede:calculateSpawnLocations(loc, orientation, spacing, amount)
 	print("calculateSpawnLocations")
	spawnLocs = {}
	--perhaps 1 off? might need amount+1, TODO: test/verify
	for i = 1, amount, 1 do

		--algo: if loc is center point, if amount is odd, then middle unit will be on the loc, if amount is even, no unit will be at loc
			-- when amount is odd then spawnLoc[(amount+1)/2] should be equal to loc
			-- when amount is even, no unit will be on the loc, they'll be either side, spacing/2 away from it
		local posInWave = i - (amount+1) /2	--The units position in the wave, negative is to the left/above, position is to the right/below.
		if orientation == "HORIZ" then
			local xLoc = (posInWave * spacing) + loc.x 
			spawnLocs[i] = Vector(xLoc, loc.y, loc.z)
		elseif orientation == "VERT" then
			local yLoc = (posInWave * spacing) + loc.y
			spawnLocs[i] = Vector(loc.x, yLoc, loc.z)
		end
	end
	
	return spawnLocs;	
end


-- Spawns a stampede unit at spawnLoc and moves the unit to moveToLoc
function stampede:spawnUnit(spawnLoc, moveToLoc)
	--spawn unit
	local stampedeUnit = CreateUnitByName( "npc_stampede_unit", spawnLoc, true, self:GetCaster(), self:GetCaster(), DOTA_TEAM_BADGUYS )

	--Move to the position
	Timers:CreateTimer({
		endTime = 0.2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
		ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = moveToLoc, Queue = true})
		--try to attach an animation
		local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_tree_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, stampedeUnit )
	end
	})

	local tickCount = 1
	--collision check
	Timers:CreateTimer(function()
		tickCount = tickCount +1

		return self:checkAndHandleCollision(stampedeUnit, tickCount)
	end
	)

	--TODO: make a func to check if units pos is near the endPos. If at end pos then remove unit		
	 Timers:CreateTimer(function()
		return self:checkAndHandleUnitAtEnd(stampedeUnit, moveToLoc, 50)
	 end
	 )
end



--spawns a row/col of stampede units. 
function stampede:spawnWave(spawnLocs, moveToLocs, unitsPerWave)
	for i =1, unitsPerWave, 1 do
		self:spawnUnit(spawnLocs[i], moveToLocs[i])
	end
end

function stampede:checkAndHandleCollision(unit,count)
	print("checking for collision. Count = ", count)
	--TODO: need a better way to determine when to stop this timer...
	if count == 50 then
		print("count threshold reached. Despawning unit")
		print("Stopping timer")
		UTIL_Remove(unit)
		return
	end

	local collisionRadius = 100
	units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                              unit:GetOrigin(),
                              nil,
                              collisionRadius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

	-- Make the found units move to (0, 0, 0)
	for _,collidedUnit in pairs(units) do
   		print("collision detected")
	    local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_ABSORIGIN, unit )
	   --TODO: deal dmg to collidedUnit
	end
	return 0.1	--
end

-- Check if the stampedeUnit is at or near enough (nearnessThreshold) to moveToLoc. Once there despawn the unit
function stampede:checkAndHandleUnitAtEnd(stampedeUnit, moveToLoc, nearnessThreshold)
	if stampedeUnit == nil then
		print("StampedeUnit is nil. Stopping timer")
		return
	end

	if stampedeUnit ~= nill then
		local dist =  getDistance(stampedeUnit:GetOrigin(), moveToLoc)
			if dist < nearnessThreshold then
				UTIL_Remove(stampedeUnit)
				return
			end
			return 0.3
	end

	print("checkAndHandleUnitAtEnd, stampede unit is nil")
	return 
	

end

function getDistance(objA, objB)
    -- Get the length for each of the components x and y
    local xDist = objB.x - objA.x
    local yDist = objB.y - objA.y

    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) ) 
end



------------------------------------------------------------------------
-----------------------------OLD CODE:----------------------------------


-- summonLocs = {}

-- MOVE_INTERVAL = 0.5 --interval in seconds
-- WAVE_INTERVAL = 5
-- DEBUG_DRAW_DURATION = 1;
-- DEBUG_DRAW_RAD = 50;

-- projectile_name = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf"
-- --projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

-- spawnedWaves = {}
-- waveIncrement = 1

-- function stampede:OnSpellStart()
-- 	local caster = self:GetCaster()
--     local cursorLoc = self:GetCursorPosition()
--     local casterLoc = caster:GetOrigin()

-- 	--Spawn to South, then head North.
-- 	local offset = 800
-- 	local spawnDistance = 800
-- 	local spacing = 400
-- 	local max = 10

-- 	--Spawn to south, in horizontal line:
-- 	southRow = {}
-- 	for i = 1, max, 1 do
-- 		local x = casterLoc.x 
-- 		southRow[i] = Vector(casterLoc.x + (i * spacing) - ( ( spacing * max ) / 2), casterLoc.y - spawnDistance,0)
-- 	end

-- 	northRow = {}
-- 	for i = 1, max, 1 do
-- 		local x = casterLoc.x 
-- 		northRow[i] = Vector(casterLoc.x + (i * spacing) - ( ( spacing * max ) / 2), casterLoc.y + spawnDistance,0)
-- 	end	


-- 	--TODO: now spawn that wave multiple times
-- 	--TODO: test once? 
-- 	--self:spawnStampedeAndMoveTo(southRow, northRow)

-- 	local interval = 1.5 --seconds between waves
-- 	local count = 1 --current wave
-- 	local waves = 15 -- max waves


--      Timers:CreateTimer(function()
--  		if (count <= waves) then 
--  			print("Spawning a new wave")
-- 			self:spawnStampedeAndMoveTo(southRow, northRow)
-- 			count = count + 1
-- 		else 
-- 			print("Fininshed all waves, returning 999")
-- 			return 999
			
--  		end
--      	return interval
--       end
-- 	  )



-- 	--TODO: test in a timer looping.

-- 	-- print("Debugging: ")
-- 	-- for i=1, max, 1 do
-- 	-- 	print("southRow[i]:", southRow[i])
-- 	-- 	print("northRow[i]:", northRow[i])
-- 	-- end


-- 	-- stampedeUnits = {}
-- 	-- for i = 1, #southRow, 1 do
-- 	-- 		local stampedeUnit = CreateUnitByName( "npc_dota_neutral_centaur_outrunner", southRow[i], true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
-- 	-- 		stampedeUnits[i] = stampedeUnit

-- 	-- 	--Move to the position
-- 	-- 	print("before move command issued")
-- 	-- 	  Timers:CreateTimer({
-- 	-- 	    endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
-- 	-- 	    callback = function()
-- 	-- 	    --queue up move commands
-- 	-- 	    print("Move commands issued")
-- 	-- 		ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = northRow[i], Queue = true})
-- 	-- 		ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = southRow[i], Queue = true})
-- 	-- 	    end
-- 	-- 	  })			

-- 	-- 	--Check whether the unit has collided with anything
-- 	--      Timers:CreateTimer(function()
-- 	--      	local count = 1
-- 	--      	return self:collisionCheck(stampedeUnits[i], count)
-- 	--       end
-- 	-- 	  )

-- 	-- end

-- end

function stampede:spawnStampedeAndMoveTo(spawnLoc, moveLoc)
	stampedeUnits = {}

	for i = 1, #spawnLoc, 1 do
			--summonBear: local hBear = CreateUnitByName("npc_beastmaster_bear", vSpawnArea, true, nil, nil, DOTA_TEAM_BADGUYS)
			--summonBoar:                 local hQuillboar = CreateUnitByName("npc_quilboar", vSpawnArea, true, self:GetCaster(), self:GetCaster(), DOTA_TEAM_BADGUYS)
			local stampedeUnit = CreateUnitByName( "npc_stampede_unit", spawnLoc[i], true, self:GetCaster(), self:GetCaster(), DOTA_TEAM_BADGUYS )
			stampedeUnits[i] = stampedeUnit

			--print("Attempted to create npc_stampede_unit")
			--print(stampedeUnit)


		--Move to the position
		  Timers:CreateTimer({
		    endTime = 0.2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		    callback = function()
		    --queue up move commands
	    	--print("insider move timer")
			ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = moveLoc[i], Queue = true})
			--ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = moveLoc[i], Queue = true})

			--particle: 
			--particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_tree_c.vpcf


		    local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_tree_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    		
    		--Not sure what these two lines will do:
    		--ParticleManager:SetParticleControl(p, 0, spawnLoc[i])
    		--ParticleManager:ReleaseParticleIndex(p)
		    end
		  })			

		
		--Check whether the unit has collided with anything
	     Timers:CreateTimer(function()
	    	local count = 1 	
	     	return self:collisionCheck(stampedeUnits[i], count)
	      end
		  )

	end



end


-- function stampede:createStampedeUnitsAtLocations(locations)
-- 	stampedeUnits = {}
-- 	for i = 1, #locations, 1 do
-- 		--Create units for the stampede
-- 		local stampedeUnit = CreateUnitByName( "npc_stampede_unit", locations[i], true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
-- 		stampedeUnits[i] = stampedeUnit

-- 		print("createStampedeUnitsAtLocations, created units")

-- 		--Move to the first position, then the next. 
-- 		  Timers:CreateTimer({
-- 		    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
-- 		    callback = function()
-- 		    --queue up move commands

-- 		    print("createStampedeUnitsAtLocations, inside timer, execut")
-- 			ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = Vector(locations[i].x, locations[i].y - 1000, locations[i].z), Queue = true})
-- 			ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = Vector(locations[i].x, locations[i].y, locations[i].z), Queue = true})
-- 		    end
-- 		  })

-- 		  --Check whether the unit has collided with anything
-- 	     Timers:CreateTimer(function()
-- 	     	local count = 1
-- 	     	return self:collisionCheck(stampedeUnits[i], count)
-- 	      end
-- 		  )

-- 	end

-- end


function stampede:collisionCheck(unit,count)
	if unit == nil then
		print("collisionCheck() unit is nil")
		return
	end

	if count == 200 then
		print("collisionCheck reached count")
		return
	end
	count = count + 1 

	local collisionRadius = 100
	direUnits = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                              unit:GetOrigin(),
                              nil,
                              collisionRadius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

	-- Make the found units move to (0, 0, 0)
	for _,collidedUnit in pairs(direUnits) do
	   --unit:MoveToPosition(Vector(0, 0, 0))
	    local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_ABSORIGIN, unit )
		 --ParticleManager:SetParticleControl( p, 4, target:GetOrigin() )
		-- ParticleManager:ReleaseParticleIndex( p )

	   --TODO: deal dmg to goodguy

	   --UTIL_Remove(collidedUnit)

	end


	return 0.1


end

--plan:
--Make one timer which triggers a new wave, every maybe 3-5 seconds
--Then another timer which 'unit'/circle/projectile along it's line

-- function stampede:spawnWaves(direction, waves, color)
-- 	print("spawnWaves main timer tick ")
--     Timers:CreateTimer(function()
--     	print("spawnWaves internal timer tick ")
--     	return self:moveWave(direction, waves[waveIncrement], color)
--      end
-- 	 )


--     waveIncrement = waveIncrement +1
--     return WAVE_INTERVAL
-- end

-- function stampede:spawnWave(direction, summonLocs, color)
-- 	print("spawnWave main timer tick")


-- 	--TODO: make a copy of the table before sending it in. 
-- 	dupe = shallowcopy(summonLocs)

-- 	spawnedWaves[#spawnedWaves] = dupe --store a ref to this so it doesnt get garbage collected 
-- 	--NO IDEA IF THAT WORKS!


--     Timers:CreateTimer(function()7
--     	print("spawnWave internal timer tick")
--     	return self:moveWave(direction, dupe, color)
--      end
-- 	 )
	

-- 	return WAVE_INTERVAL
-- end


    
-- function stampede:timerTick()
-- 	--TODO: move each thing a little on the y?
-- 	for i = 1, #summonLocs, 1 do
-- 		summonLocs[i] = summonLocs[i] + Vector(0, 20,0)
-- 		--Debug:
-- 		DebugDrawCircle(summonLocs[i], Vector(0,255,0),128,DEBUG_DRAW_RAD,true,DEBUG_DRAW_DURATION)
-- 	end

-- 	return MOVE_INTERVAL

-- end



-- function stampede:moveWave(direction, summonLocs, color)
-- 	--direction = "N","E","S","W" or something else...
-- 	distance = 20
-- 	if (direction == "N") then
-- 			for i = 1, #summonLocs, 1 do
-- 				summonLocs[i] = summonLocs[i] + Vector(0, distance,0)	-- + on the y coord to go north
-- 				--Debug:
-- 				DebugDrawCircle(summonLocs[i], color,128,DEBUG_DRAW_RAD,true,DEBUG_DRAW_DURATION)
-- 			end
-- 	end
-- 	if (direction == "E") then
-- 			for i = 1, #summonLocs, 1 do
-- 				summonLocs[i] = summonLocs[i] + Vector(distance, 0,0)	-- + on the x coord to go east
-- 				--Debug:
-- 				DebugDrawCircle(summonLocs[i], color,128,DEBUG_DRAW_RAD,true,DEBUG_DRAW_DURATION)
-- 			end
-- 	end
-- 	if (direction == "S") then
-- 			for i = 1, #summonLocs, 1 do
-- 				summonLocs[i] = summonLocs[i] - Vector(0, distance,0)	-- - on the y coord to go south
-- 				--Debug:
-- 				DebugDrawCircle(summonLocs[i], color,128,DEBUG_DRAW_RAD,true,DEBUG_DRAW_DURATION)
-- 			end
-- 	end
-- 	if (direction == "W") then
-- 			for i = 1, #summonLocs, 1 do
-- 				summonLocs[i] = summonLocs[i] - Vector(distance, 0,0)	-- - on the x coord to go west
-- 				--Debug:
-- 				DebugDrawCircle(summonLocs[i], color,128,DEBUG_DRAW_RAD,true,DEBUG_DRAW_DURATION)
-- 			end
-- 	end

-- 	--TODO: other directions;
-- 		--Circle, waypoint, ...

-- 	return MOVE_INTERVAL
-- end


--UTILS:

--TODO put this in utils file
function copyTable(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copyTable(k, s)] = copyTable(v, s) end
  return res
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