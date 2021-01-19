continuous_radar_scan = class({})

--global var so the enemies detected can be accessed outside of this class
function continuous_radar_scan:OnSpellStart()
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")
	local revolutionDuration = self:GetSpecialValueFor("revolutionDuration")
	local detectionTimeThreshold = self:GetSpecialValueFor("detectionTimeThreshold")
	

	--TODO: not yet used. TODO use!
	--I think I can control this by just doing:
	-- currentAngle = currentAngle +degreesPerFrame
	-- or 
	-- currentAngle = currentAngle -degreesPerFrame

	local direction = self:GetSpecialValueFor("direction")
	-- 1 = clockwise
	if direction == 1 then
		direction = "clockwise"
	end
	-- 2 = counterClockwise
	if direction == 2 then
		direction = "counterClockwise"
	end

	--temporary filler particle
    local particleName = "particles/gyrocopter/red_phoenix_sunray.vpcf"
    local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )	

    --reset global var for new scan
	Clear(_G.ContinuousRadarScanEnemies)
    local enemiesDetected = {}


	local currentFrame = 1
	local totalFrames = 360

	local frameDuration = revolutionDuration / totalFrames -- 30 / 360 = 0.083
	print("frameDuration = ", frameDuration)


	local degreesPerFrame = 1
	local currentAngle = 0

	Timers:CreateTimer(function()	
		local origin = caster:GetAbsOrigin()
		currentFrame = currentFrame +1

		if direction == "counterClockwise" then
			currentAngle = currentAngle +degreesPerFrame
		end
		if direction == "clockwise" then
			currentAngle = currentAngle -degreesPerFrame
		end

		local radAngle = currentAngle * 0.0174532925 --angle in radians
		local endPoint = Vector(radius * math.cos(radAngle), radius * math.sin(radAngle), 0) + origin

		--PARTICLE: currently a temporary / filler particle
		ParticleManager:SetParticleControl(pfx, 0, origin + Vector(0,0,100))
		ParticleManager:SetParticleControl(pfx, 1, endPoint)

		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), endPoint, caster, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
		for _,enemy in pairs(enemies) do

			--TODO: refactor. Maybe don't even need this if else branch.. but it simplifies decision/detection of the ADD and UPDATE branch.
				-- Question is, do they need to be seperated?
					-- if not.. i'll have to add a bool var to track if enemyNotInLoop, and after loop if it's false. then do _G.ContinuousRadarScanEnemies[#_G.ContinuousRadarScanEnemies+1] = {}
			if Contains(enemiesDetected, enemy) then 
				-- already hit this enemy... if the timeSinceLastDetection is passed some threshold then cast ability

				--find the entry in _G.ContinuousRadarScanEnemies for this enemy 
				for i,row in pairs (_G.ContinuousRadarScanEnemies) do
					if _G.ContinuousRadarScanEnemies[i].Enemy == enemy then
						-- check when we last detected this player... if more than 5-10 seconds ago then update and calldown						
						local timeSinceLastDetection = Time() - _G.ContinuousRadarScanEnemies[#_G.ContinuousRadarScanEnemies].TimeDetected 
						if timeSinceLastDetection > detectionTimeThreshold then
							_G.ContinuousRadarScanEnemies[#_G.ContinuousRadarScanEnemies].TimeDetected = Time()

							--TODO: cast call_down
								ExecuteOrderFromTable({
									UnitIndex = caster:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = enemy:GetAbsOrigin(),
									AbilityIndex = caster:FindAbilityByName("call_down"):entindex(),
									Queue = true, -- I want to set this to queue = true, but when the boss is attacking then this wont work
								})
						end
					end
				end

			else 
				-- first time hitting this enemy, add to table and set true so Contains() function works. 
				enemiesDetected[enemy] = true --little hack so Contains(enemiesDetected,enemy) works 
				_G.ContinuousRadarScanEnemies[#_G.ContinuousRadarScanEnemies+1] = {}
				_G.ContinuousRadarScanEnemies[#_G.ContinuousRadarScanEnemies].Enemy = enemy
				_G.ContinuousRadarScanEnemies[#_G.ContinuousRadarScanEnemies].TimeDetected = Time()

				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = enemy:GetAbsOrigin(),
					AbilityIndex = caster:FindAbilityByName("call_down"):entindex(),
					Queue = true, -- I want to set this to queue = true, but when the boss is attacking then this wont work
				})

			end
		end
		return frameDuration --TODO: implement deltaTime for consistent time frames, don't delay by x, delay by x - timeTakenToProcess		
	end)
end
