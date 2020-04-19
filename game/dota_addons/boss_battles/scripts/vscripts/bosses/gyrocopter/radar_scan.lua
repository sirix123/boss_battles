radar_scan = class({})
LinkLuaModifier( "radar_scan_modifier", "bosses/gyrocopter/radar_scan_modifier", LUA_MODIFIER_MOTION_NONE )

local radScan_radius = 1200 --todo: put this in the ability txt file

function radar_scan:OnSpellStart()

	local origin = self:GetCaster():GetOrigin()

	--Not working correctly because of lua tables :(
	--self:DebugRadarScanSweep(origin)

	self:DebugRadarScanPulse(origin)
	
	--self:DebugHightlightEnemiesInArea(origin, 800)


	--TODO: forget about animation for now.
	--Spell effect: Target every player within radius and deal dmg, apply mod /effect to ground to dmg units who don't move. 
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, origin, nil, radScan_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	--Create a bunch of modifier thinkers, one for each player found in radius. 
	for _,enemy in pairs(enemies) do
   		--CreateModifierThinker( self:GetCaster(), self, "quillboar_puddle_modifier", { self:GetSpecialValueFor( "duration" ) }, vLocation, self:GetCaster():GetTeamNumber(), false )
	end

end

--Draws a radar scan, a sweeping around the circle
function radar_scan:DebugRadarScanSweep(origin)
	local radius = 800 
	local duration = 0.5 --seconds
	local tickDuration = 0.5 / 360



	

	--draw: run a timer and every tick draw a new line
	local i = 1
	Timers:CreateTimer(function()
		--TODO:
		-- if i >= 360 then return end

		local x = radius * math.cos(i)
		local y = radius * math.sin(i)
		DebugDrawLine(origin, Vector(x,y,0) + origin, 255,0,0, true, duration)
		i = i+1
		return  tickDuration
	end
	)
end

--Draws a radar pulse, an expanind circle
function radar_scan:DebugRadarScanPulse(origin)
	local startRadius = 100
	local endRadius = 800
	local duration = 1 --seconds

	--Draw the big circle and little circle for the whole duration.
	--DebugDrawCircle(origin, Vector(255,0,0), 128, startRadius, true, duration)
	DebugDrawCircle(origin, Vector(255,0,0), 128, endRadius, true, duration)

	--Draw an expanding/pulsing circle inside
	local frames = 100
	local frameDuration = (duration / frames)
	local currentRadius = startRadius
	local radiusIncrement = (endRadius - startRadius) / frames 

	local i = 1
	Timers:CreateTimer(function()
		--draw the current tick
		DebugDrawCircle(origin, Vector(255,0,0), 128, currentRadius, true, frameDuration * 3)
		--increment for next draw
		currentRadius = currentRadius + radiusIncrement
		i = i +1
		--Stop conditions
		if currentRadius >= endRadius then
			return
		end
		if i >= frames then
			return
		end
 		return frameDuration
	end
	)
end


--
function radar_scan:DebugHightlightEnemiesInArea(origin,radius)
	enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              origin,
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

	--foreach unit. highlight it's current origin
	local drawRadius = 100
	local drawDuration = 3




	for i = 1, #enemies, 1 do
		DebugDrawCircle(enemies[i]:getOrigin(), Vector(255,0,0), 128, drawRadius, true, drawDuration)
	end
end

