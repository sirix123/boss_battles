
fire_shell_modifier = class({})

-----------------------------------------------------------------------------

function fire_shell_modifier:IsHidden()
	return true
end

-----------------------------------------------------------------------------

function fire_shell_modifier:GetEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end

-----------------------------------------------------------------------------

function fire_shell_modifier:OnCreated( kv )

end

-----------------------------------------------------------------------------

function fire_shell_modifier:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_STATE_DISARMED,
        MODIFIER_STATE_ROOTED,
	}
	return funcs
end

-----------------------------------------------------------------------------

function fire_shell_modifier:GetModifierMoveSpeed_Absolute( params )
	return 0.99
end



