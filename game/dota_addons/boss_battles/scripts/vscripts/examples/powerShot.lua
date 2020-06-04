--TODO: stop using globals: powerShotTarget amd 

--I'm using this ability twice, one on key press and once on key release
powerShot = class({})


local powerShotTarget = nil
local powerShotRadius = nil

local timerInterval = 0.1
local powerShotPressed
function powerShot:OnSpellStart()
	local origin = self:GetCaster():GetAbsOrigin()

	--powerShotPressed pressed. Ability used first time
	if powerShotPressed == nil then 
		powerShotPressed = true -- this flag will signify the next time this code runs it's the second time running.

		local tickCount = 0	
		Timers:CreateTimer(function()  
			tickCount = tickCount +1
			origin = self:GetCaster():GetAbsOrigin()
			local length = 300 + (tickCount * 20)
			local radius = tickCount * 3

			--stop the timer and reset tickCount
			if powerShotPressed == nil then
				tickCount = 0
				return false -- stop the timer
			end
			--Draw some indicator to show how long the button is held down
			local endPoint = (self:GetCaster():GetForwardVector() * length) + origin
			DebugDrawLine(origin, endPoint, 0,255,0, true, timerInterval) --green line 
			DebugDrawCircle(origin, Vector(0,255,0), 128, radius, true, timerInterval) --green circle

			powerShotTarget = endPoint
			powerShotRadius = radius
			return timerInterval
		end)

		return
	end

	--powerShotPressed released. Ability used second time
	if powerShotPressed == true then 
		print("powerShotPressed == true")
		powerShotPressed = nil
		local vec_distance =  powerShotTarget - origin
		local direction = (vec_distance):Normalized()
		local speed = 15

		local frameCount = 1
		Timers:CreateTimer(function()  
			speed = speed + 1
			origin = self:GetCaster():GetAbsOrigin()
			local point = origin + ( frameCount * ( direction * speed ) )
			DebugDrawCircle(point, Vector(0,255,0), 128, powerShotRadius, true, timerInterval) --green circle
			
			-- collision check..
			local dist =  (powerShotTarget - point):Length2D()
			if dist < 60 then
				DebugDrawCircle(powerShotTarget, Vector(255,0,0), 255, powerShotRadius, true, timerInterval)
				return
			end
			
			frameCount = frameCount +1
			return timerInterval
		end)
	end

end