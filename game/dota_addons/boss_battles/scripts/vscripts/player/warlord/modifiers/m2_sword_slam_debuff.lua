m2_sword_slam_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function m2_sword_slam_debuff:IsHidden()
	return false
end

function m2_sword_slam_debuff:IsDebuff()
	return true
end

function m2_sword_slam_debuff:IsPurgable()
	return false
end

function m2_sword_slam_debuff:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function m2_sword_slam_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------
-- Initializations
function m2_sword_slam_debuff:OnCreated( kv )

end

function m2_sword_slam_debuff:OnRefresh( kv )

end

function m2_sword_slam_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function m2_sword_slam_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function m2_sword_slam_debuff:GetModifierBaseAttackTimeConstant()
	return -self.delta_bat
end]]

--------------------------------------------------------------------------------
