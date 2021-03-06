
q_armor_aura_debuff = class({})

-----------------------------------------------------------------------------

function q_armor_aura_debuff:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function q_armor_aura_debuff:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_jump_armor_debuff.vpcf"
end

-----------------------------------------------------------------------------

function q_armor_aura_debuff:OnCreated( kv )
	if IsServer() then
		local ability = self:GetCaster():FindAbilityByName("q_armor_aura")
	    self.armor_minus = ability:GetSpecialValueFor( "armor_minus" )
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
