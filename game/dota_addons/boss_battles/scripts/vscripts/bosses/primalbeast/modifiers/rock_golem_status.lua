rock_golem_status = class({})

function rock_golem_status:IsHidden() return true end

-- function rock_golem_status:OnCreated()
--     print("hghlel")
-- end

function rock_golem_status:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function rock_golem_status:GetEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function rock_golem_status:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function rock_golem_status:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function rock_golem_status:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function rock_golem_status:GetOverrideAnimationRate()
	return RandomFloat(0.0,1.0)
end


function rock_golem_status:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
	return funcs
end