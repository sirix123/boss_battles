space_evocate = class({})
LinkLuaModifier("evocate_modifier", "player/templar/modifiers/evocate_modifier", LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------

function space_evocate:OnSpellStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.0)

        local particle = "particles/units/heroes/hero_meepo/meepo_burrow.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 2, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        local reduction_per_charge = self:GetCaster():FindAbilityByName("templar_passive"):GetSpecialValueFor( "space_duration_reduction_per_power_charge" )
        local reduction_duration = 0

        local stacks = 0
        if self:GetCaster():HasModifier("templar_power_charge") then
            stacks = self:GetCaster():GetModifierStackCount("templar_power_charge", self:GetCaster())
        end

        reduction_duration = reduction_per_charge * stacks

        local duration = self:GetSpecialValueFor( "duration" ) - reduction_duration

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "evocate_modifier", { duration = duration })

        local sound_cast = "Hero_NyxAssassin.Burrow.In"
        EmitSoundOn( sound_cast, self:GetCaster() )

    end
end