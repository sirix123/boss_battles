--I'm using this ability twice, one on key press and once on key release
powerShot = class({})

local tickCount = 0
local timerInterval = 0.1
function powerShot:OnSpellStart()
	print("powerShot:OnSpellStart()")

	local origin = self:GetCaster():GetAbsOrigin()
	print("origin = ", origin)

	--powerShotPressed pressed. Ability used first time
	if _G.powerShotPressed == nil then 
		print("_G.powerShotPressed == nil")
		--this timer will continue to run, so the code inside may get executed even if the above if statement is false
		_G.powerShotPressed = true -- this flag will signify the next time this code runs it's the second time running.

		Timers:CreateTimer(function()  
			tickCount = tickCount +1
			origin = self:GetCaster():GetAbsOrigin()
			local length = tickCount * 13
			local radius = tickCount * 2

			if _G.powerShotPressed == nil then
				print("stopping the timer")
				tickCount = 0
				return false -- stop the timer
			end
			--Draw some indicator to show how long the button is held down
			local endPoint = (self:GetCaster():GetForwardVector() * length) + origin
			DebugDrawLine(origin, endPoint, 0,255,0, true, timerInterval) --green line 
			DebugDrawCircle(origin, Vector(0,255,0), 128, radius, true, timerInterval) --green circle

			_G.powerShotTarget = endPoint
			_G.powerShotRadius = radius
			return timerInterval
		end)

		return
	end

	--powerShotPressed released. Ability used second time
	if _G.powerShotPressed == true then 
		print("_G.powerShotPressed == true")
		_G.powerShotPressed = nil
		local vec_distance =  _G.powerShotTarget - origin
		local direction = (vec_distance):Normalized()

		local speed = 25

		local frameCount = 1
		Timers:CreateTimer(function()  
			origin = self:GetCaster():GetAbsOrigin()
			local point = origin + ( frameCount * ( direction * speed ) )
			DebugDrawCircle(point, Vector(0,255,0), 128, _G.powerShotRadius, true, timerInterval) --green circle
			
			--TODO: collision check..
			--calc distance between point and target.. 

			frameCount = frameCount +1
			return timerInterval
		end)
	end

end