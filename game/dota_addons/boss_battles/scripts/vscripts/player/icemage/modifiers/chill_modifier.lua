
chill_modifier = class({})

-----------------------------------------------------------------------------

function chill_modifier:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function chill_modifier:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function chill_modifier:GetStatusEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function chill_modifier:OnCreated( kv )
	if IsServer() then
        self.ms_slow = -200
        self.as_slow = -50
    end
end
----------------------------------------------------------------------------

function chill_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end
-----------------------------------------------------------------------------

function chill_modifier:GetModifierMoveSpeed_Absolute( params )
	return self.ms_slow
end
--------------------------------------------------------------------------------

function chill_modifier:GetModifierAttackSpeedBonus_Constant( params )
	return self.as_slow
end
--------------------------------------------------------------------------------