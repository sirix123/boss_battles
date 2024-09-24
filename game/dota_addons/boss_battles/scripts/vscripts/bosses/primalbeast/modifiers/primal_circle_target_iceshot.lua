primal_circle_target_iceshot = class({})

function primal_circle_target_iceshot:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf", context )
end

function primal_circle_target_iceshot:OnCreated( kv )
	if not IsServer() then return end

	self.duration = self:GetDuration()
	self.radius = kv.radius

	-- create aoe finder particle
	self:PlayEffects(  )
end

function primal_circle_target_iceshot:OnDestroy()
    if not IsServer() then return end
    -- stop aoe finder particle
    self:StopEffects()

	UTIL_Remove( self:GetParent() )
end
--------------------------------------------------------------------------------------------------------------

function primal_circle_target_iceshot:PlayEffects(  )
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( self.duration, 0, 0 ) )
end

function primal_circle_target_iceshot:StopEffects()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end