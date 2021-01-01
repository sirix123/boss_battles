smart_homing_missile = class({})

--Smart homing missiles follow the players, 
	-- also changing target if they find a closer target

--BUG: self is not unique... each time I cast this spell self is identical to the previous cast and subsequent cast...
function smart_homing_missile:OnSpellStart()
	print("smart_homing_missile:OnSpellStart(). Level "..self:GetLevel())
	print("self = ", self)

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

	--Create different speed and dmg rockets based on level
	-- InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	--FYI dumb missile uses: self:InitialiseRocket(5, 0.25, 50, 400, 400)

	--find self in _G.ActiveHomingMissiles and get the index
	local rocketIndex = nil
	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				rocketIndex = i
			end
		end
	end


	local updateTargetInterval = 1
	if self:GetLevel() == 1 then
		self:InitialiseRocket(rocketIndex, 10, 0.1, 50, 300, 300)
	end
	if self:GetLevel() == 2 then
		updateTargetInterval = 0.5
		self:InitialiseRocket(rocketIndex, 10, 0.2, 50, 300, 300)
	end
	if self:GetLevel() > 2 then
		updateTargetInterval = 0.25
		self:InitialiseRocket(rocketIndex, 10, 0.3, 50, 300, 300)
	end
	
	--Rocket Pulses and updates location every x seconds
	Timers:CreateTimer(function()
		--stop the timer on any of these conditions	
		if _G.ActiveHomingMissiles[rocketIndex] == nil then return end
		if _G.ActiveHomingMissiles[rocketIndex].Rocket ~= self then return end
		if _G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil then return end
		--otherwise do RadarPulse to update enemies location / rocket's target
		self:RocketRadarPulse(rocketIndex)
		return updateTargetInterval
	end)


end

function smart_homing_missile:Detonate(missile, aoeRadius, damage)
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

function smart_homing_missile:InitialiseRocket(rocketIndex, velocity, acceleration, detonationRadius, aoeRadius, damage )
	local tracking_interval = 0.1
	--local tracking_interval = 0.3
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
	missile:SetModelScale(0.8)
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

			--if another unit collides with the rocket then detonate. otherwise continue on path.
			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, rocket.location, nil, detonationRadius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
			if (#enemies > 0) then
				self:Detonate(missile, aoeRadius, damage)
				return
			end

			-- Check how close rocket is to the target
			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()
			--ROCKET NEAR TARGET: play a sound, give the rocket a last second speed boost
			if distance < detonationRadius * 2.5 then
				--UNTESTED:  doesn't seem to do what I expect...
				--tilt rockets nose 25 degrees down, so he aiming at the ground
				--missile:SetAngles(0,25,0)

				rocket.velocity = rocket.velocity + 10 
    			--TODO: find a sound effect to use, the rocket is about to blowup, maybe a fizzle? maybe techies mine warning?
				EmitSoundOn( "techies_tech_mineblowsup_01", self:GetCaster() )

			end
			--ROCKET "HIT"(near enough to be considered collision) TARGET:
    		if ( distance < detonationRadius  ) then
    			self:Detonate(missile, aoeRadius, damage)
    			return 
    		end	

    		-- If the rocket's target has been updated then update it's trajectory
    		if _G.ActiveHomingMissiles[rocketIndex] ~= nil then
    			if _G.ActiveHomingMissiles[rocketIndex].Updated then
					rocket.target_lastKnownLocation = shallowcopy(_G.ActiveHomingMissiles[rocketIndex].Location)
					vec_distance = rocket.target_lastKnownLocation - rocket.location
		    		distance = (vec_distance):Length2D()
		    		rocket.direction = (vec_distance):Normalized()
    				_G.ActiveHomingMissiles[rocketIndex].Updated = false
    			else
    				--print("nothing updated. continue on trajectory")
    			end
    		end
    		return tracking_interval;
	end)
end


function smart_homing_missile:RocketRadarPulse(rocketIndex)
	local missileUnit = _G.ActiveHomingMissiles[rocketIndex].MissileUnit


	local radius = 100
	local radiusGrowthRate = 100

	local frameDuration = 0.05

	local tickCount = 0
	Timers:CreateTimer(function()

		tickCount = tickCount + 1
		--delay for 4 seconds before starting
		if tickCount == 1 then return 4 end

		--Not sure I need all these checks or just 1...
		--Rocket may have collided/detonated so stop this timer.
		if _G.ActiveHomingMissiles[rocketIndex] == nil or _G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil  then 
			return
		end

		if missileUnit == nil then
			return
		end


		-- print("missileUnit = ")
		-- print(missileUnit)
		--BUG: sometimes errors here, something to do with missileUnit...
		--update model
		local origin = missileUnit:GetAbsOrigin()
		radius = radius + radiusGrowthRate
		
		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) --draw same thing, radius-1, for double thick line/circle edge

		--check for hits. Maybe don't do this every single tick... but every nth to reduce compute
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--Rocket changes target to nearest enemy, once you've found one enemy update the rocket and return.
		if #enemies > 0 then
			local enemy = enemies[1]
			_G.ActiveHomingMissiles[rocketIndex].Enemy = enemy
			_G.ActiveHomingMissiles[rocketIndex].Location = Vector(enemy:GetAbsOrigin().x, enemy:GetAbsOrigin().y, enemy:GetAbsOrigin().z)	
			_G.ActiveHomingMissiles[rocketIndex].Updated = true
			return
		end
			
		return frameDuration
	end)
end