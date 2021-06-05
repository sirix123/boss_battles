
q_armor_aura_buff = class({})

-----------------------------------------------------------------------------

function q_armor_aura_buff:IsHidden()
	return false
end

function q_armor_aura_buff:RemoveOnDeath()
    return true
end

-----------------------------------------------------------------------------

function q_armor_aura_buff:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

-----------------------------------------------------------------------------

function q_armor_aura_buff:GetStatusEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

-----------------------------------------------------------------------------

function q_armor_aura_buff:OnCreated( kv )
	self.armor_plus = self:GetAbility():GetSpecialValueFor( "armor_plus" )

	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		--[[self.caster:FindAbilityByName("q_armor_aura"):SetActivated(false)
		self.caster:FindAbilityByName("e_regen_aura"):SetActivated(false)
		self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(false)]]
    end
end

-----------------------------------------------------------------------------
function q_armor_aura_buff:OnDestroy()
	if IsServer() then
		--self.caster:FindAbilityByName("q_armor_aura"):StartCooldown(self.caster:FindAbilityByName("q_armor_aura"):GetCooldown(1))
		if self.parent:GetUnitName() == self.caster:GetUnitName() then
			self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(true)
			self.caster:FindAbilityByName("e_regen_aura"):SetActivated(true)
		end
	end
end

-----------------------------------------------------------------------------
function q_armor_aura_buff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

-----------------------------------------------------------------------------

function q_armor_aura_buff:GetModifierPhysicalArmorBonus( params )
	return self.armor_plus
end

--------------------------------------------------------------------------------
