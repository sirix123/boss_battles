
--------------------------------------------------------------------------------
modifier_rooted_clock = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_rooted_clock:IsHidden()
	return false
end

function modifier_rooted_clock:IsDebuff()
	return true
end

function modifier_rooted_clock:IsStunDebuff()
	return false
end

function modifier_rooted_clock:IsPurgable()
	return true
end

function modifier_rooted_clock:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_rooted_clock:OnCreated( kv )

	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_rooted_clock:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_rooted_clock:GetEffectName()
	return "particles/clock/clock_dark_willow_bramble.vpcf"
end

function modifier_rooted_clock:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
