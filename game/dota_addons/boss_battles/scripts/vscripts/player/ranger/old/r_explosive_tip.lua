r_explosive_tip = class({})
LinkLuaModifier( "r_explosive_tip_modifier", "player/ranger/modifiers/r_explosive_tip_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function r_explosive_tip:OnSpellStart()
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

        self.caster:AddNewModifier(self.caster, self, "r_explosive_tip_modifier", {duration = base_duration})

        self.caster:SwapAbilities("r_explosive_tip", "r_explosive_tip_explode", false, true)

    end
end