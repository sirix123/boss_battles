bird_mark_modifier = class({})

-----------------------------------------------------------------------------

function bird_mark_modifier:RemoveOnDeath()
    return true
end

function bird_mark_modifier:OnCreated( kv )
	if IsServer() then

        local particle = "particles/timber/bird_overhead_icon.vpcf"
        self.head_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.head_particle, 0, self:GetParent():GetAbsOrigin())

    end
end
----------------------------------------------------------------------------

function bird_mark_modifier:OnDestroy()
    if not IsServer() then return nil end

    ParticleManager:DestroyParticle(self.head_particle,true)

end

