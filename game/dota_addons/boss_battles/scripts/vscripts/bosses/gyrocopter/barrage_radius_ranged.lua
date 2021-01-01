barrage_radius_ranged = class({})

--Rocket barrage targets all enemies in the radius and distributes tickDamage amongst them every tickDuration.
function barrage_radius_ranged:OnSpellStart()
	--print("barrage_radius_ranged:OnSpellStart()")

	local caster = self:GetCaster()
	local barrage_radius_attack = caster:FindAbilityByName("barrage_radius_attack")
	local barrage = caster:FindAbilityByName("barrage")

	local duration = barrage:GetSpecialValueFor("duration")
	local totalDamage = barrage:GetSpecialValueFor("total_damage")
	local radius = barrage:GetSpecialValueFor("melee_radius")  -- hit every unit beyond this radius. ignore units within this radius
	local maxRadius = 4000 -- big enough to cover whole arena, but not big enough to hit units outside of arena
	
	--Not 100% accurate because we don't use delta time. It won't get through all of these attacks.
	local tickDuration = barrage:GetSpecialValueFor("damage_interval") -- Amount of time to delay between ticks
	local tickLimit = duration / tickDuration
	local tickDamage = totalDamage / tickLimit

		--new approach to timing this spell... 
	local stopFlag = false
	Timers:CreateTimer(duration/2, function()
		stopFlag = true
		return
    end)

	-- sound 
	EmitSoundOn( "gyrocopter_gyro_rocket_barrage_05", caster )
	-- TODO: any particles?
	DebugDrawCircle(caster:GetAbsOrigin(), Vector(0,255,0), 96, radius, true, tickDuration*2) -- melee is green
	DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 64, radius*5, true, tickDuration*2) -- ranged is red

	--Run a timer for duration
	Timers:CreateTimer(function()	

		if stopFlag then
			_G.IsGyroBusy = false
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
		return tickDuration
	end)
end