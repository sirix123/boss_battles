channel_tinker_buff_lava_mob = class({})
LinkLuaModifier( "lava_bolt_modifier_stacks", "bosses/tinker/modifiers/lava_bolt_modifier_stacks", LUA_MODIFIER_MOTION_NONE  )

function channel_tinker_buff_lava_mob:OnAbilityPhaseStart()
    if IsServer() then


        self.particle_drain = "particles/econ/items/invoker/ti8_invoker_prism_crystal_spellcaster/ti8_invoker_prism_forge_spirit_ambient.vpcf"

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_FLAIL, 1.0)

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function channel_tinker_buff_lava_mob:OnAbilityPhaseInterrupted()
    if IsServer() then

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

    end
end

function channel_tinker_buff_lava_mob:OnChannelFinish(bInterrupted)
    if IsServer() then

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

        self:GetCaster():FadeGesture(ACT_DOTA_FLAIL)

        if bInterrupted == false then

            --print("killed ",bInterrupted)

            -- add a modifier to tinker...
            -- lava_bolt_modifier_stacks
            self.hTarget = self:GetCursorTarget()
            self.hTarget:AddNewModifier(self:GetCaster(), self, "lava_bolt_modifier_stacks", {duration = -1})

            self:GetCaster():ForceKill(false)
        else

            --print("killed int should be false",bInterrupted)

            return
        end

    end
end

---------------------------------------------------------------------------

function channel_tinker_buff_lava_mob:OnSpellStart()
    if not IsServer() then return end
    if not self:IsChanneling() then return end

end
---------------------------------------------------------------------------------------------------------------------------------------

function channel_tinker_buff_lava_mob:OnChannelThink( interval )
    if not IsServer() then return end

    self.time = (self.time or 0) + interval
    local myInterval = 1

    if self.time >= myInterval then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_FLAIL, 1.0)

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

        self.effect_cast = ParticleManager:CreateParticle(self.particle_drain, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)

        self.time = self.time - myInterval
    end

end
---------------------------------------------------------------------------------------------------------------------------------------
