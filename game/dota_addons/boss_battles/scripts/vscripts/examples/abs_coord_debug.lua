abs_coord_debug = class({})


--This spell prints the coordinates at the location of the cursor on the screen in game.  
--By printing the value of GetCursorPosition()
function abs_coord_debug:OnSpellStart()
	local duration = 50
	local cursorLoc = self:GetCursorPosition()
	DebugDrawCircle(cursorLoc, Vector(255,255,255), 128, 10, true, duration)
	DebugDrawText(cursorLoc, "GetCursorPosition", true, 50)
	DebugDrawText(cursorLoc + Vector(0,-50,0), tostring(cursorLoc), true, duration)
end


