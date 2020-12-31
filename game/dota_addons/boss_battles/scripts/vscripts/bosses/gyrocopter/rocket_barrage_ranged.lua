rocket_barrage_ranged = class({})

local spellDuration = 3.5 -- Spell duration in seconds

--TODO: implement  deltaDelay, wait (0.1 - time to execute code)
local tickDuration = 0.1 -- Amount of time to delay between ticks
local tickLimit = spellDuration / tickDuration

local totalDamage = 300
local tickDamage = totalDamage / tickLimit
local radius = 400 -- hit every unit beyond this radius. ignore units within this radius
local maxRadius = 4000 -- big enough to cover whole arena, but not big enough to hit units outside of arena

local displayDebug = true

--Rocket barrage targets all enemies in the radius and distributes tickDamage amongst them every tickDuration.
function rocket_barrage_ranged:OnSpellStart()
	_G.IsGyroBusy = true

	EmitSoundOn( "gyrocopter_gyro_rocket_barrage_05", self:GetCaster() )

	local caster = self:GetCaster()
	local particle = "particles/gyrocopter/gyro_rocket_barrage.vpcf"
	--Run a timer for spellDuration

	if displayDebug then 
		DebugDrawCircle(caster:GetAbsOrigin(), Vector(0,255,0), 96, radius, true, tickDuration*2) -- melee is green
		DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 64, radius*5, true, tickDuration*2) -- ranged is red
	end

	local tickCount = 0
	Timers:CreateTimer(function()	
		tickCount = tickCount + 1

		--check if we've reached the end of the spell
		if tickCount >= tickLimit then
			_G.IsGyroBusy = false
			return
		 end

		--Get nearby enemies
		local inRadiusenemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		local allEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, maxRadius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		local beyondRadiusEnemies = {}

		--algo to detect enemies within a donut shape: get all enemies within max radius, get enemies in min radius, remove enemies within minRadius from enemies within maxRadius
		for _,rangedEnemy in pairs(allEnemies) do
			local enemyInBoth = false
			for _,meleeEnemy in pairs(inRadiusenemies) do
				if meleeEnemy == rangedEnemy then 
					enemyInBoth = true
					break
				end
			end
			if not enemyInBoth then
				beyondRadiusEnemies[#beyondRadiusEnemies +1] = rangedEnemy
			end
		end

		--Each enemy in radius gets hit for tickDamage / #enemies
		for key, enemy in pairs(beyondRadiusEnemies) do 
			local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particleIndex, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particleIndex, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( particleIndex )
			local damageInfo = 
			{
				victim = enemy, attacker = caster,
				damage = tickDamage / #beyondRadiusEnemies, 
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}
			local dmgDealt = ApplyDamage(damageInfo)
		end
		return tickDuration
	end)
end