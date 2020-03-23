charge_modifier_aura = class({})

----------------------------------------

function charge_modifier_aura:IsAura()
	return true
end

----------------------------------------

function charge_modifier_aura:GetModifierAura()
	return  "charge_modifier"
end

----------------------------------------

function charge_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

----------------------------------------

function charge_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

----------------------------------------

function charge_modifier_aura:GetAuraRadius()
	return self.radius
end

----------------------------------------

function charge_modifier_aura:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

----------------------------------------
