rocket_barrage = class({})

--As the spell level increases the dmg increase, perhaps the radius or duration too. 


local spellDuration = 2 -- Spell duration in seconds
local tickDuration = 0.1 -- Amount of time to delay between ticks
local tickLimit = spellDuration / tickDuration

local totalDamage = 50
local tickDamage = totalDamage / tickLimit


local radius = 400


--Rocket barrage targets all enemies in the radius and deals tickDamage to them every tickDuration.
function rocket_barrage:OnSpellStart()
	-- print("rocket_barrage:OnSpellStart()")
	local caster = self:GetCaster()
	--doesn't work
	--self:GetCaster():EmitSound('gyrocopter_gyro_attack_08')

	
	-- print("rocket_barrage. caster = ", caster)
	-- print("rocket_barrage. caster:GetAbsOrigin() = ", caster:GetAbsOrigin())


	--local particle = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf"
	local particle = "particles/gyrocopter/gyro_rocket_barrage.vpcf"

	--Run a timer for spellDuration
	local tickCount = 0
	Timers:CreateTimer(function()	
		tickCount = tickCount + 1

		--Get nearby enemies
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		--if no enemies, then no need to continue
		if #enemies == 0 then 
			return tickDuration
		end

		--Each enemy in radius gets hit for tickDamage
		for key, enemy in pairs(enemies) do 

			local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particleIndex, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particleIndex, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( particleIndex )

			--todo make dmg table
			local damageInfo = 
			{
				victim = enemy, attacker = caster,
				damage = tickDamage, --TODO: calc this / get from somewhere
				damage_type = 2, -- TODO: get this from ability file ... 4 = DAMAGE_TYPE_PURE 
				ability = self,
			}
			--apply
			local dmgDealt = ApplyDamage(damageInfo)
		end

		--check if we've reached the end of the spell
		if tickCount >= tickLimit then
			--print("tickCount >= tickLimit. Returning.")
			return 
		end

		return tickDuration
	end)

end