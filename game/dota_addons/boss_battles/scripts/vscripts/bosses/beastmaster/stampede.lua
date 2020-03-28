--require('libraries/timers')

stampede = class({})

-- new class design:

--GLOBAL VARS:

-- --TODO pick locations based on map
-- CHANNELING_LOC = Vector(0,0,0) --The location the hero teleports to before/while casting stampede 
-- STAMPEDE_START_LOC Vector(0,0,0) --The location the stampede units spawn at. Actually their spwan pos is calced from this, not exactly at this 
-- STAMPEDE_END_LOC Vector(0,0,0) --The location the stampede run toward. Actually the loc is calced from this, not exactly at this 

-- STAMPEDE_ORIENTATION = "HORIZ" --"HORIZ" or "VERT". The orientation the wave is spread along. HORIZ for waves going north/south, VERT for east/west


-- STAMPEDE_DURATION = 30 --seconds
-- WAVES_AMOUNT = 10 --
-- WAVE_INTERVAL = STAMPEDE_DURATION / WAVES_AMOUNT --seconds between waves
-- WAVE_SPACING = 150 -- The amount of distance between units in a stampede wave. 
-- UNITS_PER_WAVE = 10

-- START_SPAWN_LOCS = calculateSpawnLocations(STAMPEDE_START_LOC, STAMPEDE_ORIENTATION, WAVE_SPACING, UNITS_PER_WAVE)
-- END_SPAWN_LOCS = calculateSpawnLocations(STAMPEDE_END_LOC, STAMPEDE_ORIENTATION, WAVE_SPACING, UNITS_PER_WAVE)


-- --Given a <location>, returns an array of Vectors centered on that location, spaced and aligned along an orientation
-- function stampede:calculateSpawnLocations(loc, orientation, spacing, amount)
-- 	spawnLocs = {}

-- 	--perhaps 1 off? might need amount+1, TODO: test/verify
-- 	for i = 1, amount, 1 do

-- 		--algo: if loc is center point, if amount is odd, then middle unit will be on the loc, if amount is even, no unit will be at loc
-- 			-- when amount is odd then spawnLoc[(amount+1)/2] should be equal to loc
-- 			-- when amount is even, no unit will be on the loc, they'll be either side, spacing/2 away from it

-- 		local posInWave = i - (amount+1) /2	--The units position in the wave, negative is to the left/above, position is to the right/below.
-- 		if orientation == "HORIZ" then
-- 			local xLoc = (posInWave * spacing) + loc.x 
-- 			spawnLocs[i] = Vector(xLoc, loc.y, loc.z)
-- 		elseif orientation == "VERT" then
-- 			local yLoc = (posInWave * spacing) + loc.y
-- 			spawnLocs[i] = Vector(loc.x, yLoc, loc.z)
-- 		end
-- 	end
	
-- 	return spawnLocs;	
-- end


-- --Spawn funcs:

-- 	--spawnUnit(spawnLoc, moveToLoc, ?)
-- 		-- need to set a timer to check for collisions
-- 	--spawnWave(spawnLocs, moveToLocs, ?)

-- 	--Stampede loops and calls spawnWave every WAVE_INTERVAL
-- 	--Spawn wave loops #spawnLocs and calls spawnUnit each time.

-- --Other funcs:
-- 	--OnCollision(stampUnit, unitHit)
-- 		--do dmg to unitHit, apply mod
-- 		-- destroy stampUnit


-- --Stampede onSpellStart, triggers a stampede which lasts for STAMPEDE_DURATION seconds
-- --Algo: 
-- --Hero teleports to CHANNELING_LOC
-- --Sound event and animation. 
-- 	--TODO: pick sound and animation for channeling

-- --Calc spawn locations etc and load them into a table so they can be iterated

-- --Loop: 
-- 	--Spawn a wave, each unit at x[i] and move to y[i]
-- 	--Start a timer for each unit to check collision
-- 		--On collision... dmg? explode unit, debuff for stacking dmg
-- 			--E.g first hit does 20% hp, next 30% hp, 40% etc. 






summonLocs = {}

MOVE_INTERVAL = 0.5 --interval in seconds
WAVE_INTERVAL = 5
DEBUG_DRAW_DURATION = 1;
DEBUG_DRAW_RAD = 50;

