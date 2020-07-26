stunned_modifier = class({})

function stunned_modifier:IsDebuff() return true end
function stunned_modifier:IsStunDebuff() return true end

function stunned_modifier:OnCreated()
	if IsServer() then

	end
end

function stunned_modifier:CheckState()
	return {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function stunned_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function stunned_modifier:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end

function stunned_modifier:GetEffectName()
	return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned.vpcf"
end

function stunned_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function stunned_modifier:GetStatusLabel() return "Stun" end
function stunned_modifier:GetStatusPriority() return 4 end
function stunned_modifier:GetStatusStyle() return "Stun" end