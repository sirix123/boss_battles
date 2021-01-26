r_explosive_tip_explode = class({})
---------------------------------------------------------------------------

function r_explosive_tip_explode:OnSpellStart()
    if IsServer() then

        self.caster = self:GetCaster()

        -- effect
        self.nfx = "particles/ranger/r_metamorph_terrorblade_metamorphosis_transform.vpcf"
        local effect_cast = ParticleManager:CreateParticle(self.nfx, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, Vector(0,0,0))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        -- emit sound
        EmitSoundOn("windrunner_wind_pain_01", self.caster)

        local enemies = FindUnitsInRadius(
            self.caster:GetTeam(),
            self.caster:GetOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false
        )

        if enemies ~= nil then
            for _, enemy in pairs(enemies) do
                if enemy:HasModifier("r_explosive_tip_modifier_target") then
                    enemy:RemoveModifierByNameAndCaster("r_explosive_tip_modifier_target", self.caster)
                end
            end
        end

        --self.caster:SwapAbilities("r_explosive_tip_explode", "r_explosive_tip", false, true)

    end
end