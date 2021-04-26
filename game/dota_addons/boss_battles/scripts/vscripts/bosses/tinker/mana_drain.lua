mana_drain = class({})
LinkLuaModifier( "mana_drain_root_modifier", "bosses/tinker/modifiers/mana_drain_root_modifier", LUA_MODIFIER_MOTION_NONE  )

function mana_drain:OnAbilityPhaseStart()
    if IsServer() then

        self.hTargetPos = self:GetCursorTarget()

        if self.hTargetPos == nil then
            return false
        end

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "mana_drain_root_modifier", { duration = -1 } )

        self.mana = 1.4

        self:PlayEffects()

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function mana_drain:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end

function mana_drain:OnChannelFinish(bInterrupted)
    if IsServer() then

        if self:GetCaster():HasModifier("mana_drain_root_modifier") then
            self:GetCaster():RemoveModifierByName("mana_drain_root_modifier")
        end

        ParticleManager:DestroyParticle(self.effect_cast,true)

    end
end

---------------------------------------------------------------------------

function mana_drain:OnSpellStart()
    if not IsServer() then return end
    if not self:IsChanneling() then return end

end
---------------------------------------------------------------------------------------------------------------------------------------

function mana_drain:OnChannelThink( interval )
    if not IsServer() then return end

    self.time = (self.time or 0) + interval
    local myInterval = 1

    if self.time >= myInterval then

        self:GetCaster():GiveMana(self.mana)
        BossNumbersOnTarget(self:GetCaster(), self.mana, Vector(75,75,255))

        self.hTargetPos:ReduceMana(self.mana)

        self.time = self.time - myInterval
    end

end
---------------------------------------------------------------------------------------------------------------------------------------

function mana_drain:PlayEffects()
    if IsServer() then
        -- Get Resources
        --local particle_cast = "particles/timber/droid_smelter_lion_spell_mana_drain.vpcf"
        local particle_cast = "particles/tinker/tinker_wisp_tether_agh.vpcf"

        -- Create Particle
        self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.hTargetPos )
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            1,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            "attach_rocket",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            0,
            self.hTargetPos,
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )

    end
end
