barrage_radius_melee = class({})

--Rocket barrage targets all enemies in the radius and distributes tickDamage amongst them every tickDuration.
function barrage_radius_melee:OnSpellStart()
	_G.IsGyroBusy = true

	local caster = self:GetCaster()
	local barrage_radius_attack = caster:FindAbilityByName("barrage_radius_attack")
	local barrage_radius_ranged = caster:FindAbilityByName("barrage_radius_ranged")
	local barrage = caster:FindAbilityByName("barrage")

	local duration = barrage:GetSpecialValueFor("duration")/2 --because this duration comes from barrage, half it for this half (melee/ranged) of the ability
	local totalDamage = barrage:GetSpecialValueFor("total_damage")
	local radius = barrage:GetSpecialValueFor("melee_radius")
	local maxRadius = barrage:GetSpecialValueFor("ranged_radius")
	--Not 100% accurate because we don't use delta time. It won't get through all of these attacks.
	local tickDuration = barrage:GetSpecialValueFor("damage_interval") -- Amount of time to delay between ticks
	local tickLimit = (duration) / tickDuration
	local tickDamage = totalDamage / tickLimit

	-- sound 
	EmitSoundOn( "gyrocopter_gyro_rocket_barrage_01", caster )
	-- TODO: any particles? 
	-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 64, radius, true, tickDuration*2) -- melee is red
	-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(0,255,0), 96, radius*5, true, tickDuration*2) -- ranged is green

	--red in melee. green in ranged.
    local redRadius = radius
    local redPulseParticle = ParticleManager:CreateParticle( "particles/gyrocopter/red_pulse_custom.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl(redPulseParticle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(redPulseParticle, 1, Vector(redRadius,0,0))

    local greenRadius = maxRadius
    local greenPulseParticle = ParticleManager:CreateParticle( "particles/gyrocopter/green_pulse_custom.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl(greenPulseParticle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(greenPulseParticle, 1, Vector(greenRadius,0,0))


	--Run a timer for duration
	local tickCount = 0
	local startTime = Time()
	local dmgSum = 0
	Timers:CreateTimer(function()	
		if tickCount > tickLimit then
			ParticleManager:DestroyParticle(redPulseParticle, true)
			ParticleManager:DestroyParticle(greenPulseParticle, true)

			local endTime = Time()
			local actualElapsed = endTime - startTime
			-- cast ranged barrage if this flag is set. (allows this ability to be used in isolation or in combination with ranged barrage)
			if _G.castRangeBarrageOnFinish then
			  	ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = barrage_radius_ranged:entindex(),
					Queue = false,
				})
				_G.castRangeBarrageOnFinish = false -- flip the variable 'off'
			--gyro no longer busy only if he didn't cast the next spell
			else 
				_G.IsGyroBusy = false
			end
			return
		end

		--Get nearby enemies
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--if enemies in range. shoot them
		if #enemies > 0 then
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
		end

		tickCount = tickCount +1
		return tickDuration --TODO: implement  deltaDelay, wait (0.1 - time to execute code)
	end)
end