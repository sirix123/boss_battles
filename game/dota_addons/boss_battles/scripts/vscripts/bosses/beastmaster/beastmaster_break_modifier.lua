
beastmaster_break_modifier = class({})

-----------------------------------------------------------------------------

function beastmaster_break_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function beastmaster_break_modifier:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end

-----------------------------------------------------------------------------

function beastmaster_break_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_arctic_burn.vpcf"
end

-----------------------------------------------------------------------------

function beastmaster_break_modifier:OnCreated( kv )
	if IsServer() then
	    self.armor_reduce = self:GetAbility():GetSpecialValueFor( "armor_reduce" )
    end
end

-----------------------------------------------------------------------------

function beastmaster_break_modifier:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}	
	return funcs
end

-----------------------------------------------------------------------------

function beastmaster_break_modifier:GetModifierPhysicalArmorBonus ( params )
	return self:GetAbility():GetSpecialValueFor("armor_reduce") * self:GetStackCount()
end

--------------------------------------------------------------------------------
