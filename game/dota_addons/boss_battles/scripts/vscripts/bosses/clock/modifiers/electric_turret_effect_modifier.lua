electric_turret_effect_modifier = class({})

function electric_turret_effect_modifier:IsHidden()
	return true
end

function electric_turret_effect_modifier:IsDebuff()
	return false
end

function electric_turret_effect_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.radius = kv.radius

        -- Create Particle
        -- play effect
        local particle_cast = "particles/clock/clock_disruptor_kineticfield.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
        ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, 0 ) )
        ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( 0, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )

        Timers:CreateTimer(0.5, function()
            if self.parent:IsAlive() == false then
                ParticleManager:DestroyParticle(self.effect_cast,true)
                return false
            end
            return 0.5
        end)

    end
end
----------------------------------------------------------------------------

function electric_turret_effect_modifier:OnDestroy()
    if IsServer() then


    end
end
