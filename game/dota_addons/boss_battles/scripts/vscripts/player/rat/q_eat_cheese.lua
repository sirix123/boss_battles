q_eat_cheese = class({})

---------------------------------------------------------------------------

function q_eat_cheese:OnSpellStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        -- heal
        self:GetCaster():Heal(self:GetSpecialValueFor( "heal" ), self:GetCaster())

        -- play particle eeffect
        local particle_cast = "particles/econ/events/ti8/mekanism_ti8.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        -- Play effects
        local sound_cast = "DOTA_Item.FaerieSpark.Activate"
        EmitSoundOn( sound_cast, self:GetCaster() )

    end
end