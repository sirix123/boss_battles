
q_armor_aura_debuff = class({})

-----------------------------------------------------------------------------

function q_armor_aura_debuff:IsHidden()
	return false
end

function q_armor_aura_debuff:IsDebuff()
	return true
end

-----------------------------------------------------------------------------

function q_armor_aura_debuff:OnCreated( kv )
	if IsServer() then
		local ability = self:GetCaster():FindAbilityByName("q_armor_aura")
	    self.armor_minus = ability:GetSpecialValueFor( "armor_minus" )

		local particleName = "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
		self.nfx = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 2, self:GetParent():GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_overhead", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 2, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

    end
end

function q_armor_aura_debuff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx,true)
	end
end

-----------------------------------------------------------------------------

function q_armor_aura_debuff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

-----------------------------------------------------------------------------

function q_armor_aura_debuff:GetModifierPhysicalArmorBonus( params )
	return -self.armor_minus
end

--------------------------------------------------------------------------------
