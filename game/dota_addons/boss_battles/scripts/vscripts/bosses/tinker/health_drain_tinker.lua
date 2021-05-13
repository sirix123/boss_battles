health_drain_tinker = class({})
LinkLuaModifier( "mana_drain_root_modifier", "bosses/tinker/modifiers/mana_drain_root_modifier", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "attack_interupt", "bosses/tinker/modifiers/attack_interupt", LUA_MODIFIER_MOTION_NONE  )

function health_drain_tinker:OnAbilityPhaseStart()
    if IsServer() then

        self.hTargetPos = self:GetCursorTarget()

        if self.hTargetPos == nil then
            return false
        end

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "mana_drain_root_modifier", { duration = -1 } )

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "attack_interupt", { duration = -1 } )

        self:PlayEffects()

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function health_drain_tinker:OnAbilityPhaseInterrupted()
    if IsServer() then

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

    end
end

function health_drain_tinker:OnChannelFinish(bInterrupted)
    if IsServer() then

        if self:GetCaster():HasModifier("mana_drain_root_modifier") then
            self:GetCaster():RemoveModifierByName("mana_drain_root_modifier")
        end

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

    end
end

---------------------------------------------------------------------------

function health_drain_tinker:OnSpellStart()
    if not IsServer() then return end
    if not self:IsChanneling() then return end

end
---------------------------------------------------------------------------------------------------------------------------------------

function health_drain_tinker:OnChannelThink( interval )
    if not IsServer() then return end

    self.time = (self.time or 0) + interval
    local myInterval = 1

    if self:GetCaster():HasModifier("attack_interupt") == false then
        self:StartCooldown(self:GetCooldown(self:GetLevel()))
        self:GetCaster():InterruptChannel()
        if self.particle_drain_fx then
            ParticleManager:DestroyParticle(self.particle_drain_fx,true)
        end
    end

    if self.time >= myInterval then

        self:GetCaster():Heal( self:GetCaster():GetMaxHealth() * 0.02, self:GetCaster())
        BossNumbersOnTarget(self:GetCaster(), self:GetCaster():GetMaxHealth() * 0.02, Vector(75,255,75))

        self.time = self.time - myInterval
    end

end
---------------------------------------------------------------------------------------------------------------------------------------

function health_drain_tinker:PlayEffects()
    if IsServer() then
        -- Get Resources
        --local particle_cast = "particles/timber/droid_smelter_lion_spell_mana_drain.vpcf"
        self.particle_drain = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"

        self.particle_drain_fx = ParticleManager:CreateParticle(self.particle_drain, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self.hTargetPos, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hTargetPos:GetAbsOrigin(), true)
    end
end
