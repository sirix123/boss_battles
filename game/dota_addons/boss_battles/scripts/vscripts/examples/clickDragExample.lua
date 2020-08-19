--TODO: describe this class

-- Click and drag works by calling the ability twice, the first time when the mouse is clicked, the second time when the mouse is released.
	-- You'll need to use the custom_hotkeys javascript to do this
clickDragExample = class({})

--The mouse state for this class is a little bit unintuitive. Often the mouseState reflects what the next action will be (Click or release) and doesn't reflect it's current state
local MOUSE_STATE_CLICKED = "clicked"
local MOUSE_STATE_RELEASED = "released"
local mouseState = MOUSE_STATE_CLICKED --the first time the ability is called is when the mouse is clicked, so start with this val
 
local timerInterval = 0.1

local clickLocation = Vector()
local clickTime = 0
local releaseLocation = Vector()
local releaseTime = 0

function clickDragExample:OnSpellStart()
	if mouseState == MOUSE_STATE_CLICKED then
		clickLocation = self:GetCursorPosition()		
		clickTime = Time()
		clickTime = GetGameTime()	
		mouseState = MOUSE_STATE_RELEASED --update state to the next state, so when this ability is called next time it performs the RELEASED portion

		-- Any actions you want to take whilst the mouse is being dragged do them in here.
		Timers:CreateTimer(function() 
			local cursorPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
			--local distance =  clickLocation	- cursorPos

			--DEBUGGING/TESTING:
			--DebugDrawCircle(clickLocation, Vector(0,0,255), 128, 100, true, timerInterval) -- blue circ at clickLocation
			--DebugDrawCircle(cursorPos, Vector(0,0,255), 128, 100, true, timerInterval) -- blue circ at current cursor			

			if mouseState == MOUSE_STATE_CLICKED then return end -- stop the timer if the mouse has been released.
			return timerInterval
		end) --end timer


		
		return
	end

	if mouseState == MOUSE_STATE_RELEASED then
		releaseLocation = self:GetCursorPosition()
		mouseState = MOUSE_STATE_CLICKED --update state to the next state, so when this ability is called next time it performs the CLICKED portion

		local distance =  clickLocation	- releaseLocation
		local direction (distance):Normalized()

		--TODO: 
	end


end
