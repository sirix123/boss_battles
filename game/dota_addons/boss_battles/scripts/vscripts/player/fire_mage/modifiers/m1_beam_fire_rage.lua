m1_beam_fire_rage = class({})

function m1_beam_fire_rage:IsHidden()
	return false
end

function m1_beam_fire_rage:IsDebuff()
	return false
end

function m1_beam_fire_rage:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function m1_beam_fire_rage:OnCreated( kv )
    if IsServer() then
        self.particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.particle_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.particle_fx, 1, Vector(1,0,0))
	end
end
---------------------------------------------------------------------------

function m1_beam_fire_rage:OnRefresh( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

function m1_beam_fire_rage:OnDestroy( kv )
    if IsServer() then
	end
end
-----------------------------------------------------------------------------
