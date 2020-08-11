modifier_sprint = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sprint:IsHidden()
	return false
end

function modifier_sprint:IsDebuff()
	return false
end

function modifier_sprint:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sprint:OnCreated( kv )
	-- references
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )

end

function modifier_sprint:OnRefresh( kv )
	-- same as oncreated
	self:OnCreated( kv )
end

function modifier_sprint:OnRemoved()
end

function modifier_sprint:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sprint:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_sprint:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sprint:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_sprint:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end