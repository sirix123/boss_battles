--TODO: make a modifier thinker so I can draw the current state of the mouse during the drag portion. Timer won't allow me to GetCursorPosition.
--TODO: parametize "clicked" and "released" if these are two STATES then define them somewhere. 
--TODO: Make projectile spawn at origin instead of pullBackLocation. But need to update the target and direction math. 
	--Currently the projectile is spawning at pullBackLocation and moving to clickLocation.

--trying to make an ability which shoots based on where the user clicks and then drags. As if the user was pulling a slingShot back, the projectile fires on the inverse of that
-- the ability is only used when the key is released
slingShot = class({})

local timerInterval = 0.1
local slingShotState = "clicked"
local radius = 50
local clickLocation = Vector()
local pullBackLocation = Vector()

function slingShot:OnSpellStart()
	local origin = self:GetCaster():GetAbsOrigin()

	--First time this ability/spell is used. Just store the cursor location
	if slingShotState == "clicked" then 
		--store the click location and move to next phase
		clickLocation = self:GetCursorPosition()			
		slingShotState = "released"

		--Show where the user clicked, and is now dragging there mouse. do this with 2 circles and a line. 
		--BUG: This doesn't work because self:GetCursorPosition() is returning an empty vector when inside a timer.. weird..just use a modifer thinker..
		-- Timers:CreateTimer(function() 
		-- 	print("self:GetCursorPosition() = ", self:GetCursorPosition())
		-- 	DebugDrawCircle(clickLocation, Vector(0,0,255), 128, 100, true, timerInterval) -- blue circ at clickLocation
		-- 	DebugDrawLine(clickLocation, self:GetCursorPosition() + origin, 0,255,0, true, timerInterval)
		-- 	DebugDrawCircle(self:GetCursorPosition() + origin, Vector(0,0,255), 128, 100, true, timerInterval) -- blue circ at current cursor
		-- 	--stop once the mouse has been released
		-- 	if slingShotState == "clicked" then
		-- 		return
		-- 	end
		-- 	return timerInterval
		-- end)

		return
	end

	--Second time this ability/spell is used. Activate the spell
	if slingShotState == "released" then 
		-- reset back to starting state
		slingShotState = "clicked"
		pullBackLocation = self:GetCursorPosition()			
		DebugDrawCircle(pullBackLocation, Vector(0,255,255), 128, radius, true, 8) -- lightblue circ at pullBackLocation

		local vec_distance =  clickLocation	- pullBackLocation
	    local distance = (vec_distance):Length2D()
	    local direction = (vec_distance):Normalized()
		local target =  clickLocation + vec_distance -- not sure this is correct
		DebugDrawCircle(target, Vector(255,0,0), 128, radius, true, 10) -- red circ at target

		--speed should actually be determined by distance... the length you've pulled the slingshot back will put more power into the shot...
		local speed = 15
		--TODO: projectileLocation should start at self.GetCaster:GetAbsOrigin()
		local projectileLocation = pullBackLocation --TODO: the projectile won't shoot from the hero but this way the animation woirks
		Timers:CreateTimer(function() 
			speed = speed * 1.05 --make the projectile get faster over time
			projectileLocation = projectileLocation + (speed * direction)
			DebugDrawCircle(projectileLocation, Vector(0,255,0), 128, radius, true, timerInterval) -- green circ is projectile			

			-- collision check..
			local dist =  (target - projectileLocation):Length2D()
			if dist < 50 then
				DebugDrawCircle(target, Vector(255,0,0), 255, 100, true, timerInterval)
				return
			end
			--seems like we missed the target.... destroy if distance is to big.
			--TODO: change this to tickBased so it has a limited duration. 
			if distance > 3000 then return end
			return timerInterval
		end) --end timer
	end
end -- end OnSpellStarted