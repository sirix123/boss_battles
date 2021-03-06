
r_outgoing_dmg_debuff = class({})

-----------------------------------------------------------------------------

function r_outgoing_dmg_debuff:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_debuff:GetEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds.vpcf"
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_debuff:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds.vpcf"
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_debuff:OnCreated( kv )
	if IsServer() then
	    self.slow_percent = self:GetAbility():GetSpecialValueFor( "slow_percent" )
    end
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_debuff:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}	
	return funcs
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_debuff:GetModifierMoveSpeed_Absolute( params )
	return self:GetAbility():GetSpecialValueFor("slow_percent")
end

--------------------------------------------------------------------------------
