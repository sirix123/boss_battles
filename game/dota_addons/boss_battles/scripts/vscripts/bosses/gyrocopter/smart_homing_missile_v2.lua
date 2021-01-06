smart_homing_missile_v2 = class({})

--Smart homing missiles follow the players, 
	-- also changing target if they find a closer target


--New version, Attempt 4/5ish. Appears to be working for single player.
function smart_homing_missile_v2:OnSpellStart()
	--print("smart_homing_missile_v2:OnSpellStart()")
	if #_G.HomingMissileTargets == 0 then 
		return
	end
	self.caster = self:GetCaster()

	local hasMissileDetonated = false

	--grab target from: _G.HomingMissileTargets
	local target = _G.HomingMissileTargets[1]
	--remove [1] and reorder the list
	for i = 1, #_G.HomingMissileTargets, 1 do 
		if _G.HomingMissileTargets[i+1] ~= nil then 
			_G.HomingMissileTargets[i] = _G.HomingMissileTargets[i+1]
		else
			_G.HomingMissileTargets[i] = nil
		end
	end		


	--TEST: todo find out that the level of these vars is working...
	local velocity = self:GetSpecialValueFor("velocity")
	local acceleration = self:GetSpecialValueFor("acceleration")
	local damage = self:GetSpecialValueFor("damage")
	local aoeRadius = self:GetSpecialValueFor("aoe_radius")
	local detonationRadius = self:GetSpecialValueFor("detonation_radius")

	local updateInterval = self:GetSpecialValueFor("update_interval")


    -- Create a unit to represent the spell/ability
    local missileUnit = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	missileUnit:SetModelScale(0.8)
	missileUnit:SetOwner(self:GetCaster())

	--Rocket pulses and updates location every updateInterval seconds.
	--Rocket changes target to nearest enemy
	Timers:CreateTimer(4, function() -- wait 4 seconds before starting, allowing rocket to 'arm'
		if hasMissileDetonated then return end
		-- print("timer tick. updating location.")
		-- print("missileUnit = ")
		-- print(missileUnit)
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, 4000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #enemies > 0 then
			target = enemies[1]
		end
		return updateInterval
    end)


	-- Calculate direction of the rocket, using target position and caster position. 
	-- And check if it's hit a player or arrived at it's location
    local targetLastKnownLocation = shallowcopy(target:GetAbsOrigin())
    local dt = 0.1
    Timers:CreateTimer(3.2, function() -- wait 3.2 seconds before starting, allowing rocket to arm
    	if hasMissileDetonated then return end
	    local vec_distance = target:GetAbsOrigin() - missileUnit:GetAbsOrigin()
	    local distance = (vec_distance):Length2D()
	    local direction = (vec_distance):Normalized()

		--update model
		velocity = velocity + acceleration
		local location = missileUnit:GetAbsOrigin() + direction * velocity
		--update rocket/missile unit itself
		missileUnit:SetAbsOrigin(location)			
		missileUnit:SetForwardVector(direction)


		--if a unit collides with the rocket then detonate. otherwise continue on path.
		-- or 
		----ROCKET "HIT"(near enough to be considered collision) TARGET:
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, detonationRadius,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if ( (#enemies > 0) or (distance < detonationRadius) ) then
			for _,enemy in pairs(enemies) do 
				local enemyDistance = (enemy:GetAbsOrigin() - missileUnit:GetAbsOrigin()):Length2D()
				local damageInfo = 
				{
					victim = enemy,
					attacker = self.caster,
					damage = damage - enemyDistance, --TODO: calculate the dmg properly based on duration/distance.
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = self,
				}
				ApplyDamage(damageInfo)
				--Particle effect on enemy hit by rocket.
				--temp placeholder particle
				local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, self.target )
			end
			--destroy the missile
			UTIL_Remove(missileUnit)			
			local hasMissileDetonated = true
			return
		end
    	return dt
	end)
end


-- function smart_homing_missile_v2:Detonate(aoeRadius, damage)
-- 	--DEBUG draw, replace with explosion particle
-- 	DebugDrawCircle(self.missileUnit:GetAbsOrigin(), Vector(255,0,0), 128, aoeRadius, true, 0.5)
-- 	--TODO: particle. explosion particle

-- 	--find any enmies nearby and apply damage
-- 	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self.missileUnit:GetAbsOrigin(), nil, aoeRadius,
-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 	for _,enemy in pairs(enemies) do 
-- 		local enemyDistance = (enemy:GetAbsOrigin() - self.missileUnit:GetAbsOrigin()):Length2D()
-- 		local damageInfo = 
-- 		{
-- 			victim = enemy,
-- 			attacker = self.caster,
-- 			damage = damage - enemyDistance, --TODO: calculate the dmg properly based on duration/distance.
-- 			damage_type = DAMAGE_TYPE_PHYSICAL,
-- 			ability = self,
-- 		}
-- 		ApplyDamage(damageInfo)
-- 		--Particle effect on enemy hit by rocket.
-- 		--temp placeholder particle
-- 		local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, self.target )
-- 	end
-- 	--destroy the missile
-- 	UTIL_Remove(self.missileUnit)
-- 	--TODO: CONFIRM is self.missileUnit null?
-- 	print("self.missileUnit = ", self.missileUnit)
-- end

