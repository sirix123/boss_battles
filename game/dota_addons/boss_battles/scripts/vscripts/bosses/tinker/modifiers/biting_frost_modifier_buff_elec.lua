biting_frost_modifier_buff_elec = class({})

function biting_frost_modifier_buff_elec:IsHidden()
	return false
end

function biting_frost_modifier_buff_elec:IsDebuff()
	return false
end

function biting_frost_modifier_buff_elec:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff_elec:OnCreated( kv )
    if IsServer() then


	end
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff_elec:OnDestroy( kv )
    if IsServer() then

	end
end
-----------------------------------------------------------------------------

function biting_frost_modifier_buff_elec:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
end

-----------------------------------------------------------------------------

function biting_frost_modifier_buff_elec:GetModifierMoveSpeedBonus_Constant( params )
	return -200
end

--------------------------------------------------------------------------------

function biting_frost_modifier_buff_elec:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end

-----------------------------------------------------------------------------

function biting_frost_modifier_buff_elec:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_arctic_burn.vpcf"
end
