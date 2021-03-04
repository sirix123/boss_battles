modifier_rubick = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_rubick:IsHidden()
	return false
end

function modifier_rubick:IsDebuff()
	return false
end

function modifier_rubick:IsPurgable()
	return true
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_rubick:OnCreated( kv )
    self.animation_rate = 0.1
end

function modifier_rubick:OnDestroy()

end

--------------------------------------------------------------------------------

function modifier_rubick:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
    }
end

function modifier_rubick:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_rubick:GetOverrideAnimationRate()
	return self.anim_rate
end

function modifier_rubick:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
	return funcs
end