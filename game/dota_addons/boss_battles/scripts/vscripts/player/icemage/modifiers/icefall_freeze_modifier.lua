icefall_freeze_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function icefall_freeze_modifier:IsHidden()
	return false
end

function icefall_freeze_modifier:IsDebuff()
	return false
end
-----------------------------------------------------------------------------

function icefall_freeze_modifier:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end

function icefall_freeze_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
-----------------------------------------------------------------------------

function icefall_freeze_modifier:OnCreated( kv )
end
----------------------------------------------------------------------------

function icefall_freeze_modifier:OnRefresh( kv )
end
----------------------------------------------------------------------------

function icefall_freeze_modifier:OnDestroy()
end
----------------------------------------------------------------------------

function icefall_freeze_modifier:CheckState()
	return {
		--[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}
end
-----------------------------------------------------------------------------

function icefall_freeze_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function icefall_freeze_modifier:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end