-- function smart_homing_missile_v2:InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage )
-- 	local tracking_interval = 0.1
-- 	--local tracking_interval = 0.3
-- 	-- Calculate direction of the rocket, using target position and caster position. 
--     local vec_distance = self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
--     local distance = (vec_distance):Length2D()
--     local direction = (vec_distance):Normalized()

-- 	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())
-- 	-- The spell/ability model:
--     local rocket = {
--     	velocity = velocity,
--     	location = self:GetCaster():GetAbsOrigin(),
--     	target = self.target,
--     	target_lastKnownLocation = targetLocationCopy,
--     	direction = direction,
--     }

--     -- Create a unit to represent the spell/ability
--     self.missileUnit = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
-- 	self.missileUnit:SetModelScale(0.8)
-- 	self.missileUnit:SetOwner(self:GetCaster())

--     local tickCount = 0
--     Timers:CreateTimer(function()
--     		tickCount = tickCount +1
-- 			--DEBUG DRAW:
-- 			DebugDrawCircle(rocket.target_lastKnownLocation, Vector(255,0,0), 128, 10, true, tracking_interval)
-- 			-- Delay 3 seconds for the 'prepare' animation the missile does
-- 			local waitAmount = 3.2 / tracking_interval  
-- 			if tickCount < waitAmount then
-- 				return tracking_interval;  --do nothing until the missile animation is ready to be moved.
-- 			end				
			
-- 			--update model
-- 			rocket.velocity = rocket.velocity + acceleration
-- 			rocket.location = rocket.location + rocket.direction * rocket.velocity
-- 			--update rocket/missile unit itself
-- 			self.missileUnit:SetAbsOrigin(rocket.location)			
-- 			self.missileUnit:SetForwardVector(rocket.direction)

-- 			--if another unit collides with the rocket then detonate. otherwise continue on path.
-- 			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, rocket.location, nil, detonationRadius,
-- 			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 			if (#enemies > 0) then
-- 				self:Detonate(aoeRadius, damage)
-- 				return
-- 			end

-- 			-- Check how close rocket is to the target
-- 			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()
-- 			--ROCKET NEAR TARGET: play a sound, give the rocket a last second speed boost
-- 			if distance < detonationRadius * 2.5 then
-- 				--UNTESTED:  doesn't seem to do what I expect...
-- 				--tilt rockets nose 25 degrees down, so he aiming at the ground
-- 				--missile:SetAngles(0,25,0)

-- 				rocket.velocity = rocket.velocity + 10 
--     			--TODO: find a sound effect to use, the rocket is about to blowup, maybe a fizzle? maybe techies mine warning?
-- 				EmitSoundOn( "techies_tech_mineblowsup_01", self:GetCaster() )

-- 			end
-- 			--ROCKET "HIT"(near enough to be considered collision) TARGET:
--     		if ( distance < detonationRadius  ) then
--     			self:Detonate(aoeRadius, damage)
--     			return 
--     		end	

--     		-- If the rocket's target has been updated then update it's trajectory
-- 			if self.updated then
-- 				rocket.target_lastKnownLocation = shallowcopy(self.target:GetAbsOrigin())


-- 				vec_distance = rocket.target_lastKnownLocation - rocket.location
-- 	    		distance = (vec_distance):Length2D()
-- 	    		rocket.direction = (vec_distance):Normalized()
-- 			end
--     		return tracking_interval;
-- 	end)
-- end


-- function smart_homing_missile_v2:RocketRadarPulse()

-- 	local radius = 100
-- 	local radiusGrowthRate = 100
-- 	local frameDuration = 0.05

-- 	local tickCount = 0
-- 	Timers:CreateTimer(function()
-- 		tickCount = tickCount + 1
-- 		--delay for 4 seconds before starting
-- 		if tickCount == 1 then return 4 end
-- 		if self.missileUnit == nil then
-- 			return
-- 		end

-- 		--update model
-- 		local origin = self.missileUnit:GetAbsOrigin()
-- 		radius = radius + radiusGrowthRate
		
-- 		--draw 
-- 		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) 

-- 		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self.missileUnit:GetAbsOrigin(), nil, radius,
-- 		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 		--Rocket changes target to nearest enemy, once you've found one enemy update the rocket and return.
-- 		if #enemies > 0 then
-- 			self.updated = true
-- 			self.target = enemies[1]
-- 			return
-- 		end
-- 		return frameDuration
-- 	end)
-- end


