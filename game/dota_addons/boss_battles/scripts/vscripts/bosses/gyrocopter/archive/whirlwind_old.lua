-- whirlwind = class({})


-- --gyro rotates, either 
-- function whirlwind:OnSpellStart()
-- 	_G.WhirlwindFires = {}
-- 	_G.WhirlwindPhaseTwoStarted = false
-- 	_G.IsGyroBusy = true
-- 	-- check _G.rotating_flak_cannon_direction for clockwise or counterclockwise

-- 	--TODO: put this in txt file and implement both versions. 
-- 	if _G.rotating_flak_cannon_direction == "clockwise" then
-- 		--clockwise = yawAcceleration = yawAcceleration + yawIncrement
-- 		--but need to change the yawLastDetectionThreshold method too
-- 	end
-- 	if _G.rotating_flak_cannon_direction == "counterclockwise" then

-- 	end

-- 	local caster = self:GetCaster()

-- 	--local duration = 10

-- 	local timerDelay = 0.15

-- 	local yawAcceleration = 3 -- this is how many degrees gyro rotates per tick
-- 	local yawIncrement = 0.1
-- 	local initialYaw = caster:GetAnglesAsVector().y

-- 	local length = 2000

	

-- 	local lineDetectionRadius = 120
-- 	Timers:CreateTimer(function()
-- 		--end condition: stop after 1 full rotation
-- 		if caster:GetAnglesAsVector().y > (initialYaw + 360) then
-- 			startPhaseTwo = true
-- 			return
-- 		end

-- 		local endPoint = (caster:GetForwardVector() * length) + caster:GetAbsOrigin()

-- 		--check if unit in line from forward vector to length
-- 		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), endPoint, caster, lineDetectionRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
-- 		DebugDrawLine_vCol(caster:GetAbsOrigin(), endPoint , Vector(255,0,0), true, timerDelay)

-- 		--If an enemy is detected, slow the rotation down and shoot at their location
-- 		if #enemies > 0 then
-- 			-- add the enemy's location to the target list
-- 			_G.WhirlwindTargets[#_G.WhirlwindTargets +1] = enemies[1]:GetAbsOrigin()
-- 			_G.WhirlwindFires[#_G.WhirlwindFires+1].StartLocation = enemies[1]:GetAbsOrigin()
-- 		--no enemy to target, add a target on the ground:
-- 		else
-- 			_G.WhirlwindTargets[#_G.WhirlwindTargets +1] = caster:GetAbsOrigin() + ( caster:GetForwardVector() * 550 )
-- 			_G.WhirlwindFires[#_G.WhirlwindFires+1].StartLocation = caster:GetAbsOrigin() + ( caster:GetForwardVector() * 550 )
-- 		end

-- 		ExecuteOrderFromTable({
-- 			UnitIndex = caster:entindex(),
-- 			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
-- 			AbilityIndex = caster:FindAbilityByName("whirlwind_attack"):entindex(),
-- 			Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
-- 		})

-- 		--rotate gyro
-- 		caster:SetAngles(caster:GetAnglesAsVector().x, caster:GetAnglesAsVector().y + yawAcceleration, 0)
		
-- 		return timerDelay
-- 	end)


-- 	-- PHASE 2. three timers. one for rotate, one for fly upward, one for pushing fire outwards
-- 	-- rotate faster 
-- 	Timers:CreateTimer(function()
-- 		if not startPhaseTwo then 
-- 			return timerDelay
-- 		end
-- 		yawAcceleration = yawAcceleration + yawIncrement
-- 		caster:SetAngles(caster:GetAnglesAsVector().x, caster:GetAnglesAsVector().y + yawAcceleration, 0)
-- 	end)

-- 	-- fly upwards
-- 	local flyUpAltitude = 450
-- 	Timers:CreateTimer(function()
-- 		if not startPhaseTwo then 
-- 			return timerDelay
-- 		end

-- 		local zIncrement = 20
-- 		Timers:CreateTimer(function()
-- 			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,zIncrement))
-- 			-- stop once reaching altitude
-- 			if caster:GetAbsOrigin().z >= flyUpAltitude then return end 
-- 			return timerDelay
-- 		end)
-- 	end)

-- 	-- control fire, push it outwards.
-- 	local fireLines = {}
-- 	local fireLineParticleName = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_line_flames.vpcf"

	

-- 	-- create macropyre particle
-- 	local macropyreParticles = {}
-- 	Timers:CreateTimer(function()
-- 		if not startPhaseTwo then 
-- 			return timerDelay
-- 		end

-- 		for i, wwFire in pairs(_G.WhirlwindFires) do
-- 			-- create a macropyre at _G.WhirlwindFires[i]
-- 			-- macropyreParticles[i] = ParticleManager:CreateParticle(fireLineParticleName, PATTACH_WORLDORIGIN, nil)
-- 			-- ParticleManager:SetParticleControl(macropyreParticles[i] , 0, wwFire.StartLocation)
-- 			-- ParticleManager:SetParticleControl(macropyreParticles[i] , 1, wwFire.StartLocation)
-- 		end

-- 	end)

-- 	--update macropyre particle
-- 	Timers:CreateTimer(function()
-- 		if not startPhaseTwo then 
-- 			return timerDelay
-- 		end


-- 		--foreach fire in _G.WhirlwindFires
-- 		for i, wwFire in pairs(_G.WhirlwindFires) do
-- 			--TODO; update the model (use gyros location and fire location to get direction, then increment along direction)
-- 			-- print(i.." wwFire = ", wwFire)
-- 			-- print(i.." wwFire.StartLocation = ", wwFire.StartLocation)

-- 			local direction = (wwFire.StartLocation - caster:GetAbsOrigin()):Normalized()
-- 			_G.WhirlwindFires[i].Direction = direction

-- 			local newFireLoc = wwFire.StartLocation + (direction * 5)
-- 			--print(i.." updated fireLoc = ", wwFire)

-- 			_G.WhirlwindFires[i].EndLocation = newFireLoc

-- 			--update projectile... can't update projectile so create a new particle
-- 			-- local projectile =  _G.WhirlwindProjectiles[i] 
-- 			-- print(i.. "projectile = ", projectile)

-- 		end
-- 		yawAcceleration = yawAcceleration + yawIncrement
-- 		caster:SetAngles(caster:GetAnglesAsVector().x, caster:GetAnglesAsVector().y + yawAcceleration, 0)
-- 		return timerDelay
-- 	end)
-- end
