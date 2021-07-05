
e_sigil_of_power_modifier_buff = class({})

-----------------------------------------------------------------------------

function e_sigil_of_power_modifier_buff:IsHidden()
	return false
end

function e_sigil_of_power_modifier_buff:RemoveOnDeath()
    return true
end

-----------------------------------------------------------------------------

function e_sigil_of_power_modifier_buff:OnCreated( kv )
    self.outgoing_plus = kv.damage_boost
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.outgoing_plus = kv.damage_boost

        local particle = "particles/custom/magic_circle/follow_magic_circle.vpcf"

        self.nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.nfx, 2, Vector(100,0,0))

        print("kv.damage_boost ",kv.damage_boost)
    end
end
-----------------------------------------------------------------------------

function e_sigil_of_power_modifier_buff:OnDestroy()
    if IsServer() then
        if self.nfx then
            ParticleManager:DestroyParticle(self.nfx,false)
        end

    end
end
-----------------------------------------------------------------------------

function e_sigil_of_power_modifier_buff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function e_sigil_of_power_modifier_buff:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.outgoing_plus
end

--------------------------------------------------------------------------------
