q_warlord_dps_stance_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_warlord_dps_stance_modifier:IsHidden()
	return false
end

function q_warlord_dps_stance_modifier:IsDebuff()
	return false
end

function q_warlord_dps_stance_modifier:IsPurgable()
	return false
end

function q_warlord_dps_stance_modifier:RemoveOnDeath()
	return false
end

function q_warlord_dps_stance_modifier:GetTexture()
	return "troll_warlord_berserkers_rage"
end

--------------------------------------------------------------------------------
-- Initializations
function q_warlord_dps_stance_modifier:OnCreated( kv )

end

function q_warlord_dps_stance_modifier:OnRefresh( kv )

end

function q_warlord_dps_stance_modifier:OnDestroy( kv )

end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function q_warlord_dps_stance_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function q_warlord_dps_stance_modifier:GetModifierBaseAttackTimeConstant()
	return -self.delta_bat
end]]

--------------------------------------------------------------------------------
