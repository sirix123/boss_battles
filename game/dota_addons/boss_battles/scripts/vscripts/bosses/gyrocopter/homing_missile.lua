homing_missile = class({})

local displayDebug = true

--Homing missile should always be passed it's target. 
-- The code here will treat the target different for each different lvl of homing missile. 
-- lvl 1, gets target current location and goes there
-- lvl 2, gets target current location and starts going there, then updates target position every 5 sec
-- lvl3, update location/pos/ every sec
-- lvl 4 the rocket has a target but will change it's target if another one comes closer when it checks, every 1 sec

local tracking_interval = 0.1

function homing_missile:OnSpellStart()
	if self:GetCursorTarget() == nil then return end
	-- print("homing_missile:OnSpellStart() called")
	-- print("self:GetLevel() = ", self:GetLevel())

	self.target = self:GetCursorTarget()
	-- print("self.target = ", self.target)
	-- print("self = ", self)

	-- If there is an entry in _G.ActiveHomingMissiles for this target (self.target) then attach this rocket to it.
	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == nil and _G.ActiveHomingMissiles[i].Enemy == self.target then 
				_G.ActiveHomingMissiles[i].Rocket = self
			end
		end
	end

	if self:GetLevel() == 1 then
		self:Rocket1()	--confirm this works
	end
	if self:GetLevel() == 2 then
		self:Rocket2()	--confirm this works
	end
	if self:GetLevel() == 3 then
		self:Rocket3()	--confirm this works
	end
	if self:GetLevel() == 4 then
		self:Rocket4()	--confirm this works
	end

	--TESTING: leveling up the rocket after each cast to test the various lvls
	-- if self:GetLevel() < 4 then
	-- 	self:SetLevel(self:GetLevel() +1)
	-- end

end -- end of homing_missile:OnSpellStart()


function homing_missile:InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	--Calculate direction of the rocket, using target position and caster position. 
    local vec_distance = self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    local distance = (vec_distance):Length2D()
    local direction = (vec_distance):Normalized()

	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())	
    local rocket = {
    	velocity = velocity,
    	location = self:GetCaster():GetAbsOrigin(),
    	target = self.target,
    	target_lastKnownLocation = targetLocationCopy,
    	direction = direction,
    }
    local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    --Adjust size of the rocket based on the level
	if self:GetLevel() == 1 then
		missile:SetModelScale(1)
	end
	if self:GetLevel() == 2 then
		missile:SetModelScale(1.25)
	end
	if self:GetLevel() == 3 then
		missile:SetModelScale(1.5)
	end
	if self:GetLevel() == 4 then
		missile:SetModelScale(1.75)
	end

	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				_G.ActiveHomingMissiles[i].MissileUnit = missile
			end
		end
	end

    local tickCount = 0
    Timers:CreateTimer(function()     		
    		tickCount = tickCount +1
			--need to delay 3 seconds for the 'prepare' animation the missile does
			local waitAmount = 3.2 / tracking_interval  
			if tickCount < waitAmount then
				return tracking_interval;  --do nothing until the missile animation is ready to be moved.
			end				
			
			--update model
			rocket.velocity = rocket.velocity + acceleration
			rocket.location = rocket.location + rocket.direction * rocket.velocity
			missile:SetAbsOrigin(rocket.location)			
			missile:SetForwardVector(rocket.direction)
			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()

			--DEBUG DRAW:
			if displayDebug then
				DebugDrawCircle(rocket.target_lastKnownLocation, Vector(255,0,0), 128, 10, true, tracking_interval)
			end

			--ROCKET NEAR TARGET:
			if distance < detonationRadius * 1.5 then
    			--TODO: find a sound effect to use, the rocket is about to blowup, maybe a fizzle? maybe techies mine warning?
				EmitSoundOn( "techies_tech_mineblowsup_01", self:GetCaster() )
			end
			--ROCKET "HIT"(near enough to be considered collision) TARGET:
    		if ( distance < detonationRadius  ) then
				local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, rocket.location, nil, aoeRadius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
				for _,enemy in pairs(enemies) do 
					local enemyDistance = (enemy:GetAbsOrigin() - rocket.location):Length2D()
					local damageInfo = 
					{
						victim = rocket.target,
						attacker = self:GetCaster(),
						damage = damage - enemyDistance, --TODO: calculate the dmg properly based on duration/distance.
						damage_type = 1, --DAMAGE_TYPE_PHYSICAL = 1, DAMAGE_TYPE_MAGICAL = 2
						ability = self,
					}
					ApplyDamage(damageInfo)

	    			--DEBUG draw, replace with explosion particle
    				DebugDrawCircle(missile:GetAbsOrigin(), Vector(255,0,0), 128, aoeRadius, true, tracking_interval *2)

					--Particle effect on enemy hit by rocket.
					local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, rocket.target )
				end
				--destroy the missile
				UTIL_Remove(missile)

				-- Loop through ActiveHomingMissiles and find self then remove it from ActiveHomingMissiles
				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Rocket == self then --and enemy is match to target? 
						_G.ActiveHomingMissiles[i] = nil 
					end
				end
    			return 
    		end			

			--only update the rocket's tracking info if an enemy has been scanned, otherwise continue on current course/direction
			if #_G.ActiveHomingMissiles > 0 then
				--update the rockets target if there is a 'new' scan of this particular enemy
				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Enemy == rocket.target then
						if _G.ActiveHomingMissiles[i].Location == rocket.target_lastKnownLocation then --do nothing if the location is the same as last time
						else 
							-- New RadarScan occured and has updated this targets location, update the rockets target and direction
							rocket.target_lastKnownLocation = shallowcopy(_G.ActiveHomingMissiles[i].Location)
							vec_distance = rocket.target_lastKnownLocation - rocket.location
				    		distance = (vec_distance):Length2D()
				    		rocket.direction = (vec_distance):Normalized()
						end
					end
				end
				else
			end
    		return tracking_interval;
	end)
