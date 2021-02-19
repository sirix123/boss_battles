barrage_radius_ranged = class({})

--Rocket barrage targets all enemies in the radius and distributes tickDamage amongst them every tickDuration.
function barrage_radius_ranged:OnSpellStart()
	_G.IsGyroBusy = true
	local caster = self:GetCaster()

	local barrage_radius_attack = caster:FindAbilityByName("barrage_radius_attack")
	local barrage_radius_melee = caster:FindAbilityByName("barrage_radius_melee")
	local barrage = caster:FindAbilityByName("barrage")

	local radius = barrage:GetSpecialValueFor("melee_radius")  -- hit every unit beyond this radius. ignore units within this radius
	local maxRadius = barrage:GetSpecialValueFor("ranged_radius")  
	local duration = barrage:GetSpecialValueFor("duration")/2 --because this duration comes from barrage, half it for this half (melee/ranged) of the ability
	
	local totalDamage = barrage:GetSpecialValueFor("total_damage")
	local tickDuration = barrage:GetSpecialValueFor("damage_interval") -- Amount of time to delay between ticks
	local tickLimit = duration / tickDuration
	local tickDamage = totalDamage / tickLimit

	-- sound 
	EmitSoundOn( "gyrocopter_gyro_rocket_barrage_05", caster )

	--particles:
	--red in ranged. green in melee.
    local redRadius = maxRadius
    local redPulseParticle = ParticleManager:CreateParticle( "particles/gyrocopter/red_pulse_custom.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl(redPulseParticle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(redPulseParticle, 1, Vector(redRadius,0,0))

    local greenRadius = radius
    local greenPulseParticle = ParticleManager:CreateParticle( "particles/gyrocopter/green_pulse_custom.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl(greenPulseParticle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(greenPulseParticle, 1, Vector(greenRadius,0,0))

	--Run a timer for duration
	local tickCount = 0
	local startTime = Time()
	Timers:CreateTimer(function()	
		if tickCount > tickLimit then
			ParticleManager:DestroyParticle(redPulseParticle, true)
			ParticleManager:DestroyParticle(greenPulseParticle, true)
			
			local endTime = Time()
			local actualElapsed = endTime - startTime
			--print("ranged barrage actualElapsed = ".. actualElapsed)

			-- cast melee barrage if this flag is set. (allows this ability to be used in isolation or in combination with melee barrage)
			if _G.castMeleeBarrageOnFinish then
			  	ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = barrage_radius_melee:entindex(),
					Queue = false,
				})
				_G.castMeleeBarrageOnFinish = false -- flip the variable 'off'
			--gyro no longer busy only if he didn't cast the next spell
			else
				_G.IsGyroBusy = false
			end
			return
		end

		--Get two sets nearby enemies, enemies within radius and enemies within maxRadius. 
		local inRadiusenemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		local allEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, maxRadius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--algo to detect enemies within a donut shape: get all enemies within max radius, get enemies in min radius, remove enemies within minRadius from enemies within maxRadius
		local beyondRadiusEnemies = {}
		for _,rangedEnemy in pairs(allEnemies) do
			local enemyInBoth = false
			for _,meleeEnemy in pairs(inRadiusenemies) do
				if meleeEnemy == rangedEnemy then 
					enemyInBoth = true
					break
				end
			end
			if not enemyInBoth then
				beyondRadiusEnemies[#beyondRadiusEnemies +1] = rangedEnemy
			end
		end

		--Each enemy in radius gets hit for tickDamage / #enemies
		
		_G.BarrageCurrentDamage = tickDamage / #beyondRadiusEnemies
		for key, enemy in pairs(beyondRadiusEnemies) do 
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
		tickCount = tickCount +1
		return tickDuration
	end)
end