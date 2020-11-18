

stun_droid_zap = class({})
LinkLuaModifier( "stun_droid_zap_modifier_thinker", "bosses/timber/stun_droid_zap_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

function stun_droid_zap:OnSpellStart()
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor( "duration" )

    --caster:AddNewModifier(caster, self, "stun_droid_zap_modifier_thinker", {duration = duration})
    CreateModifierThinker(
                caster,
                self,
                "stun_droid_zap_modifier_thinker",
                {
                    duration = duration,
                    target_x = caster:GetAbsOrigin().x,
                    target_y = caster:GetAbsOrigin().y,
                    target_z = caster:GetAbsOrigin().z,
                },
                caster:GetAbsOrigin(),
                caster:GetTeamNumber(),
                false
            )

    self:PlayEffects()

end
----------------------------------------------------------------------------------------------------------------

function stun_droid_zap:PlayEffects()

    local particle_cast = "particles/timber/droid_stun_sven_spell_gods_strength.vpcf"
    local sound_cast = "Hero_StormSpirit.Attack"

    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    EmitSoundOn( sound_cast, self:GetCaster() )
end