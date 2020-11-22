modifier_ground = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ground:IsHidden()
	return true
end

function modifier_ground:IsDebuff()
	return false
end

function modifier_ground:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ground:OnCreated( kv )
end

function modifier_ground:OnDestroy()
end

--------------------------------------------------------------------------------

function modifier_ground:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = false, 
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
    }
end

function modifier_ground:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ground:GetVisualZDelta()
	return 50
end

function modifier_ground:GetModifierMoveSpeedBonus_Constant()
	return -200
end

