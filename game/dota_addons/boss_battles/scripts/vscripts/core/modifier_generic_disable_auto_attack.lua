modifier_generic_disable_auto_attack = class({})

--------------------------------------------------------------------------------

function modifier_generic_disable_auto_attack:IsDebuff()
	return true
end

function modifier_generic_disable_auto_attack:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------


function modifier_generic_disable_auto_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
	}

	return funcs
end

function modifier_generic_disable_auto_attack:GetDisableAutoAttack()
	return true
end

