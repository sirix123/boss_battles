smart_homing_missile_v2 = class({})

local explosionBackgroundParticleName = "particles/econ/events/ti10/hot_potato/hot_potato_explode_ball_explosion.vpcf" -- ctrl pt 0
local explosionParticles = {}
explosionParticles[1] = "particles/econ/courier/courier_cluckles/courier_cluckles_ambient_rocket_explosion_flash_c.vpcf" -- ctrl pt 3
explosionParticles[2] = "particles/econ/courier/courier_snapjaw/courier_snapjaw_ambient_rocket_explosion_flash_c.vpcf"  -- ctrl pt 3

--Smart homing missiles follow the players, 
	-- also changing target if they find a closer target

--New version, Attempt 4/5ish. Appears to be working for single player.
function smart_homing_missile_v2:OnSpellStart()
	--print("smart_homing_missile_v2:OnSpellStart()")
	if #_G.HomingMissileTargets == 0 then 
		return
	end
	local caster = self:GetCaster()

	--grab target from: _G.HomingMissileTargets. remove [1] and reorder the list
	local target = _G.HomingMissileTargets[1]
	for i = 1, #_G.HomingMissileTargets, 1 do 
		if _G.HomingMissileTargets[i+1] ~= nil then 
			_G.HomingMissileTargets[i] = _G.HomingMissileTargets[i+1]
		else
			_G.HomingMissileTargets[i] = nil
		end
	end

	local targetParticleName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_target.vpcf"
	local targetParticle = ParticleManager:CreateParticle( targetParticleName, PATTACH_OVERHEAD_FOLLOW, target )

	local velocity = self:GetSpecialValueFor("velocity")
	local acceleration = self:GetSpecialValueFor("acceleration")
	local damage = self:GetSpecialValueFor("damage")
	local aoeRadius = self:GetSpecialValueFor("aoe_radius")
	local detonationRadius = self:GetSpecialValueFor("detonation_radius")
	local updateInterval = self:GetSpecialValueFor("update_interval")

    -- Create a unit to represent the spell/ability
    local missileUnit = CreateUnitByName("npc_dota_gyrocopter_homing_missile", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	missileUnit:SetModelScale(0.8)
	missileUnit:SetOwner(caster)

	local hasMissileDetonated = false
	--Rocket pulses and updates location every updateInterval seconds. Rocket changes target to nearest enemy
	local detectionRadius = 400
	Timers:CreateTimer(6, function() -- wait 4 seconds before starting, allowing rocket to 'arm'
		if hasMissileDetonated then return end
		if missileUnit:IsNull() then return end
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, detectionRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #enemies > 0 then
			target = enemies[1]

			--remove old particle and create new
			ParticleManager:DestroyParticle(targetParticle, true)
			targetParticle = ParticleManager:CreateParticle( targetParticleName, PATTACH_OVERHEAD_FOLLOW, target )

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

		-- only arm the rocket after it has gone a certain distance from gyro
		local distFromGyro = (missileUnit:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
		if distFromGyro > aoeRadius then
			--if a unit collides with the rocket then detonate. otherwise continue on path.
			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, missileUnit:GetAbsOrigin(), nil, detonationRadius,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
			if ( (#enemies > 0) or (distance < detonationRadius) ) then
				for _,enemy in pairs(enemies) do 
					local enemyDistance = (enemy:GetAbsOrigin() - missileUnit:GetAbsOrigin()):Length2D()
					local damageInfo = 
					{
						victim = enemy,
						attacker = caster,
						damage = damage - enemyDistance, --TODO: calculate the dmg properly based on duration/distance.
						damage_type = DAMAGE_TYPE_PHYSICAL,
						ability = self,
					}
					ApplyDamage(damageInfo)
					--Particle effect on enemy hit by rocket.
					--temp placeholder particle
					local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, self.target )
				end

				--play two particles. Always do explosionBackGroundParticle and then pick another one at random.
				local explosionBackGroundParticle = ParticleManager:CreateParticle( explosionBackgroundParticleName, PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( explosionBackGroundParticle, 0, missileUnit:GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( explosionBackGroundParticle )

				local particleNumber = RandomInt(1, #explosionParticles)
				local particleName = explosionParticles[particleNumber]

				--Because I don't know exactly which CPs these particles have (some use 3,  others use 0, some use mutliple) so just set em all!
				local explosionParticle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, nil )
	            ParticleManager:SetParticleControl( explosionParticle, 0, missileUnit:GetAbsOrigin() )
	            ParticleManager:SetParticleControl( explosionParticle, 3, missileUnit:GetAbsOrigin() )
	            ParticleManager:ReleaseParticleIndex( explosionParticle )

				--destroy the missile
				UTIL_Remove(missileUnit)			
				local hasMissileDetonated = true
				
				ParticleManager:DestroyParticle(targetParticle, true)
				return
			end
		end


    	return dt
	end)
end

