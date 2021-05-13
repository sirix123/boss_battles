tinker_teleport_phase2 = class({})
LinkLuaModifier( "mana_drain_root_modifier", "bosses/tinker/modifiers/mana_drain_root_modifier", LUA_MODIFIER_MOTION_NONE  )

function tinker_teleport_phase2:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT, 1.5)

        self.move_pos = self:GetCursorTarget()
        if self.move_pos == nil then
            return false
       end

        -- sound effect
        EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "NeutralItem.TeleportToStash", self:GetCaster())

        local particle = "particles/econ/events/ti8/teleport_end_ti8.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.effect_cast, 1, self:GetCaster():GetAbsOrigin())
        --ParticleManager:ReleaseParticleIndex(effect_cast)

        self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.effect_cast_1, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.effect_cast_1, 1, self:GetCaster():GetAbsOrigin())

        return true
    end
end

function tinker_teleport_phase2:OnSpellStart()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_TELEPORT)

        ParticleManager:DestroyParticle(self.effect_cast,false)
        ParticleManager:DestroyParticle(self.effect_cast_1,false)

        StopSoundOn("NeutralItem.TeleportToStash", self:GetCaster())

        local randomX = RandomInt(150,250)
        local randomY = RandomInt(150,250)
        self.vMove_pos = Vector(self.move_pos:GetAbsOrigin().x + randomX, self.move_pos:GetAbsOrigin().y + randomY, self.move_pos:GetAbsOrigin().z)

        FindClearSpaceForUnit(self:GetCaster(), self.vMove_pos, true)

	end
end