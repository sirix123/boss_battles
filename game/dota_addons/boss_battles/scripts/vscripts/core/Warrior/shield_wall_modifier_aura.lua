shield_wall_modifier_aura = class({})


-- FILE NOT CALLED ANYWHERE ANYMORE 

----------------------------------------

function shield_wall_modifier_aura:IsAura()
	return true
end

----------------------------------------

function shield_wall_modifier_aura:GetModifierAura()
	return  "shield_wall_modifier"
end

----------------------------------------

function shield_wall_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

----------------------------------------

function shield_wall_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

----------------------------------------

function shield_wall_modifier_aura:GetAuraRadius()
	return self.radius
end

----------------------------------------

function shield_wall_modifier_aura:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

----------------------------------------
