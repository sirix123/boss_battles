r_explosive_tip_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function r_explosive_tip_modifier:IsHidden()
	return false
end

function r_explosive_tip_modifier:IsDebuff()
	return false
end

function r_explosive_tip_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function r_explosive_tip_modifier:OnCreated( kv )
	if IsServer() then
		self.caster = self:GetCaster()
	end
end

function r_explosive_tip_modifier:OnRefresh( kv )
end

function r_explosive_tip_modifier:OnRemoved()
	if IsServer() then

		if self.caster:GetAbilityByIndex(4):GetAbilityName() == "r_explosive_tip_explode" then
			self.caster:SwapAbilities("r_explosive_tip_explode", "r_explosive_tip", false, true)
		end

	end
end

function r_explosive_tip_modifier:OnDestroy()

end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function r_explosive_tip_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function r_explosive_tip_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function r_explosive_tip_modifier:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function r_explosive_tip_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end]]