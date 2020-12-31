radar_pulse = class({})

--global var so the enemies detected can be accessed outside of this class

function radar_pulse:OnSpellStart()
	local caster = self:GetCaster()
	
	local sound1 = "gyrocopter_gyro_attack_09" -- "gyrocopter_gyro_attack_09" "gyrocopter: I have visual!"
	local sound2 = "gyrocopter_gyro_attack_10" -- "gyrocopter_gyro_attack_10" "gyrocopter: Hostile identified."

	local endRadius = 2000

	--temporary filler particle
	local particleSpeed = 700
    local nfx = ParticleManager:CreateParticle("particles/gyrocopter/gyro_razor_plasmafield.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 1, Vector(particleSpeed, endRadius, 1))

    --reset global var for new scan 
    Clear(_G.RadarPulseEnemies)
	local enemiesDetected = {}

	local radius = 0
	
	local radiusGrowthRate = 25
	local frameDuration = 0.02
	local currentAlpha = 10
	Timers:CreateTimer(function()	
		currentAlpha = currentAlpha + 1
		--update model
		local origin = caster:GetAbsOrigin()
		if radius < endRadius then
			radius = radius + radiusGrowthRate
		else --else, last frame. Flash the circle one last time with higher alpha
			DebugDrawCircle(origin, Vector(255,0,0), 128, radius, true, frameDuration*2)
			--UNTESTED:
			ParticleManager:DestroyParticle(nfx, true)
			ParticleManager:ReleaseParticleIndex(nfx)
			return
		end

		--draw 
		DebugDrawCircle(origin, Vector(255,0,0), currentAlpha, radius, true, frameDuration*2)		
		DebugDrawCircle(origin, Vector(255,0,0), 0, radius-1, true, frameDuration*2) --draw same thing, radius-1, for double thick line/circle edge

		--HACK: to implement some delay, play this sound after a second or two of the spell starting
		if currentAlpha == 50 then
			caster:EmitSound(sound2)
		end

		--check for hits. Maybe don't do this every single tick... but every nth to reduce compute
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		for _,enemy in pairs(enemies) do -- if this enemy has already been hit. only "hit" each enemy once
			if Contains(enemiesDetected, enemy) then -- do nothing. this gets called every tick after the first tick that detects an enemy
			else
				-- enemy detected for the first time this pulse. Gets called once for this Timer
				enemiesDetected[enemy] = true --little hack so Contains(enemiesDetected,enemy) works 
				_G.RadarPulseEnemies[#_G.RadarPulseEnemies+1] = {}
				_G.RadarPulseEnemies[#_G.RadarPulseEnemies].Enemy = enemy
				_G.RadarPulseEnemies[#_G.RadarPulseEnemies].Location = shallowcopy(enemy:GetAbsOrigin())	

				--cast this ability on this enemy.
				local abilityToCast = caster:FindAbilityByName(_G.PulseAndCast) --e.g _G.PulseAndCast = "dumb_homing_missile"

				--if homing_missiles:
				if (_G.PulseAndCast == "dumb_homing_missile" or _G.PulseAndCast == "smart_homing_missile") then
					_G.HomingMissileTargets[#_G.HomingMissileTargets+1] = {}
					_G.HomingMissileTargets[#_G.HomingMissileTargets] = enemy	

					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = abilityToCast:entindex(),
						Queue = false,
					})	
				end
				--if call_down
				if (_G.PulseAndCast == "call_down") then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = enemy:GetAbsOrigin(),
						AbilityIndex = abilityToCast:entindex(),
						Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
					})
				end



			end
		end
		return frameDuration --TODO: implement deltaTime for consistent time frames, don't delay by x, delay by x - timeTakenToProcess		
	end)
end
