q_iceblock_modifier = class({})

-----------------------------------------------------------------------------

function q_iceblock_modifier:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:GetStatusEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:OnCreated( kv )
	if IsServer() then
        --self.ms_slow = -200
        --self.as_slow = -50
    end
end
----------------------------------------------------------------------------
--[[
function q_iceblock_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:GetModifierMoveSpeed_Absolute( params )
	return self.ms_slow
end
--------------------------------------------------------------------------------

function q_iceblock_modifier:GetModifierAttackSpeedBonus_Constant( params )
	return self.as_slow
end]]
--------------------------------------------------------------------------------