projectile_name = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf"
--projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

spawnedWaves = {}
waveIncrement = 1

function stampede:OnSpellStart()
	local caster = self:GetCaster()
    local cursorLoc = self:GetCursorPosition()
    local casterLoc = caster:GetOrigin()

	--Spawn to South, then head North.
	local offset = 800
	local spawnDistance = 800
	local spacing = 400
	local max = 10

	--Spawn to south, in horizontal line:
	southRow = {}
	for i = 1, max, 1 do
		local x = casterLoc.x 
		southRow[i] = Vector(casterLoc.x + (i * spacing) - ( ( spacing * max ) / 2), casterLoc.y - spawnDistance,0)
	end

	northRow = {}
	for i = 1, max, 1 do
		local x = casterLoc.x 
		northRow[i] = Vector(casterLoc.x + (i * spacing) - ( ( spacing * max ) / 2), casterLoc.y + spawnDistance,0)
	end	


	--TODO: now spawn that wave multiple times
	--TODO: test once? 
	--self:spawnStampedeAndMoveTo(southRow, northRow)

	local interval = 1.5 --seconds between waves
	local count = 1 --current wave
	local waves = 15 -- max waves


     Timers:CreateTimer(function()
 		if (count <= waves) then 
 			print("Spawning a new wave")
			self:spawnStampedeAndMoveTo(southRow, northRow)
			count = count + 1
		else 
			print("Fininshed all waves, returning 999")
			return 999
			
 		end
     	return interval
      end
	  )





	--TODO: test in a timer looping.

	-- print("Debugging: ")
	-- for i=1, max, 1 do
	-- 	print("southRow[i]:", southRow[i])
	-- 	print("northRow[i]:", northRow[i])
	-- end


	-- stampedeUnits = {}
	-- for i = 1, #southRow, 1 do
	-- 		local stampedeUnit = CreateUnitByName( "npc_dota_neutral_centaur_outrunner", southRow[i], true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
	-- 		stampedeUnits[i] = stampedeUnit

	-- 	--Move to the position
	-- 	print("before move command issued")
	-- 	  Timers:CreateTimer({
	-- 	    endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	-- 	    callback = function()
	-- 	    --queue up move commands
	-- 	    print("Move commands issued")
	-- 		ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = northRow[i], Queue = true})
	-- 		ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = southRow[i], Queue = true})
	-- 	    end
	-- 	  })			

	-- 	--Check whether the unit has collided with anything
	--      Timers:CreateTimer(function()
	--      	local count = 1
	--      	return self:collisionCheck(stampedeUnits[i], count)
	--       end
	-- 	  )

	-- end

end

function stampede:spawnStampedeAndMoveTo(spawnLoc, moveLoc)
	stampedeUnits = {}
	for i = 1, #spawnLoc, 1 do
			local stampedeUnit = CreateUnitByName( "npc_stampede_unit", spawnLoc[i], true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
			stampedeUnits[i] = stampedeUnit

		--Move to the position
		  Timers:CreateTimer({
		    endTime = 0.2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		    callback = function()
		    --queue up move commands
	    	print("insider move timer")
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


function stampede:createStampedeUnitsAtLocations(locations)
	stampedeUnits = {}
	for i = 1, #locations, 1 do
		--Create units for the stampede
		local stampedeUnit = CreateUnitByName( "npc_stampede_unit", locations[i], true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
		stampedeUnits[i] = stampedeUnit

		print("createStampedeUnitsAtLocations, created units")

		--Move to the first position, then the next. 
		  Timers:CreateTimer({
		    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		    callback = function()
		    --queue up move commands

		    print("createStampedeUnitsAtLocations, inside timer, execut")
			ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = Vector(locations[i].x, locations[i].y - 1000, locations[i].z), Queue = true})
			ExecuteOrderFromTable({ UnitIndex = stampedeUnit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = Vector(locations[i].x, locations[i].y, locations[i].z), Queue = true})
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


function stampede:collisionCheck(unit,count)
	if count == 200 then
		print("collisionCheck reached count")
		return
	end
	count = count + 1 

	local collisionRadius = 100
	direUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
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

	   UTIL_Remove(collidedUnit)

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


--     Timers:CreateTimer(function()
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