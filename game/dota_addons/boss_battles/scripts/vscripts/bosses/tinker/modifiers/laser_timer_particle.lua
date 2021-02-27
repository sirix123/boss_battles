laser_timer_particle = class({})

function laser_timer_particle:IsHidden()
	return false
end

function laser_timer_particle:IsDebuff()
	return true
end

function laser_timer_particle:OnCreated( kv )
    if IsServer() then

        self:StartIntervalThink( 0.03 )
		
    end
end

function laser_timer_particle:OnDestroy()
    if IsServer() then


    end
end

--------------------------------------------------------------------------------

function laser_timer_particle:OnIntervalThink()
    if IsServer() then

        local remaining = self:GetRemainingTime()
        local seconds = math.ceil( remaining )
        local isHalf = (seconds-remaining)>0.5
        if isHalf then seconds = seconds-1 end

        if self.half~=isHalf then
            self.half = isHalf

            self:PlayTimerEffects( seconds, isHalf )
        end

        self:PlayArrowEffects()

    end
end

function laser_timer_particle:PlayTimerEffects(seconds, half)
    if IsServer() then

        local particle_cast = "particles/tinker/biger_hoodwink_sharpshooter_timer.vpcf"

        -- calculate data
        local mid = 1
        if half then mid = 8 end

        local len = 2
        if seconds<1 then
            len = 1
            if not half then return end
        end

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, seconds, mid ) )
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( len, 0, 0 ) )

    end
end

function laser_timer_particle:PlayArrowEffects()
    if IsServer() then
    end
end

