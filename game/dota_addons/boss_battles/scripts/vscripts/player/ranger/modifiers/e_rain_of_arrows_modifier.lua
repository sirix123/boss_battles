e_rain_of_arrows_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function e_rain_of_arrows_modifier:IsHidden()
	return false
end

function e_rain_of_arrows_modifier:IsDebuff()
	return false
end

function e_rain_of_arrows_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function e_rain_of_arrows_modifier:OnCreated( kv )
	if IsServer() then
		self.caster = self:GetCaster()

	end
end

function e_rain_of_arrows_modifier:OnRefresh( kv )
end

function e_rain_of_arrows_modifier:OnRemoved()
	if IsServer() then

	end
end

function e_rain_of_arrows_modifier:OnDestroy()

end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function e_rain_of_arrows_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function e_rain_of_arrows_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function e_rain_of_arrows_modifier:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function e_rain_of_arrows_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end]]