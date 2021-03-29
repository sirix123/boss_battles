flee = class({})

-- Gyro moves toward target, leaving behind a trail of oil puddles, which he then ignites upon arrive at location


function flee:OnSpellStart()
	--print("flee:OnSpellStart()")
	_G.IsGyroBusy = true
	local target = self:GetCursorPosition()
	local caster = self:GetCaster()
	local startPoint = caster:GetAbsOrigin()

	local fleeSpeed = self:GetSpecialValueFor("flee_speed")
	local radius = self:GetSpecialValueFor("radius")
	local dmg = self:GetSpecialValueFor("damage")
	local collisionDist  = self:GetSpecialValueFor("collision_distance")

	--get burn_duration from whirlwind
	local burnDuration = self:GetCaster():FindAbilityByName( "whirlwind" ):GetSpecialValueFor("burn_duration")
	--print("burnDuration = ", burnDuration)

	local originalMs = self:GetCaster():GetBaseMoveSpeed()
	self:GetCaster():SetBaseMoveSpeed(fleeSpeed)

	local distance = (target - self:GetCaster():GetAbsOrigin()):Length2D()
	local travelTime = distance / self:GetCaster():GetBaseMoveSpeed()

	local tickDelay = 0.1

	--tilt gyro's nose 25 degrees up, so he's aiming up as he flies away
	caster:SetAngles(-25,0,0) -- does this work?
	caster:MoveToPosition(target)

	local particle = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf"
	local enemiesAlreadyHit = {}
	local previousPosition = nil
	local puddles = {}
	Timers:CreateTimer(function()
		local distance = (target - caster:GetAbsOrigin()):Length2D()

		if previousPosition ~= nil then
			--Place a puddle at gyros current position.
			--TODO: make it so it places it at gyro's previous position. So it's behind him instead of in front
			local puddle = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN , caster  )
			ParticleManager:SetParticleControl( puddle, 0, caster:GetAbsOrigin() )
			puddles[#puddles+1] = puddle
		end

		local runOverEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetCaster():GetAbsOrigin(), nil, collisionDist*2, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		for _,enemy in pairs(runOverEnemies) do
			-- check that enemy is in enemiesAlreadyHit.
			local enemyAlreadyHit = false
			if #enemiesAlreadyHit > 0 then
				for i = 1, #enemiesAlreadyHit do 
					if enemiesAlreadyHit[i] == enemy then
						enemyAlreadyHit = true
					end
				end
			end
			--only damage enemies not already hit
			if not enemyAlreadyHit then
				local dmgTable =
	            {
	                victim = enemy,
	                attacker = caster,
	                damage = dmg/2,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	            }
	            ApplyDamage(dmgTable)
				enemiesAlreadyHit[#enemiesAlreadyHit+1] = enemy
			end
		end

		--gyro arrived at location, ignite puddles on fire		
		if (distance <= collisionDist) then
			caster:SetBaseMoveSpeed(originalMs)
			local endPoint = caster:GetAbsOrigin()

			local macropyreParticleName = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_line_flames.vpcf"
			local macropyreParticle = ParticleManager:CreateParticle(macropyreParticleName, PATTACH_WORLDORIGIN, nil)
			local macropyreRadius = 150

			--TODO: put some of this in KVP
			local macropyreIgniteTime = 2 -- seconds it takes for macropyre to ignite from start to finish
			local macropyreDuration = 7 --seconds macropyre will be around for, in full length for (macropyreDuration - macropyreIgniteTime)
			local macropyreStopOnTick = macropyreDuration / tickDelay --number of ticks macropyre will 
			local macropyreTick = 0
			local macropyreCurrentEndPoint = caster:GetAbsOrigin()
			local macropyreDistPerTick = ((startPoint - caster:GetAbsOrigin())) / (macropyreIgniteTime / tickDelay )

			ParticleManager:SetParticleControl(macropyreParticle, 0, caster:GetAbsOrigin())
			macropyreCurrentEndPoint = macropyreCurrentEndPoint + macropyreDistPerTick
			ParticleManager:SetParticleControl(macropyreParticle, 1, macropyreCurrentEndPoint)

			--start timer to remove macropyre after duration, and until duration check if enemies in line
			Timers:CreateTimer(function()
				macropyreTick = macropyreTick+1
				if macropyreTick == macropyreStopOnTick then
					--cleanup macropyre particle
					--TODO: don't destroy particle instantly, shrink it from start toward end, then finally delete.
					ParticleManager:DestroyParticle(macropyreParticle, true)
					_G.IsGyroBusy = false
			 		return
			  	end

				if ( #puddles > 0 ) then
					ParticleManager:DestroyParticle(puddles[#puddles], true)
					puddles[#puddles] = nil
					--Macro was going 1 too far. so stop 1 early
					if #puddles > 1 then
						macropyreCurrentEndPoint = macropyreCurrentEndPoint + macropyreDistPerTick
						ParticleManager:SetParticleControl(macropyreParticle, 1, macropyreCurrentEndPoint)
					end
				end

				--Check for enemies in line, apply or increment burn mod
				local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, endPoint, macropyreCurrentEndPoint, caster, macropyreRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
				for _,enemy in pairs(enemies) do
					if enemy:HasModifier("whirlwind_burn_modifier") then -- has modifier, increment it.
						--print("enemy already has burn_mod, incrementing")
						local currBurnStacks = enemy:GetModifierStackCount("whirlwind_burn_modifier", caster)
						enemy:SetModifierStackCount("whirlwind_burn_modifier", caster, currBurnStacks +1)        	
					else -- no modifier yet, add it
						--print(enemy:GetUnitName() .. " doesn't have burn_mod. adding it")
						enemy:AddNewModifier(caster, self, "whirlwind_burn_modifier", {}) -- can pass kvp values in the final param	
					end
					--Decrease stacks after burnDuration
					Timers:CreateTimer(burnDuration, function()
						if enemy:HasModifier("whirlwind_burn_modifier") then
							local currBurnStacks = enemy:GetModifierStackCount("whirlwind_burn_modifier", caster)
							if currBurnStacks > 0 then
								enemy:SetModifierStackCount("whirlwind_burn_modifier", caster, currBurnStacks -1)        	
							end
						end		
						return 
					end)
				end
				return tickDelay
			end)
			--print("Flee ended. _G.IsGyroBusy = false")
	        _G.IsGyroBusy = false
        	return --stop timer, ability ended.
		end

		previousPosition = caster:GetAbsOrigin()
		return tickDelay
	end)

end
