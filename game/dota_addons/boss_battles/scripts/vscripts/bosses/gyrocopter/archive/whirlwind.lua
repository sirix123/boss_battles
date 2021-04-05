whirlwind = class({})
LinkLuaModifier( "whirlwind_burn_modifier", "bosses/gyrocopter/whirlwind_burn_modifier", LUA_MODIFIER_MOTION_NONE )
-- Gyro rotates in a circle, shooting a fireball and creating a fire patch every rotationPerTick degrees, 
-- shoots at enemy if enemy, or infront of himself at a distance inner_ring_radius
-- after full rotation, gyro causes gusts/whirlwind that blows fire outwards. fire moves outward/away from gyro at fire_movespeed 
-- this last for gust_duration seconds?

--gyro rotates, either 
function whirlwind:OnSpellStart()
	_G.IsGyroBusy = true
	_G.FireLocations = {}
	_G.WhirlwindRotationComplete = false

	local initialZ = self:GetCaster():GetAbsOrigin().z

	local maxRadius = self:GetSpecialValueFor("max_radius")
	local innerRadius = self:GetSpecialValueFor("inner_radius")
	local fire_movespeed = self:GetSpecialValueFor("fire_movespeed")
	local gust_duration = self:GetSpecialValueFor("gust_duration")
	local burnDuration = self:GetSpecialValueFor("burn_duration")
	local macropyreMaxLength = self:GetSpecialValueFor("macropyre_maxLength")
	local macropyreRadius = self:GetSpecialValueFor("macropyre_radius")


	local caster = self:GetCaster()

	local timerDelay = 0.15
	local rotationPerTick = 5
	local tickCount = 0	
	local rotationComplete = false
	local lineDetectionRadius = 120

	Timers:CreateTimer(function()
		--end condition: stop after 1 full rotation
		if (tickCount * rotationPerTick) > 360  then
			rotationComplete = true
			_G.WhirlwindRotationComplete = true -- whirlwind_attack will listen for this change to cleanup particles
			return
		end

		--get enemies in line forward from gyro, width lineDetectionRadius and length lineDetectionRadius
		local endPoint = (caster:GetForwardVector() * maxRadius) + caster:GetAbsOrigin()
		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), endPoint, caster, lineDetectionRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
		
		DebugDrawLine_vCol(caster:GetAbsOrigin(), endPoint , Vector(255,0,0), true, timerDelay)

		--TODO/POSSIBLE BUG: Find out if unitsInLine is closest first. Otherwise impl SortUnitByDistance(enemies)
		if #enemies > 0 then
			_G.WhirlwindTargets[#_G.WhirlwindTargets +1] = enemies[1]:GetAbsOrigin()
		--no enemy? shoot at ground
		else
			_G.WhirlwindTargets[#_G.WhirlwindTargets +1] = caster:GetAbsOrigin() + ( caster:GetForwardVector() * innerRadius )
		end

		--Cast the initial fireball/flame attack
		ExecuteOrderFromTable({
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = caster:FindAbilityByName("whirlwind_attack"):entindex(),
			Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
		})

		--rotate gyro
		caster:SetAngles(caster:GetAnglesAsVector().x, caster:GetAnglesAsVector().y + rotationPerTick, 0)
		
		tickCount = tickCount+1
		return timerDelay
	end)

	--after rotating/fireball phase then do gust/whirlwind phase
	local maxTicks = (gust_duration / timerDelay )
	local maxAltitude = 450
	local currentAltitude = caster:GetAbsOrigin().z
	local altitudePerTick = (maxAltitude - currentAltitude) / maxTicks
		
	local fireMoveDistPerTick = fire_movespeed * timerDelay

	--todo: REPLACE THIS WITH MY MACRO
	
 	local macropyreParticleName = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_line_flames.vpcf"
	local macropyreParticles = {}
	
	


	local macropyreTickCount = 0
	--start a timer but don't progress/execute anything until rotationComplete
	-- each tick: fly gyro up. rotate gyro. push macropyre away, burning any enemies hit
	Timers:CreateTimer(function()
		if not rotationComplete then return timerDelay end

		if #_G.WhirlWindAttackParticles > 0 then
			for i,fireLoc in pairs(_G.WhirlWindAttackParticles) do
				ParticleManager:DestroyParticle(_G.WhirlWindAttackParticles[i], true)
				_G.WhirlWindAttackParticles[i] = nil
			end
		end

		--end condition:
		if macropyreTickCount > maxTicks then
			--print("macropyreTickCount == maxTicks. Stopping..")
			--Remove macropyre particles? instantly or delyayed?
			for i,particle in pairs(macropyreParticles) do 
				ParticleManager:DestroyParticle(macropyreParticles[i], true)
			end

			--TODO; return gyro to the ground quickly.
			local returnToGroundTickCount = 0
			local maxTicksReturnToGround = 10
			local zDecrementPerTick = (caster:GetAbsOrigin().z - initialZ) / maxTicksReturnToGround
			Timers:CreateTimer(function()
				if returnToGroundTickCount == maxTicksReturnToGround then
					_G.IsGyroBusy = false
					return
				end
				--Decrement current.z 10 times, to reach initialZ
				caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z - zDecrementPerTick))

				returnToGroundTickCount = returnToGroundTickCount +1
				return timerDelay
			end)
			return
		end		
		
		
		-- fly gyro up. rotate gyro
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + altitudePerTick))
		caster:SetAngles(caster:GetAnglesAsVector().x, caster:GetAnglesAsVector().y + rotationPerTick, 0)

		-- push fires outwards
		for i,fireLoc in pairs(_G.FireLocations) do
			local direction = (fireLoc.StartLocation - caster:GetAbsOrigin()):Normalized()
			_G.FireLocations[i].EndLocation = fireLoc.EndLocation + (direction * fireMoveDistPerTick)

			--Create particles if nil, otherwise update particles start/end location
			if macropyreParticles[i] == nil then
				macropyreParticles[i] = ParticleManager:CreateParticle(macropyreParticleName, PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(macropyreParticles[i] , 0, fireLoc.StartLocation)
			else
				-- if length > macropyreMaxLength then reduce startLocation
				local length = (fireLoc.StartLocation - fireLoc.EndLocation):Length2D()
				if length > macropyreMaxLength then
					_G.FireLocations[i].StartLocation = fireLoc.EndLocation -  (direction * fireMoveDistPerTick)
					ParticleManager:SetParticleControl(macropyreParticles[i] , 0, fireLoc.StartLocation)
				end
				--each tick update end location
				ParticleManager:SetParticleControl(macropyreParticles[i] , 1, fireLoc.EndLocation)
			end

			--check in any enemy is hit
			local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, fireLoc.StartLocation, fireLoc.EndLocation, caster, macropyreRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
			for _,enemy in pairs(enemies) do

				if enemy:HasModifier("whirlwind_burn_modifier") then -- has modifier, increment it.
					local currBurnStacks = enemy:GetModifierStackCount("whirlwind_burn_modifier", self.caster)
					enemy:SetModifierStackCount("whirlwind_burn_modifier", self.caster, currBurnStacks +1)        	
				else -- no modifier yet, add it
					enemy:AddNewModifier(self:GetCaster(), self, "whirlwind_burn_modifier", {}) -- can pass kvp values in the final param	
				end
				--Decrease stacks after burnDuration
				Timers:CreateTimer(burnDuration, function()
					if enemy:HasModifier("whirlwind_burn_modifier") then
						local currBurnStacks = enemy:GetModifierStackCount("whirlwind_burn_modifier", self.caster)
						if currBurnStacks > 0 then
							enemy:SetModifierStackCount("whirlwind_burn_modifier", self.caster, currBurnStacks -1)        	
						end
					end		
					return 
				end)
			end
		end
		macropyreTickCount = macropyreTickCount+1
		return timerDelay
	end)



end
