dumb_homing_missile_v2 = class({})

--Dumb homing missiles don't follow the players location, they move towards the players last known location
--New version, Attempt 4/5ish. Appears to be working for single player.
function dumb_homing_missile_v2:OnSpellStart()
	--print("dumb_homing_missile_v2:OnSpellStart()")
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


	local velocity = self:GetSpecialValueFor("velocity")
	local acceleration = self:GetSpecialValueFor("acceleration")
	local damage = self:GetSpecialValueFor("damage")
	local aoeRadius = self:GetSpecialValueFor("aoe_radius")
	local detonationRadius = self:GetSpecialValueFor("detonation_radius")

    -- Create a unit to represent the spell/ability
    local missileUnit = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	missileUnit:SetModelScale(1.4)
	missileUnit:SetOwner(self:GetCaster())


	-- Calculate direction of the rocket, using target position and caster position. 
	-- And check if it's hit a player or arrived at it's location
    local targetLastKnownLocation = shallowcopy(target:GetAbsOrigin())
    local dt = 0.1
    Timers:CreateTimer(3.2, function() -- wait 3.2 seconds before starting, allowing rocket to arm
    	if hasMissileDetonated then return end
	    local vec_distance = targetLastKnownLocation - missileUnit:GetAbsOrigin()
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

--Rocket planning...
--I was using globals... but each rocket is self contained. now...
-- function dumb_homing_missile_v2:OnSpellStart()
-- 	print("dumb_homing_missile_v2:OnSpellStart()")
-- 	if #_G.HomingMissileTargets == 0 then 
-- 		return
-- 	end
-- 	self.caster = self:GetCaster()
-- 	--grab target from: _G.HomingMissileTargets
-- 	self.target = _G.HomingMissileTargets[1]
-- 	--remove [1] and reorder the list
-- 	for i = 1, #_G.HomingMissileTargets, 1 do 
-- 		if _G.HomingMissileTargets[i+1] ~= nil then 
-- 			_G.HomingMissileTargets[i] = _G.HomingMissileTargets[i+1]
-- 		else
-- 			_G.HomingMissileTargets[i] = nil
-- 		end
-- 	end		

-- 	--InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
-- 	if self:GetLevel() == 1 then
-- 		self:InitialiseRocket(5, 0.1, 90, 300, 300)
-- 	end
-- 	if self:GetLevel() == 2 then
-- 		self:InitialiseRocket(10, 0.2, 90, 350, 350)
-- 	end
-- 	if self:GetLevel() > 2 then
-- 		self:InitialiseRocket(15, 0.2, 90, 400, 400)
-- 	end


-- end

-- function dumb_homing_missile_v2:InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
-- 	--print("dumb_homing_missile:InitialiseRocket()")
-- 	local tracking_interval = 0.1
-- 	-- Calculate direction of the rocket, using target position and caster position. 
--     local vec_distance = self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()
--     local distance = (vec_distance):Length2D()
--     local direction = (vec_distance):Normalized()

-- 	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())
-- 	-- The spell/ability model:
--     local rocket = {
--     	velocity = velocity,
--     	location = self.caster:GetAbsOrigin(),
--     	target = self.target,
--     	target_lastKnownLocation = targetLocationCopy,
--     	direction = direction,
--     }

--     -- Create a unit to represent the spell/ability
--     local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self.caster:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber())
--     --dumb_homing_missile is big. Bigger than smart_homing_missile
--     missile:SetModelScale(1.4)
--     missile:SetOwner(self.caster)


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
-- 			missile:SetAbsOrigin(rocket.location)			
-- 			missile:SetForwardVector(rocket.direction)

-- 			--if a unit collides with the rocket, then detonate.
-- 			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, rocket.location, nil, detonationRadius,
-- 			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 			if (#enemies > 0) then
-- 				self:Detonate(missile, aoeRadius, damage)
-- 				return
-- 			end

-- 			-- Check how close rocket is to the target
-- 			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()
-- 			--ROCKET NEAR TARGET: play a sound, give the rocket a last second speed boost
-- 			if distance < detonationRadius * 3 then
-- 				--UNTESTED: 
-- 				--tilt rockets nose 25 degrees down, so he aiming at the ground
-- 				missile:SetAngles(25,0,0)

-- 				rocket.velocity = rocket.velocity + 10 
--     			--TODO: find a sound effect to use, the rocket is about to blowup, maybe a fizzle? maybe techies mine warning?
-- 				EmitSoundOn( "techies_tech_mineblowsup_01", self.caster )

-- 			end
-- 			--ROCKET "HIT"(near enough to be considered collision) TARGET:
--     		if ( distance < detonationRadius  ) then
--     			self:Detonate(missile, aoeRadius, damage)
--     			return 
--     		end			

--     		return tracking_interval;
-- 	end)
-- end


-- function dumb_homing_missile_v2:Detonate(missile, aoeRadius, damage)
-- 	--print("dumb_homing_missile:Detonate()")
-- 	--DEBUG draw, replace with explosion particle
-- 	DebugDrawCircle(missile:GetAbsOrigin(), Vector(255,0,0), 128, aoeRadius, true, 0.5)
-- 	--TODO: particle. explosion particle

-- 	--find any enmies nearby and apply damage
-- 	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missile:GetAbsOrigin(), nil, aoeRadius,
-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
-- 	for _,enemy in pairs(enemies) do 
-- 		local enemyDistance = (enemy:GetAbsOrigin() - missile:GetAbsOrigin()):Length2D()
-- 		local damageInfo = 
-- 		{
-- 			victim = enemy,
-- 			attacker = self:GetCaster(),
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
-- 	UTIL_Remove(missile)
-- end