
bear_claw_modifier = class({})

-----------------------------------------------------------------------------

function bear_claw_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function bear_claw_modifier:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end

-----------------------------------------------------------------------------

function bear_claw_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_arctic_burn.vpcf"
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