-- smart_homing_missile_v2 = class({})

-- --Smart homing missiles follow the players, 
-- 	-- also changing target if they find a closer target



-- function smart_homing_missile_v2:OnSpellStart()
-- 	local localTarget = nil

-- 	print("smart_homing_missile_v2:OnSpellStart()")
-- 	if #_G.HomingMissileTargets == 0 then 
-- 		return
-- 	end

-- 	print("havent assigned self.target yet. but...")
-- 	print("self.target = ", self.target)

-- 	print("pre assign localTarget = ", localTarget)
-- 	localTarget = _G.HomingMissileTargets[1]
-- 	print("post assign localTarget = ", localTarget)

-- 	self.caster = self:GetCaster()
-- 	--grab target from: _G.HomingMissileTargets
-- 	self.target = _G.HomingMissileTargets[1]

-- 	print("after assigning it:")
-- 	print("self.target = ", self.target)

-- 	--remove [1] and reorder the list
-- 	for i = 1, #_G.HomingMissileTargets, 1 do 
-- 		if _G.HomingMissileTargets[i+1] ~= nil then 
-- 			_G.HomingMissileTargets[i] = _G.HomingMissileTargets[i+1]
-- 		else
-- 			_G.HomingMissileTargets[i] = nil
-- 		end
-- 	end		


-- 	local updateTargetInterval = 1
-- 	if self:GetLevel() == 1 then
-- 		self:InitialiseRocket(10, 0.1, 50, 300, 300)
-- 	end
-- 	if self:GetLevel() == 2 then
-- 		updateTargetInterval = 0.5
-- 		self:InitialiseRocket(10, 0.2, 50, 300, 300)
-- 	end
-- 	if self:GetLevel() > 2 then
-- 		updateTargetInterval = 0.25
-- 		self:InitialiseRocket(10, 0.3, 50, 300, 300)
-- 	end

-- 	--Rocket Pulses and updates location every x seconds
-- 	Timers:CreateTimer(function()
-- 		if self.missileUnit == nil then return end
-- 		--otherwise do RadarPulse to update enemies location / rocket's target
-- 		self:RocketRadarPulse()
-- 		return updateTargetInterval
-- 	end)

-- end


-- function smart_homing_missile_v2:Detonate(aoeRadius, damage)
-- 	--DEBUG draw, replace with explosion particle
-- 	DebugDrawCircle(self.missileUnit:GetAbsOrigin(), Vector(255,0,0), 128, aoeRadius, true, 0.5)
-- 	--TODO: particle. explosion particle

-- 	--find any enmies nearby and apply damage
-- 	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self.missileUnit:GetAbsOrigin(), nil, aoeRadius,
-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 	for _,enemy in pairs(enemies) do 
-- 		local enemyDistance = (enemy:GetAbsOrigin() - self.missileUnit:GetAbsOrigin()):Length2D()
-- 		local damageInfo = 
-- 		{
-- 			victim = enemy,
-- 			attacker = self.caster,
-- 			damage = damage - enemyDistance, --TODO: calculate the dmg properly based on duration/distance.
-- 			damage_type = DAMAGE_TYPE_PHYSICAL,
-- 			ability = self,
-- 		}
-- 		ApplyDamage(damageInfo)
-- 		--Particle effect on enemy hit by rocket.
-- 		--temp placeholder particle
-- 		local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, self.target )
-- 	end
-- 	--destroy the missile
-- 	UTIL_Remove(self.missileUnit)
-- 	--TODO: CONFIRM is self.missileUnit null?
-- 	print("self.missileUnit = ", self.missileUnit)
-- end

