tinker_teleport = class({})

function tinker_teleport:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT, 1.5)

        -- sound effect
        EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "NeutralItem.TeleportToStash", self:GetCaster())

        local particle = "particles/econ/events/ti8/teleport_end_ti8.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.effect_cast, 1, self:GetCaster():GetAbsOrigin())
        --ParticleManager:ReleaseParticleIndex(effect_cast)

        return true
    end
end

function tinker_teleport:OnSpellStart()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_TELEPORT)

        ParticleManager:DestroyParticle(self.effect_cast,false)

        StopSoundOn("NeutralItem.TeleportToStash", self:GetCaster())

        -- move to loc
        -- pick one of 4 spots and teleport there
        local centre_point = Vector(-10633,11918,130.33)
        local radius = 1800
        local x = RandomInt(centre_point.x - radius - 100, centre_point.x + radius + 100)
        local y = RandomInt(centre_point.y - radius - 100, centre_point.y + radius + 100)
        local move_pos = Vector(x,y,0)

        FindClearSpaceForUnit(self:GetCaster(), move_pos, true)


	end
end