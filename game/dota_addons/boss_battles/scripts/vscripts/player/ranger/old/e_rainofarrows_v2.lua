e_rainofarrows_v2 = class({})
LinkLuaModifier("e_rain_of_arrows_modifier", "player/ranger/modifiers/e_rain_of_arrows_modifier", LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------

function e_rainofarrows_v2:OnSpellStart()
    if IsServer() then

        self.caster = self:GetCaster()

        -- effect
        self.nfx = "particles/ranger/r_metamorph_terrorblade_metamorphosis_transform.vpcf"
        local effect_cast = ParticleManager:CreateParticle(self.nfx, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, Vector(0,0,0))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        -- emit sound
        EmitSoundOn("windrunner_wind_pain_01", self.caster)

        local base_duration = self:GetSpecialValueFor( "base_duration" )

        self.caster:AddNewModifier(self.caster, self, "e_rain_of_arrows_modifier", {duration = base_duration})

    end
end