-- function smart_homing_missile_v2:InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage )
-- 	local tracking_interval = 0.1
-- 	--local tracking_interval = 0.3
-- 	-- Calculate direction of the rocket, using target position and caster position. 
--     local vec_distance = self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
--     local distance = (vec_distance):Length2D()
--     local direction = (vec_distance):Normalized()

-- 	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())
-- 	-- The spell/ability model:
--     local rocket = {
--     	velocity = velocity,
--     	location = self:GetCaster():GetAbsOrigin(),
--     	target = self.target,
--     	target_lastKnownLocation = targetLocationCopy,
--     	direction = direction,
--     }

--     -- Create a unit to represent the spell/ability
--     self.missileUnit = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
-- 	self.missileUnit:SetModelScale(0.8)
-- 	self.missileUnit:SetOwner(self:GetCaster())

--     local tickCount = 0
--     Timers:CreateTimer(function()
--     		tickCount = tickCount +1
-- 			--DEBUG DRAW:
-- 			DebugDrawCircle(rocket.target_lastKnownLocation, Vector(255,0,0), 128, 10, true, tracking_interval)
-- 			-- Delay 3 seconds for the 'prepare' animation the missile does
-- 			local waitAmount = 3.2 / tracking_interval  
-- 			if tickCount < waitAmount then
-- 				return tracking_interval;  --do nothing until the missile animation is ready to be moved.
-- 			end				
			
-- 			--update model
-- 			rocket.velocity = rocket.velocity + acceleration
-- 			rocket.location = rocket.location + rocket.direction * rocket.velocity
-- 			--update rocket/missile unit itself
-- 			self.missileUnit:SetAbsOrigin(rocket.location)			
-- 			self.missileUnit:SetForwardVector(rocket.direction)

-- 			--if another unit collides with the rocket then detonate. otherwise continue on path.
-- 			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, rocket.location, nil, detonationRadius,
-- 			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 			if (#enemies > 0) then
-- 				self:Detonate(aoeRadius, damage)
-- 				return
-- 			end

-- 			-- Check how close rocket is to the target
-- 			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()
-- 			--ROCKET NEAR TARGET: play a sound, give the rocket a last second speed boost
-- 			if distance < detonationRadius * 2.5 then
-- 				--UNTESTED:  doesn't seem to do what I expect...
-- 				--tilt rockets nose 25 degrees down, so he aiming at the ground
-- 				--missile:SetAngles(0,25,0)

-- 				rocket.velocity = rocket.velocity + 10 
--     			--TODO: find a sound effect to use, the rocket is about to blowup, maybe a fizzle? maybe techies mine warning?
-- 				EmitSoundOn( "techies_tech_mineblowsup_01", self:GetCaster() )

-- 			end
-- 			--ROCKET "HIT"(near enough to be considered collision) TARGET:
--     		if ( distance < detonationRadius  ) then
--     			self:Detonate(aoeRadius, damage)
--     			return 
--     		end	

--     		-- If the rocket's target has been updated then update it's trajectory
-- 			if self.updated then
-- 				rocket.target_lastKnownLocation = shallowcopy(self.target:GetAbsOrigin())


-- 				vec_distance = rocket.target_lastKnownLocation - rocket.location
-- 	    		distance = (vec_distance):Length2D()
-- 	    		rocket.direction = (vec_distance):Normalized()
-- 			end
--     		return tracking_interval;
-- 	end)
-- end


-- function smart_homing_missile_v2:RocketRadarPulse()

-- 	local radius = 100
-- 	local radiusGrowthRate = 100
-- 	local frameDuration = 0.05

-- 	local tickCount = 0
-- 	Timers:CreateTimer(function()
-- 		tickCount = tickCount + 1
-- 		--delay for 4 seconds before starting
-- 		if tickCount == 1 then return 4 end
-- 		if self.missileUnit == nil then
-- 			return
-- 		end

-- 		--update model
-- 		local origin = self.missileUnit:GetAbsOrigin()
-- 		radius = radius + radiusGrowthRate
		
-- 		--draw 
-- 		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) 

-- 		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self.missileUnit:GetAbsOrigin(), nil, radius,
-- 		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 		--Rocket changes target to nearest enemy, once you've found one enemy update the rocket and return.
-- 		if #enemies > 0 then
-- 			self.updated = true
-- 			self.target = enemies[1]
-- 			return
-- 		end
-- 		return frameDuration
-- 	end)
-- end