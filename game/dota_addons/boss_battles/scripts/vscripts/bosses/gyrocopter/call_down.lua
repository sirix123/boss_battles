call_down = class({})
--SPELL CONCEPT:
--The spell is cast at an aoe location(pt,radius), it indicators for x seconds, and then applies dmg in the aoe.
--Perhaps leave aoe dmg in the area afterwards
--Or apply a burn/bleed effect on players hit


--TODO Find some particle effects for call_down

--Potentially: 
-- particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_sparks.vpcf
-- particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion.vpcf
-- particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_flash_c.vpcf
-- particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_second.vpcf
-- particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_flash_g.vpcf

--TODO: write the logic for the spell.



local radius = 1200
local indicator_duration = 3


local location = {}
function call_down:OnSpellStart()
	print("========================")
	print("call_down:OnSpellStart()")
	print("========================")

	local cursorPos = self:GetCursorPosition()	

	local cursorPos = self:GetCursorPosition()
	print("cursorPos = ", cursorPos)
	--DebugDrawCircle(cursorPos, Vector(0,255,0), 128, 250, true, 3) -- green = caster_origin 		

	local caster_origin = self:GetCaster():GetAbsOrigin()
	local caster_origin2 = self:GetCaster():GetOrigin()
	print("GetCaster():GetAbsOrigin() = ", self:GetCaster():GetAbsOrigin())
	print("GetCaster():GetOrigin() = ", self:GetCaster():GetOrigin())
	print("GetCursorPosition() = ", self:GetCursorPosition())
	print("========================")
	print("========================")

	local caster_cursorPos = self:GetCaster():GetCursorPosition()
	print("caster_cursorPos = ", caster_cursorPos)
	--local caster_origin = self:GetCaster()

	location = shallowcopy(self:GetCursorPosition())
	--print("location = ", location)

	local caster = self:GetCaster()
	local caster_origin = self:GetCaster():GetAbsOrigin()
	print("caster_origin = ", caster_origin)

	--DEBUG: 
	--DebugDrawCircle(caster_origin, Vector(0,255,0), 128, 250, true, 3) -- green = caster_origin 		
	--DebugDrawCircle(caster_cursorPos, Vector(0,0,255), 128, 250, true, 3) -- blue = caster_cursorPos 		



	local tick_interval = 0.05
	local total_ticks = indicator_duration / tick_interval

	--print("total_ticks = ", total_ticks)

	local current_tick = 0
	--Start a timer that at the end will trigger the main spell (particles and dmg portion)
	Timers:CreateTimer(function()	
		current_tick = current_tick +1
		if current_tick >= total_ticks then
			print("Call down landing!")

			-- TODO: particle effects

			-- TODO: get enemies in radius
			--local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 10000,
			--DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )


			-- TODO: apply dmg to enemies



			return	--stop the timer 
		end
	return tick_interval
	end)


-------------------------------------------------------------
-- Below code is for the pre-dmg indicator
	--perhaps a growing ring...


	--Different types of indicators:
		-- Flash a fixed radius red circle, blinking lights fixed speed
		-- Flash a fixed radius red circle, blinking lights at increasing speed 
		-- Grow a circle from small radius to full radius over indicator_duration
		-- Show radius at increasing color intensity, increase/reduce opacity over duration


	-- Flash a fixed radius red circle, blinking lights fixed speed
	--vars needed: indicator duration, tick_interval, tick count, total_ticks, modulus_amount
	-- local current_tick = 0
	-- local total_flashes = 20
	-- local modulus_amount = total_ticks / total_flashes 
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	if current_tick % modulus_amount == 0 then
	-- 		DebugDrawCircle(location, Vector(255,0,0), 128, radius, true, tick_interval)		
	-- 	end
		
	-- return tick_interval
	-- end)


	-- Flash a fixed radius red circle, blinking lights at increasing speed 
	-- local current_tick = 0
	-- local modulus_amount = total_ticks / 5
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	if current_tick % modulus_amount == 0 then
	-- 		DebugDrawCircle(location, Vector(255,0,0), 128, radius, true, tick_interval *2)		
	-- 		modulus_amount = modulus_amount - 1
	-- 	end
		
	-- return tick_interval
	-- end)



	-- Grow a circle from small radius to full radius over indicator_duration
	-- local start_radius = 20
	-- local end_radius = radius --or less...
	-- local current_radius = start_radius
	-- local growth_amount = end_radius / total_ticks
	-- --local growth_amount = (end_radius / total_ticks) - start_radius
	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	current_radius = current_radius + growth_amount

	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	DebugDrawCircle(location, Vector(255,0,0), 128, current_radius, true, tick_interval)		
		
	-- return tick_interval
	-- end)


	-- Show radius at increasing color intensity, increase/reduce opacity over duration
	-- local current_alpha = 0
	-- local growth_amount = 256 / total_ticks

	-- Timers:CreateTimer(function()	
	-- 	current_tick = current_tick +1
	-- 	current_alpha = current_alpha + growth_amount

	-- 	if current_tick >= total_ticks then
	-- 		return	--stop the timer 
	-- 	end

	-- 	DebugDrawCircle(location, Vector(255,0,0), current_alpha, current_radius, true, tick_interval)		
		
	-- return tick_interval
	-- end)

	-- local targetOrigin = target:GetAbsOrigin()
	-- print("targetOrigin = ", targetOrigin)

	--show indicator at that loc for indicator_duration


	--After indicator duration, trigger spell dmg and particle animation


	--

end


---------------------------------------------------------------------------------------------------
-- Various aoe indicators



function call_down:GetAOERadius()
	return self:GetSpecialValueFor("radius")
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
