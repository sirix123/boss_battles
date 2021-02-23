
mana_drain_root_modifier = class({})

-----------------------------------------------------------------------------

function mana_drain_root_modifier:IsHidden()
	return true
end

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

function mana_drain_root_modifier:OnCreated( kv )

end

-----------------------------------------------------------------------------

function mana_drain_root_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,

        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_STATE_DISARMED,
        MODIFIER_STATE_ROOTED,
	}
	return funcs
end

-----------------------------------------------------------------------------

function mana_drain_root_modifier:GetModifierMoveSpeed_Absolute( params )
	return 0.99
end

function mana_drain_root_modifier:GetModifierDisableTurning( params )
    return 1
end

function mana_drain_root_modifier:GetModifierIgnoreCastAngle( params )
    return 1
end



