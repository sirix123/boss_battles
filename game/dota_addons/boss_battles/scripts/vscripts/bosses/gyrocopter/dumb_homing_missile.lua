dumb_homing_missile = class({})

--Dumb homing missiles don't follow the players location, they move towards the players last known location
function dumb_homing_missile:OnSpellStart()
	--print("dumb_homing_missile:OnSpellStart(). Level "..self:GetLevel())
	
	if #_G.HomingMissileTargets == 0 then 
		--print("dumb_homing_missile:OnSpellStart() called but no targets found in _G.HomingMissileTargets. Unable to proceed.")
		return
	end
	
	--grab target from: _G.HomingMissileTargets
	self.target = _G.HomingMissileTargets[1]
	--remove [1] and reorder the list
	for i = 1, #_G.HomingMissileTargets, 1 do 
		if _G.HomingMissileTargets[i+1] ~= nil then 
			_G.HomingMissileTargets[i] = _G.HomingMissileTargets[i+1]
		else
			_G.HomingMissileTargets[i] = nil
		end
	end		

	--Add an entry to _G.ActiveHomingMissiles
	_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles+1] = {}
	_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Rocket = self
	_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Enemy = self.target
	_G.ActiveHomingMissiles[#_G.ActiveHomingMissiles].Location = shallowcopy(self.target:GetAbsOrigin())	

	--Create different speed and dmg rockets based on level
	-- InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	--self:InitialiseRocket(5, 0.25, 50, 400, 400)

	if self:GetLevel() == 1 then
		self:InitialiseRocket(5, 0.01, 90, 300, 300)
	end
	if self:GetLevel() == 2 then
		self:InitialiseRocket(10, 0.02, 90, 350, 350)
	end
	if self:GetLevel() > 2 then
		self:InitialiseRocket(15, 0.02, 90, 400, 400)
	end

end

function dumb_homing_missile:Detonate(missile, aoeRadius, damage)
	--print("dumb_homing_missile:Detonate()")
	--DEBUG draw, replace with explosion particle
	DebugDrawCircle(missile:GetAbsOrigin(), Vector(255,0,0), 128, aoeRadius, true, 0.5)
	--TODO: particle. explosion particle

	--find any enmies nearby and apply damage
	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missile:GetAbsOrigin(), nil, aoeRadius,
	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	for _,enemy in pairs(enemies) do 
		local enemyDistance = (enemy:GetAbsOrigin() - missile:GetAbsOrigin()):Length2D()
		local damageInfo = 
		{
			victim = enemy,
			attacker = self:GetCaster(),
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
	UTIL_Remove(missile)

	-- Loop through ActiveHomingMissiles and find self then remove it from ActiveHomingMissiles
	for i = 1, #_G.ActiveHomingMissiles, 1 do
		if _G.ActiveHomingMissiles[i].Rocket == self then --and enemy is match to target? 
			_G.ActiveHomingMissiles[i] = nil 
		end
	end
end

function dumb_homing_missile:InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	--print("dumb_homing_missile:InitialiseRocket()")
	local tracking_interval = 0.1
	-- Calculate direction of the rocket, using target position and caster position. 
    local vec_distance = self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    local distance = (vec_distance):Length2D()
    local direction = (vec_distance):Normalized()

	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())
	-- The spell/ability model:
    local rocket = {
    	velocity = velocity,
    	location = self:GetCaster():GetAbsOrigin(),
    	target = self.target,
    	target_lastKnownLocation = targetLocationCopy,
    	direction = direction,
    }

    -- Create a unit to represent the spell/ability
    local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    --dumb_homing_missile is big. Bigger than smart_homing_missile
    missile:SetModelScale(1.4)
    missile:SetOwner(self:GetCaster())

	-- Add the missile unit created to the entry in _G.ActiveHomingMissiles for this rocket.
	if #_G.ActiveHomingMissiles > 0 then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				_G.ActiveHomingMissiles[i].MissileUnit = missile
			end
		end
	end

    local tickCount = 0
    Timers:CreateTimer(function()     		
    		tickCount = tickCount +1
			--DEBUG DRAW:
			DebugDrawCircle(rocket.target_lastKnownLocation, Vector(255,0,0), 128, 10, true, tracking_interval)
			-- Delay 3 seconds for the 'prepare' animation the missile does
			local waitAmount = 3.2 / tracking_interval  
			if tickCount < waitAmount then
				return tracking_interval;  --do nothing until the missile animation is ready to be moved.
			end				
			
			--update model
			rocket.velocity = rocket.velocity + acceleration
			rocket.location = rocket.location + rocket.direction * rocket.velocity
			--update rocket/missile unit itself
			missile:SetAbsOrigin(rocket.location)			
			missile:SetForwardVector(rocket.direction)

			--if a unit collides with the rocket, then detonate.
			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, rocket.location, nil, detonationRadius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
			if (#enemies > 0) then
				self:Detonate(missile, aoeRadius, damage)
				return
			end

			-- Check how close rocket is to the target
			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()
			--ROCKET NEAR TARGET: play a sound, give the rocket a last second speed boost
			if distance < detonationRadius * 3 then
				--UNTESTED: 
				--tilt rockets nose 25 degrees down, so he aiming at the ground
				missile:SetAngles(25,0,0)

				rocket.velocity = rocket.velocity + 10 
    			--TODO: find a sound effect to use, the rocket is about to blowup, maybe a fizzle? maybe techies mine warning?
				EmitSoundOn( "techies_tech_mineblowsup_01", self:GetCaster() )

			end
			--ROCKET "HIT"(near enough to be considered collision) TARGET:
    		if ( distance < detonationRadius  ) then
    			self:Detonate(missile, aoeRadius, damage)
    			return 
    		end			


    		--Need to rethink this... for dumb homing missiles. do they ever change target/path?

			--only update the rocket's tracking info if an enemy has been scanned, otherwise continue on current course/direction
			-- if #_G.ActiveHomingMissiles > 0 then
			-- 	--update the rockets target if there is a 'new' scan of this particular enemy
			-- 	for i = 1, #_G.ActiveHomingMissiles, 1 do
			-- 		if _G.ActiveHomingMissiles[i].Enemy == rocket.target then
			-- 			if _G.ActiveHomingMissiles[i].Location == rocket.target_lastKnownLocation then --do nothing if the location is the same as last time
			-- 			else 
			-- 				-- New RadarScan occured and has updated this targets location, update the rockets target and direction
			-- 				rocket.target_lastKnownLocation = shallowcopy(_G.ActiveHomingMissiles[i].Location)
			-- 				vec_distance = rocket.target_lastKnownLocation - rocket.location
			-- 	    		distance = (vec_distance):Length2D()
			-- 	    		rocket.direction = (vec_distance):Normalized()
			-- 			end
			-- 		end
			-- 	end
			-- 	else
			-- end


    		return tracking_interval;
	end)
end