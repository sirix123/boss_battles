space_shadowstep_teleport_back = class({})

function space_shadowstep_teleport_back:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function space_shadowstep_teleport_back:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_shadowstep_teleport_back:OnSpellStart()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        local caster = self:GetCaster()

        -- add modifier
        caster:RemoveModifierByName("space_shadowstep_caster_modifier")

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

        -- swap to next ability
        caster:SwapAbilities("space_shadowstep_teleport_back", "space_shadowstep", false, true)

    end
end