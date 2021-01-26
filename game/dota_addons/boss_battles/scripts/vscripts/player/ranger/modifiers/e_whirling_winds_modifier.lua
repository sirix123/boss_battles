e_whirling_winds_modifier = class({})
-----------------------------------------------------------------------------

function e_whirling_winds_modifier:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function e_whirling_winds_modifier:GetEffectName()
	return "particles/ranger/ranger_wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function e_whirling_winds_modifier:GetStatusEffectName()
	return "particles/ranger/ranger_wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function e_whirling_winds_modifier:OnCreated( kv )
    --if IsServer() then

        self.ms_boost = 30
        self.dmg_boost_percent = 30

    --end
end
----------------------------------------------------------------------------

function e_whirling_winds_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function e_whirling_winds_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms_boost
end
--------------------------------------------------------------------------------

function e_whirling_winds_modifier:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.dmg_boost_percent
end
--------------------------------------------------------------------------------


