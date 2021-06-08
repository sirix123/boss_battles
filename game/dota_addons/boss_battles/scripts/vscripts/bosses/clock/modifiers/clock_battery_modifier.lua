clock_battery_modifier = class({})

-----------------------------------------------------------------------------

function clock_battery_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function clock_battery_modifier:OnCreated()
	self.radius		= 300
	self.interval	= 0.6

	if not IsServer() then return end

	self.damage				= 40

	self:GetParent():EmitSound("Hero_Rattletrap.Battery_Assault")

	self:StartIntervalThink(self.interval)

end

function clock_battery_modifier:OnIntervalThink()
	if not IsServer() then return end

	self:GetParent():EmitSound("Hero_Rattletrap.Battery_Assault_Launch")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(particle)

	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	if #enemies >= 1 then
		enemies[1]:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")

		ParticleManager:SetParticleControl(particle2, 1, enemies[1]:GetAbsOrigin())

    -- Standard logic
        local damageTable = {
            victim 			= enemies[1],
            damage 			= self.damage,
            damage_type		= DAMAGE_TYPE_PHYSICAL,
            attacker 		= self:GetCaster(),
            ability 		= self:GetAbility()
        }

        ApplyDamage(damageTable)

        enemies[1]:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_generic_stunned", {duration = 0.2 })

	else
		ParticleManager:SetParticleControl(particle2, 1, self:GetParent():GetAbsOrigin() + RandomVector(RandomInt(0, 128))) -- Arbitrary numbers
	end

	ParticleManager:ReleaseParticleIndex(particle)
end

function clock_battery_modifier:OnDestroy()
	if not IsServer() then return end

	self:GetParent():StopSound("Hero_Rattletrap.Battery_Assault")
end