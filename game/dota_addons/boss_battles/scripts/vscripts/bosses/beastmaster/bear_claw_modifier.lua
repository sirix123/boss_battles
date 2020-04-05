
bear_claw_modifier = class({})

-----------------------------------------------------------------------------

function bear_claw_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function bear_claw_modifier:GetEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds.vpcf"
end

-----------------------------------------------------------------------------

function bear_claw_modifier:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds.vpcf"
end

-----------------------------------------------------------------------------

function bear_claw_modifier:OnCreated( kv )
	if IsServer() then
	    self.slow_percent = self:GetAbility():GetSpecialValueFor( "slow_percent" )
    end
end

-----------------------------------------------------------------------------

function bear_claw_modifier:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}	
	return funcs
end

-----------------------------------------------------------------------------

function bear_claw_modifier:GetModifierMoveSpeed_Absolute( params )
	return self:GetAbility():GetSpecialValueFor("slow_percent")
end

--------------------------------------------------------------------------------
