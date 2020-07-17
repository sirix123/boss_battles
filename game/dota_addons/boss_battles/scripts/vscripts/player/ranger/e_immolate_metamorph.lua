e_immolate_metamorph = class({})
LinkLuaModifier( "e_immolate_metamorph_modifier", "player/ranger/modifiers/e_immolate_metamorph_modifier", LUA_MODIFIER_MOTION_NONE )

function e_immolate_metamorph:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_immolate_metamorph:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_immolate_metamorph:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()
        self.caster:AddNewModifier(self.caster, self, "e_immolate_metamorph_modifier", {duration = self:GetSpecialValueFor( "duration")})

    end
end