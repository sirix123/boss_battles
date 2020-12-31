barrage_radius_melee = class({})

--Rocket barrage targets all enemies in the radius and distributes tickDamage amongst them every tickDuration.
function barrage_radius_melee:OnSpellStart()
	--print("barrage_radius_melee:OnSpellStart()")
	_G.IsGyroBusy = true

	local caster = self:GetCaster()
	local barrage_radius_attack = caster:FindAbilityByName("barrage_radius_attack")
	local barrage = caster:FindAbilityByName("barrage")

	local duration = barrage:GetSpecialValueFor("duration")
	local totalDamage = barrage:GetSpecialValueFor("total_damage")
	local radius = barrage:GetSpecialValueFor("melee_radius")

	local tickDuration = barrage:GetSpecialValueFor("damage_interval") -- Amount of time to delay between ticks
	local tickLimit = duration / tickDuration
	local tickDamage = totalDamage / tickLimit

	-- sound 
	EmitSoundOn( "gyrocopter_gyro_rocket_barrage_01", self:GetCaster() )
	-- TODO: any particles? 
	DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 64, radius, true, tickDuration*2) -- melee is red
	DebugDrawCircle(caster:GetAbsOrigin(), Vector(0,255,0), 96, radius*5, true, tickDuration*2) -- ranged is green

	--Run a timer for duration
	local tickCount = 0
	Timers:CreateTimer(function()	
		tickCount = tickCount + 1
		--check if we've reached the end of the spell
		if tickCount >= tickLimit then 
			_G.IsGyroBusy = false
			return
		 end

		--Get nearby enemies
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--if no enemies, then no need to continue
		if #enemies == 0 then return tickDuration end

		--Each enemy in radius gets hit for tickDamage / #enemies
		_G.BarrageCurrentDamage = tickDamage / #enemies
		for key, enemy in pairs(enemies) do 
			-- add the target to the target list
			_G.BarrageTargets[#_G.BarrageTargets+1] = enemy

			-- shoot barrage_radius_attack at enemy
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = barrage_radius_attack:entindex(), --if this doesn't work. use _G.BarrageRadiusAttack
				Queue = false, 
			})
		end
		return tickDuration --TODO: implement  deltaDelay, wait (0.1 - time to execute code)
	end)
end