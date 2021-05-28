modifier_untargetable = class({})

--------------------------------------------------------------------------------

function modifier_untargetable:IsDebuff()
	return true
end

function modifier_untargetable:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_untargetable:CheckState()
	local state = {
	[MODIFIER_STATE_UNTARGETABLE] = true,
	[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	}

	return state
end

--------------------------------------------------------------------------------