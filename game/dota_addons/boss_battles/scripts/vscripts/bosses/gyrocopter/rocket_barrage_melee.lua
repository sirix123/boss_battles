rocket_barrage_melee = class({})

local spellDuration = 3.5 -- Spell duration in seconds

--TODO: implement  deltaDelay, wait (0.1 - time to execute code)
local tickDuration = 0.1 -- Amount of time to delay between ticks
local tickLimit = spellDuration / tickDuration

local totalDamage = 300
local tickDamage = totalDamage / tickLimit
local radius = 400

--Rocket barrage targets all enemies in the radius and distributes tickDamage amongst them every tickDuration.
function rocket_barrage_melee:OnSpellStart()
	local caster = self:GetCaster()
	local particle = "particles/gyrocopter/gyro_rocket_barrage.vpcf"
	--Run a timer for spellDuration
	local tickCount = 0
	Timers:CreateTimer(function()	
		tickCount = tickCount + 1

		--check if we've reached the end of the spell
		if tickCount >= tickLimit then return end

		--Get nearby enemies
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--if no enemies, then no need to continue
		if #enemies == 0 then return tickDuration end
		--Each enemy in radius gets hit for tickDamage / #enemies
		for key, enemy in pairs(enemies) do 
			local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particleIndex, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particleIndex, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( particleIndex )
			local damageInfo = 
			{
				victim = enemy, attacker = caster,
				damage = tickDamage / #enemies, 
				damage_type = 2, -- TODO: get this from ability file ... 4 = DAMAGE_TYPE_PURE 
				ability = self,
			}
			local dmgDealt = ApplyDamage(damageInfo)
		end
		return tickDuration
	end)
end