modifier_flying_movement_ground = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_flying_movement_ground:IsDebuff()
	return true
end

function modifier_flying_movement_ground:IsStunDebuff()
	return false
end

function modifier_flying_movement_ground:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Modifier State
function modifier_flying_movement_ground:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}

	return state
end

--------------------------------------------------------------------------------
--[[ Graphics and animations
function modifier_flying_movement_ground:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_flying_movement_ground:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end]]