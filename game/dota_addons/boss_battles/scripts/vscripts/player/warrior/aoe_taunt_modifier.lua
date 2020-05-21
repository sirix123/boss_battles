aoe_taunt_modifier =class({})

------------------------------------------------

function aoe_taunt_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function aoe_taunt_modifier:GetEffectName()
	return "particles/items4_fx/scepter_aura_dot.vpcf"
end

------------------------------------------------------------------------------

function aoe_taunt_modifier:OnCreated( kv )
	if self:GetAbility() then
        self.reduceDmg = self:GetAbility():GetSpecialValueFor("reduceDmg" )
    end
end

-----------------------------------------------------------------------------

function aoe_taunt_modifier:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}	
	return funcs
end

-----------------------------------------------------------------------------

function aoe_taunt_modifier:GetModifierDamageOutgoing_Percentage( params )
	return self.reduceDmg
end

