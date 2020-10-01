modifier_remove_healthbar = class({})

--------------------------------------------------------------------------------

function modifier_remove_healthbar:IsDebuff()
	return true
end

function modifier_remove_healthbar:IsStunDebuff()
	return true
end

function modifier_remove_healthbar:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_remove_healthbar:CheckState()
	local state = {
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end

--------------------------------------------------------------------------------

