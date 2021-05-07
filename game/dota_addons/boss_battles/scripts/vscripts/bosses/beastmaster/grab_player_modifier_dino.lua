grab_player_modifier_dino = class({})
--------------------------------------------------------------------------------

function grab_player_modifier_dino:IsDebuff() 
    return true 
end

function grab_player_modifier_dino:IsHidden()
    return true 
end

function grab_player_modifier_dino:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_flaming_lasso_generic_smoke.vpcf"
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:OnCreated(params)
	if not IsServer() then return end
    
    self.caster = self:GetCaster()
	
	self.drag_distance			= 50

	self.interval			= FrameTime()
	
	self.chariot_max_length	= self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), self:GetParent())
	self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
	self.current_position	= self:GetCaster():GetAbsOrigin()	
	
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.Loop")
	
	self.lasso_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flaming_lasso.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.lasso_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.lasso_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.lasso_particle, false, false, -1, false, false)
	
	self:StartIntervalThink(self.interval)
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:OnRefresh(params)
	self:OnCreated(params)
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:OnIntervalThink()

    self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    self.current_position	= self:GetCaster():GetAbsOrigin()
    self:GetParent():SetAbsOrigin(GetGroundPosition(self:GetCaster():GetAbsOrigin() + self.vector:Normalized() * self.drag_distance, nil))
	
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Batrider.FlamingLasso.Loop")
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.End")
	
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)	
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]							= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
	}
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end
--------------------------------------------------------------------------------

function grab_player_modifier_dino:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
--------------------------------------------------------------------------------
