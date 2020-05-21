shield_wall_modifier =class({})

------------------------------------------------

function shield_wall_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function shield_wall_modifier:GetEffectName()
	return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_glyph.vpcf"
end

------------------------------------------------------------------------------

function shield_wall_modifier:OnCreated( kv )
	if self:GetAbility() then
        self.minMovespeed = self:GetAbility():GetSpecialValueFor("minMovespeed" )
        self.pctDmgReduction = self:GetAbility():GetSpecialValueFor("pctDmgReduction")
    end
end

-----------------------------------------------------------------------------

function shield_wall_modifier:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}	
	return funcs
end

-----------------------------------------------------------------------------

function shield_wall_modifier:GetModifierMoveSpeed_Absolute( params )
	return self.minMovespeed
end

-----------------------------------------------------------------------------

function shield_wall_modifier:GetModifierPhysicalArmorBonus( params )
	return self.pctDmgReduction
end

-----------------------------------------------------------------------------

function shield_wall_modifier:GetModifierMagicalResistanceBonus( params )
	return self.slopctDmgReductionw_percent
end

