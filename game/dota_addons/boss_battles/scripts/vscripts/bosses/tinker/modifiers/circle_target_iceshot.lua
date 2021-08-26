circle_target_iceshot = class({})

function circle_target_iceshot:OnCreated( kv )
	if not IsServer() then return end

	self.max_travel = self:GetAbility():GetSpecialValueFor( "max_travel" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	-- create aoe finder particle
	self:PlayEffects( kv.travel_time )
end

function circle_target_iceshot:OnRefresh( kv )
    if not IsServer() then return end

	self.max_travel = self:GetAbility():GetSpecialValueFor( "max_travel" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

function circle_target_iceshot:OnRemoved()
end

function circle_target_iceshot:OnDestroy()
    if not IsServer() then return end
    -- stop aoe finder particle
    self:StopEffects()

	UTIL_Remove( self:GetParent() )
end
--------------------------------------------------------------------------------------------------------------

function circle_target_iceshot:PlayEffects( time )
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end

function circle_target_iceshot:StopEffects()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end