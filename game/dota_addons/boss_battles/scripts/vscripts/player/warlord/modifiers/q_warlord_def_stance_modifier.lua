q_warlord_def_stance_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_warlord_def_stance_modifier:IsHidden()
	return true
end

function q_warlord_def_stance_modifier:IsDebuff()
	return false
end

function q_warlord_def_stance_modifier:IsPurgable()
	return false
end

function q_warlord_def_stance_modifier:RemoveOnDeath()
	return false
end

function q_warlord_def_stance_modifier:GetTexture()
	return "dragon_knight_dragon_tail"
end

--------------------------------------------------------------------------------
-- Initializations
function q_warlord_def_stance_modifier:OnCreated( kv )

end

function q_warlord_def_stance_modifier:OnRefresh( kv )

end

function q_warlord_def_stance_modifier:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Aura
function q_warlord_def_stance_modifier:IsAura()
	return true
end

function q_warlord_def_stance_modifier:GetModifierAura()
	return "q_warlord_def_stance_modifier_lifesteal"
end

function q_warlord_def_stance_modifier:GetAuraRadius()
	return self.aura_radius
end

function q_warlord_def_stance_modifier:GetAuraSearchTeam()
	if not self:GetParent():PassivesDisabled() then
		return DOTA_UNIT_TARGET_TEAM_FRIENDLY
	end
end

function q_warlord_def_stance_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--[[function q_warlord_def_stance_modifier:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end]]
--------------------------------------------------------------------------------
-- Initializations
function q_warlord_def_stance_modifier:OnCreated( kv )
	-- references
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "lifesteal_aura_radius" ) -- special value
end

function q_warlord_def_stance_modifier:OnRefresh( kv )
	-- references
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "lifesteal_aura_radius" ) -- special value
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function q_warlord_def_stance_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function q_warlord_def_stance_modifier:GetModifierBaseAttackTimeConstant()
	return -self.delta_bat
end]]

--------------------------------------------------------------------------------
