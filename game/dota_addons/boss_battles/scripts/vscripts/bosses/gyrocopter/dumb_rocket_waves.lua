dumb_rocket_waves = class({})

--global var so the enemies detected can be accessed outside of this class
function dumb_rocket_waves:OnSpellStart()
	local caster = self:GetCaster()

	local totalWaves = self:GetSpecialValueFor("totalWaves")
	local timeBetween = self:GetSpecialValueFor("timeBetween")
	local meleeExclusionRadius = self:GetSpecialValueFor("meleeExclusionRadius")
	local maxRadius = 4000

	local currentWave = 1
	Timers:CreateTimer(function()	
		if currentWave > totalWaves then return end

		local origin = caster:GetAbsOrigin()

		--Get two sets nearby enemies, enemies within meleeExclusionRadius and enemies within maxRadius. 
		local meleeTargets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, origin, nil, meleeExclusionRadius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		local allEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, origin, nil, maxRadius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--algo to detect enemies within a donut shape: get all enemies within max radius, get enemies in min radius, remove enemies within minRadius from enemies within maxRadius
		local beyondRadiusEnemies = {}
		for _,rangedEnemy in pairs(allEnemies) do
			local enemyInBoth = false
			for _,meleeEnemy in pairs(meleeTargets) do
				if meleeEnemy == rangedEnemy then 
					enemyInBoth = true
					break
				end
			end
			if not enemyInBoth then
				beyondRadiusEnemies[#beyondRadiusEnemies +1] = rangedEnemy
			end
		end

		--Cast a rocket at each enemy in beyondRadiusEnemies
		for _,enemy in pairs(beyondRadiusEnemies) do
			_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = {}
			_G.HomingMissileTargets[#_G.HomingMissileTargets] = enemy
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = caster:FindAbilityByName("dumb_homing_missile_v2"):entindex(),
				Queue = true,
			})
		end

		currentWave = currentWave + 1
		return timeBetween --TODO: implement deltaTime for consistent time frames, don't delay by x, delay by x - timeTakenToProcess		
	end)
end
