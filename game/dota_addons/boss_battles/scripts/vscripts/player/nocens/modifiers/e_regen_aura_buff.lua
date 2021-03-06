
e_regen_aura_buff = class({})

-----------------------------------------------------------------------------

function e_regen_aura_buff:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function e_regen_aura_buff:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end

-----------------------------------------------------------------------------

function e_regen_aura_buff:GetStatusEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end

-----------------------------------------------------------------------------

function e_regen_aura_buff:OnCreated( kv )
	self.regen_plus = self:GetAbility():GetSpecialValueFor( "regen_plus" )
    if IsServer() then
        self.caster = self:GetCaster()
        self.caster:FindAbilityByName("q_armor_aura"):SetActivated(false)
        self.caster:FindAbilityByName("e_regen_aura"):SetActivated(false)
        self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(false)
    end
end
-----------------------------------------------------------------------------

function e_regen_aura_buff:OnDestroy()
    if IsServer() then
        self.caster:FindAbilityByName("q_armor_aura"):SetActivated(true)
        self.caster:FindAbilityByName("e_regen_aura"):SetActivated(true)
        self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(true)
    end
end
-----------------------------------------------------------------------------

function e_regen_aura_buff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-----------------------------------------------------------------------------

function e_regen_aura_buff:GetModifierConstantHealthRegen( params )
	return self.regen_plus
end

--------------------------------------------------------------------------------
