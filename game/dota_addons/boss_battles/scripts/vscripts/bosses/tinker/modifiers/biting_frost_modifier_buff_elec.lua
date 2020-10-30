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