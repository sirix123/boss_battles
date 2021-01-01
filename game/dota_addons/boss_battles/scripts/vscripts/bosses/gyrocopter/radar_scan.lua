radar_scan = class({})

--global var so the enemies detected can be accessed outside of this class

function radar_scan:OnSpellStart()
	local caster = self:GetCaster()

	--temporary filler particle
    local particleName = "particles/gyrocopter/red_phoenix_sunray.vpcf"
    
    --local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )	

    --reset global var for new scan
	Clear(_G.RadarScanEnemies)
    local enemiesDetected = {}
    
	local radius = 2500
	local spellDuration = 3 --seconds
	local currentFrame = 1
	local totalFrames = 120
	local frameDuration = spellDuration / totalFrames -- 2 / 120 = 0.016?
	local totalDegreesOfRotation = 360
	local degreesPerFrame = totalDegreesOfRotation / totalFrames
	local currentAngle = 0

	Timers:CreateTimer(function()	
		local origin = caster:GetAbsOrigin()
		currentFrame = currentFrame +1
		currentAngle = currentAngle +degreesPerFrame

		--Scan finished: any cleanup or actions on the last frame... 
		if currentFrame >= totalFrames then
			--ParticleManager:DestroyParticle(pfx, true)			
			return
		end	

		local radAngle = currentAngle * 0.0174532925 --angle in radians
		local endPoint = Vector(radius * math.cos(radAngle), radius * math.sin(radAngle), 0) + origin

		--PARTICLE: currently a temporary / filler particle
		-- ParticleManager:SetParticleControl(pfx, 0, origin + Vector(0,0,100))
		-- ParticleManager:SetParticleControl(pfx, 1, endPoint)

		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), endPoint, caster, 1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
		for _,enemy in pairs(enemies) do
			if Contains(enemiesDetected, enemy) then 
				-- already hit this enemy, do nothing
			else 
				-- first time hitting this enemy, add to table and set true so Contains() function works. 
				enemiesDetected[enemy] = true --little hack so Contains(enemiesDetected,enemy) works 
				_G.RadarScanEnemies[#_G.RadarScanEnemies+1] = {}
				_G.RadarScanEnemies[#_G.RadarScanEnemies].Enemy = enemy
				_G.RadarScanEnemies[#_G.RadarScanEnemies].Location = shallowcopy(enemy:GetAbsOrigin())	

				--cast this ability on this enemy.
				local abilityToCast = caster:FindAbilityByName(_G.ScanAndCast) --e.g _G.ScanAndCast = "dumb_homing_missile"

				--if homing_missiles:
				if (_G.ScanAndCast == "dumb_homing_missile" or _G.ScanAndCast == "smart_homing_missile") then
					_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = {}
					_G.HomingMissileTargets[#_G.HomingMissileTargets] = enemy	
		
					--TESTED: if queue false, interupts other actions. if queue true, won't interrupt
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = abilityToCast:entindex(),
						Queue = true,
					})	
				end
				--if call_down
				if (_G.ScanAndCast == "call_down") then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = enemy:GetAbsOrigin(),
						AbilityIndex = abilityToCast:entindex(),
						Queue = true, -- I want to set this to queue = true, but when the boss is attacking then this wont work
					})
				end
			end
		end
		return frameDuration --TODO: implement deltaTime for consistent time frames, don't delay by x, delay by x - timeTakenToProcess		
	end)
end
