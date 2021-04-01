whirlwind_v2 = class({})
LinkLuaModifier( "whirlwind_burn_modifier", "bosses/gyrocopter/whirlwind_burn_modifier", LUA_MODIFIER_MOTION_NONE )
-- Gyro rotates in a circle, shooting a fireball and creating a fire patch every rotationPerTick degrees, 
-- shoots at enemy if enemy, or infront of himself at a distance inner_ring_radius
-- after full rotation, gyro causes gusts/whirlwind that blows fire outwards. fire moves outward/away from gyro at fire_movespeed 
-- this last for gust_duration seconds?

--gyro rotates, either
function whirlwind_v2:OnSpellStart()
	if IsServer() then

	_G.FireLocations = {}
	_G.WhirlwindRotationComplete = false
	_G.WhirlwindTargets = {}

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
	local create_arrow = true

	--[[ 	---------------------------------------------

		fly to center of the arena & root self & disable attack

	]] 		---------------------------------------------

	self:GetCaster():MoveToPosition(Vector(-12273,1545,132))

	self:GetCaster():AddNewModifier( nil, nil, "modifier_rooted", { duration = -1 })

	self:GetCaster():AddNewModifier( nil, nil, "modifier_generic_disable_auto_attack", { duration = -1 })


	--[[ 	---------------------------------------------

		rotate and shoot balls

	]] 		---------------------------------------------

	Timers:CreateTimer(function()
		--end condition: stop after 1 full rotation
		if (tickCount * rotationPerTick) > 360  then
			rotationComplete = true
			_G.WhirlwindRotationComplete = true -- whirlwind_attack will listen for this change to cleanup particles
			return
		end

		--get enemies in line forward from gyro, width lineDetectionRadius and length lineDetectionRadius
		local endPoint = (caster:GetForwardVector() * maxRadius) + caster:GetAbsOrigin()
		--local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), endPoint, caster, lineDetectionRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
		local enemy = FindCloestUnitInALine( caster, caster:GetAbsOrigin(), endPoint, lineDetectionRadius)

		--DebugDrawLine_vCol(caster:GetAbsOrigin(), endPoint , Vector(255,0,0), true, timerDelay)

		if create_arrow == true then
			create_arrow = false

			local particle_arrow = "particles/custom/sirix_mouse/range_finder_cone.vpcf"
			self.particle_arrow = ParticleManager:CreateParticle(particle_arrow, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(self.particle_arrow , 0, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.particle_arrow , 3, Vector(50,50,0)) -- line width
			ParticleManager:SetParticleControl(self.particle_arrow , 4, Vector(255,0,0)) -- colour
		else
			self.distance = self:GetCaster():GetForwardVector() * 300
			ParticleManager:SetParticleControl(self.particle_arrow , 1, self:GetCaster():GetAbsOrigin()) -- origin
			ParticleManager:SetParticleControl(self.particle_arrow , 2, self:GetCaster():GetAbsOrigin() + self.distance)
		end

		--TODO/POSSIBLE BUG: Find out if unitsInLine is closest first. Otherwise impl SortUnitByDistance(enemies)
		if enemy ~= nil then
			_G.WhirlwindTargets[#_G.WhirlwindTargets +1] = enemy:GetAbsOrigin()
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

	--[[ 	---------------------------------------------

		push fire balls out

	]] 		--------------------------------------------------

	--after rotating/fireball phase then do gust/whirlwind phase
	local maxTicks = (gust_duration / timerDelay )
	local fireMoveDistPerTick = fire_movespeed * timerDelay

 	local macropyreParticleName =  "particles/gyrocopter/fire_patch_b.vpcf" --"particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_line_flames.vpcf"
	local macropyreParticles = {}
	local macropyreTickCount = 0

	-- start a timer but don't progress/execute anything until rotationComplete
	-- each tick: rotate gyro. push macropyre away, burning any enemies hit
	Timers:CreateTimer(function()
		if not rotationComplete then
			return timerDelay
		end

		if self.particle_arrow then
			timerDelay = 0.03
			ParticleManager:DestroyParticle(self.particle_arrow, true)
		end

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
			for i, _ in pairs(macropyreParticles) do
				ParticleManager:DestroyParticle(macropyreParticles[i], true)
			end
			return false
		end

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
			end

			--DebugDrawLine_vCol(fireLoc.StartLocation, fireLoc.EndLocation , Vector(255,0,0), true, 1)

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
end
