modifier_generic_silenced = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_silenced:IsDebuff()
	return true
end

function modifier_generic_silenced:IsStunDebuff()
	return false
end

function modifier_generic_silenced:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Modifier State
function modifier_generic_silenced:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics and animations
function modifier_generic_silenced:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_generic_silenced:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end