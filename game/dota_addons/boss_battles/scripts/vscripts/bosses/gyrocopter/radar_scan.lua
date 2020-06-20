-- radar_scan = class({})
-- LinkLuaModifier( "radar_scan_modifier", "bosses/gyrocopter/radar_scan_modifier", LUA_MODIFIER_MOTION_NONE )

-- local radScan_radius = 1200 --todo: put this in the ability txt file

-- function radar_scan:OnSpellStart()
-- 	print("radar_scan:OnSpellStart()")
-- 	local origin = self:GetCaster():GetOrigin()

-- 	--Lvl 1 of spell: 80% WIP
-- 	self:NewDebugRadarScanSweep()

-- 	--Lvl 2 of spell: 50% WIP
-- 		--TODO: utilise "enemiesScanned"
-- 	--self:DebugRadarScanPulse(origin)
-- end



-- --NEED TO KNOW:
-- -- Total frames
-- -- Current frame

-- -- Current hero location
-- -- Circle radius, angle, 

-- --vars used to persist across NewDebugRadarScanSweep function calls
-- local currentFrame = 1
-- local totalframes = 120

-- enemiesScanned = {}
-- function radar_scan:NewDebugRadarScanSweep()
-- 	local origin = self:GetCaster():GetOrigin()

-- 	--TODO: Make a new smoother radar scan sweep.
-- 	--I had an idea but I can't remember it now...
-- 	--I think go through a timer and draw the next 5-10 lines each tick
-- 	--Because the timer can't run fast enough increase the amount of lines per tick until it looks smoother
-- 	--Perhaps I stagger their duration to create an illusion.

-- 	local radius = 800 
-- 	local duration = 1 --seconds
-- 	local tickDuration = 0.5 / 360


-- 	--Get all enemies that are in the current radius... 
-- 	--TODO: somehow change this so they get highlighted when "hit" by the line...
-- 	--THOUGHTS: Perhaps as you loop through and draw the lines, check each enemies location and somehow see if it intersects with the line
-- 		-- Need to track which enemies I have already "hit" so we only do them once per revolution of the radar
-- 		-- I think line intersect logic is expensive to do every tick, 
-- 			--HACK: use FindUNitsInRadius and check it every nth line, maybe 12 times per revolution
-- 	-- local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, origin, nil, radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
-- 	-- for _,enemy in pairs(enemies) do
-- 	-- 	print("found a nearby enemy")
-- 	-- 	--TODO: Create Modifier, create animation
--  --   		--CreateModifierThinker( self:GetCaster(), self, "quillboar_puddle_modifier", { self:GetSpecialValueFor( "duration" ) }, vLocation, self:GetCaster():GetTeamNumber(), false )
--  --   		DebugDrawCircle(enemy:GetOrigin(), Vector(0,255,0), 128, 100, true, 5)

-- 	-- end

-- 	--DOTA API LINE INTERSECT:

-- 	-- table FindUnitsInLine(int teamNumber, Vector vStartPos, Vector vEndPos, handle cacheUnit, float width, int teamFilter, int typeFilter, int flagFilter)
-- 	local i = 1
-- 	Timers:CreateTimer(function()
-- 		if i > 360 then
-- 			Clear(enemiesScanned)
-- 			return false
-- 		end
-- 		if i < -360 then
-- 			Clear(enemiesScanned)
-- 			return false
-- 		end

-- 		--draw n lines at once
-- 		for j = 1, 3, 1 do
-- 			--radians is needed not degrees
-- 			local angle = i * 0.0174532925 
-- 			local x = radius * math.cos(angle)
-- 			local y = radius * math.sin(angle)
-- 			DebugDrawLine(origin, Vector(x,y,0) + origin, 255,0,0, true, duration)

-- 			--https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API/Global.FindUnitsInLine

-- 			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, origin, Vector(x,y,0) + origin, self:GetCaster(), 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
-- 			for _,enemy in pairs(enemies) do
-- 				print("Line intersects with an enemy")
-- 				--TODO: check if enemy has already been hit
-- 				--if not then hit enemy and add to hit list

-- 				if Contains(enemiesScanned, enemy) then
-- 					print("already hit this enemy")
-- 				else
-- 					print("New enemy hit")
-- 					DebugDrawCircle(enemy:GetOrigin(), Vector(0,255,0), 128, 100, true, 5)
-- 					enemiesScanned[enemy] = true --little hack so Contains works 
-- 				end
-- 			end
-- 			i = i-1
-- 		end
-- 		return tickDuration;
-- 	end
-- 	)

-- end

-- -----------------------------------------------------------------------------------------------
-- --Table/Set/List functions

-- -- Remove/Clear the whole set
-- function Clear(set)
-- 	for k,v in pairs(set) do
-- 		set[k] = nil
-- 	end
-- end

-- -- Remove this key from the set
-- function Remove(set, key)
-- 	set[key] = nil
-- end

-- -- Check if the set contains this key
-- function Contains(set, key)
--     return set[key] ~= nil
-- end


-- --Draws a radar pulse, an expanind circle
-- function radar_scan:DebugRadarScanPulse(origin)
-- 	local startRadius = 100
-- 	local endRadius = 800
-- 	local duration = 1 --seconds

-- 	--Draw the big circle and little circle for the whole duration.
-- 	--DebugDrawCircle(origin, Vector(255,0,0), 128, startRadius, true, duration)
-- 	DebugDrawCircle(origin, Vector(255,0,0), 0, endRadius, true, duration * 3)

-- 	--Draw an expanding/pulsing circle inside
-- 	local frames = 100
-- 	local frameDuration = (duration / frames)
-- 	local currentRadius = startRadius
-- 	local radiusIncrement = (endRadius - startRadius) / frames 

-- 	local i = 1
-- 	Timers:CreateTimer(function()
-- 		--draw the current tick
-- 		DebugDrawCircle(origin, Vector(255,0,0), 64, currentRadius, true, frameDuration * 3)
-- 		--increment for next draw
-- 		currentRadius = currentRadius + radiusIncrement
-- 		i = i +1
-- 		--Stop conditions
-- 		if currentRadius >= endRadius then
-- 			return
-- 		end
-- 		if i >= frames then
-- 			return
-- 		end
--  		return frameDuration /2
-- 	end
-- 	)
-- end


-- --
-- function radar_scan:DebugHightlightEnemiesInArea(origin,radius)
-- 	enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
--                               origin,
--                               nil,
--                               radius,
--                               DOTA_UNIT_TARGET_TEAM_ENEMY,
--                               DOTA_UNIT_TARGET_ALL,
--                               DOTA_UNIT_TARGET_FLAG_NONE,
--                               FIND_ANY_ORDER,
--                               false)

-- 	--foreach unit. highlight it's current origin
-- 	local drawRadius = 100
-- 	local drawDuration = 3




-- 	for i = 1, #enemies, 1 do
-- 		DebugDrawCircle(enemies[i]:getOrigin(), Vector(255,0,0), 128, drawRadius, true, drawDuration)
-- 	end
-- end

