space_burrow = class({})
LinkLuaModifier("burrow_modifier", "player/rat/modifier/burrow_modifier", LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------

function space_burrow:OnSpellStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.0)

        local particle = "particles/units/heroes/hero_meepo/meepo_burrow.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 2, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)


        self:GetCaster():AddNewModifier(self:GetCaster(), self, "burrow_modifier", { duration = self:GetSpecialValueFor( "duration" ) })

        local sound_cast = "Hero_NyxAssassin.Burrow.In"
        EmitSoundOn( sound_cast, self:GetCaster() )

    end
end