end


function homing_missile:Rocket1()
	--print("homing_missile:Rocket1()")
	--InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	self:InitialiseRocket(10, 0.01, 120, 200, 200)
end

function homing_missile:Rocket2()
	-- print("homing_missile:Rocket2()")

	--InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	self:InitialiseRocket(10, 0.02, 120, 250, 250)

end

function homing_missile:Rocket3()
	-- print("homing_missile:Rocket3()")

	--InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	self:InitialiseRocket(10, 0.05, 120, 300, 300)

	--find self in: ActiveHomingMissiles
	local rocketIndex = nil
	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				rocketIndex = i
			end
		end
	end

	--Rocket3 Pulses and updates location every 3 seconds
	local interval = 3
	--how can this timer know when to stop?
		-- maybe check if ActiveHomingMissiles[rocketIndex] ~= nil or ActiveHomingMissiles[rocketIndex].Rocket ~= self then
	Timers:CreateTimer(function()	
		if _G.ActiveHomingMissiles[rocketIndex] == nil then return end
		if _G.ActiveHomingMissiles[rocketIndex].Rocket ~= self then return end
		if _G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil then return end

		Rocket3RadarPulse(rocketIndex)
		return interval
	end)


	--update the enemies location 



end

function homing_missile:Rocket4()
	-- print("homing_missile:Rocket4()")

	--InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage)
	self:InitialiseRocket(10, 0.1, 120, 350, 350)

	--find self in: ActiveHomingMissiles
	local rocketIndex = nil
	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				rocketIndex = i
			end
		end
	end

	local interval = 3
	--how can this timer know when to stop?
	-- maybe check if ActiveHomingMissiles[rocketIndex] ~= nil or ActiveHomingMissiles[rocketIndex].Rocket ~= self then
	Timers:CreateTimer(function()	
		if _G.ActiveHomingMissiles[rocketIndex] == nil then return end
		if _G.ActiveHomingMissiles[rocketIndex].Rocket ~= self then return end
		if _G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil then return end
		
		Rocket4RadarPulse(rocketIndex)
		return interval
	end)

end


function Rocket3RadarPulse(rocketIndex)
	--print("Rocket3RadarPulse")
	local rocketData = _G.ActiveHomingMissiles[rocketIndex]
	
	local target = rocketData.Enemy

	local radius = 100
	local radiusGrowthRate = 25

	local frameDuration = 0.05
	Timers:CreateTimer(function()	
		if _G.ActiveHomingMissiles[rocketIndex] == nil then 
			--print("_G.ActiveHomingMissiles[rocketIndex] == nil. Returning.")
			return
		end
		if _G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil then
			--print("_G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil. Returning.")
			return
		end

		local missileUnit = rocketData.MissileUnit
		--update model
		local origin = missileUnit:GetAbsOrigin()
		radius = radius + radiusGrowthRate

		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) --draw same thing, radius-1, for double thick line/circle edge

		--check for hits. Maybe don't do this every single tick... but every nth to reduce compute
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--Rocket 3 looks for it's current enemy and updates the location of it once detected
		for _,enemy in pairs(enemies) do 
			-- check that enemy matches this rockets target
			if enemy == target then
				rocketData.Location = shallowcopy(enemy:GetAbsOrigin())	
				return
			end
		end
		return frameDuration
	end)
end

function Rocket4RadarPulse(rocketIndex)
	local rocketData = _G.ActiveHomingMissiles[rocketIndex]
	local missileUnit = rocketData.MissileUnit
	local target = rocketData.Enemy

	local radius = 100
	local radiusGrowthRate = 25

	local frameDuration = 0.05
	Timers:CreateTimer(function()	
		if _G.ActiveHomingMissiles[rocketIndex] == nil then 
			--print("_G.ActiveHomingMissiles[rocketIndex] == nil. Returning.")
			return
		end
		if _G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil then
			--print("_G.ActiveHomingMissiles[rocketIndex].MissileUnit == nil. Returning.")
			return
		end
		
		--update model
		local origin = missileUnit:GetAbsOrigin()
		radius = radius + radiusGrowthRate
		
		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) --draw same thing, radius-1, for double thick line/circle edge

		--check for hits. Maybe don't do this every single tick... but every nth to reduce compute
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--Rocket 4 changes target to nearest enemy, once you've found one enemy update the rocket and return.
		for _,enemy in pairs(enemies) do 
			rocketData.Enemy = enemy
			rocketData.Location = shallowcopy(enemy:GetAbsOrigin())	
			return
		end
		return frameDuration
	end)
end



--TODO: easy, just FindEnemiesInRadius, sort by nearest
function homing_missile:FindNearestEnemy()
	--something like:
		local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )
end

-- some function I found on stackoverflow to:
-- pass in a table (orig) and it copys the table by value instead of by reference and returns the copied table
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


