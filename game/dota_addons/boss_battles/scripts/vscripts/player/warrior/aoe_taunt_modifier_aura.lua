aoe_taunt_modifier_aura = class({})

----------------------------------------

function aoe_taunt_modifier_aura:IsAura()
	return true
end

----------------------------------------

function aoe_taunt_modifier_aura:GetModifierAura()
	return  "aoe_taunt_modifier"
end

----------------------------------------

function aoe_taunt_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

----------------------------------------

function aoe_taunt_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

----------------------------------------

function aoe_taunt_modifier_aura:GetAuraRadius()
	return self.radius
end

----------------------------------------

function aoe_taunt_modifier_aura:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

----------------------------------------
