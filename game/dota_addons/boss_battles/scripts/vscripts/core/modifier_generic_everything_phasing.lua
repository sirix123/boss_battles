

modifier_generic_everything_phasing = class({})

--------------------------------------------------------------------------------

function modifier_generic_everything_phasing:IsDebuff()
	return true
end

function modifier_generic_everything_phasing:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_generic_everything_phasing:CheckState()
	local state = {
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}

	return state
end

--------------------------------------------------------------------------------