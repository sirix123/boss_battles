blue_droid_death_modifier = class({})

LinkLuaModifier( "stun_droid_zap_modifier_thinker", "bosses/timber/stun_droid_zap_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )
-----------------------------------------------------------------------------

function blue_droid_death_modifier:RemoveOnDeath()
    return true
end

function blue_droid_death_modifier:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function blue_droid_death_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function blue_droid_death_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
end


function blue_droid_death_modifier:OnDestroy()
    if not IsServer() then return nil end

    --local duration = self:GetSpecialValueFor( "duration" )
    local ability = self:GetParent():FindAbilityByName( "stun_droid_zap" )
    local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel())
    local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel())
	local base_stun = ability:GetLevelSpecialValueFor("debuff_duration", ability:GetLevel())

    --caster:AddNewModifier(caster, self, "stun_droid_zap_modifier_thinker", {duration = duration})
    CreateModifierThinker(
                self:GetParent(),
                self,
                "stun_droid_zap_modifier_thinker",
                {
                    duration = duration,
                    radius = radius,
                    base_stun = base_stun,
                    target_x = self:GetParent():GetAbsOrigin().x,
                    target_y = self:GetParent():GetAbsOrigin().y,
                    target_z = self:GetParent():GetAbsOrigin().z,
                },
                self:GetParent():GetAbsOrigin(),
                self:GetParent():GetTeamNumber(),
                false
            )

    local particle_cast = "particles/timber/droid_stun_sven_spell_gods_strength.vpcf"
    local sound_cast = "Hero_StormSpirit.StaticRemnantPlant"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( sound_cast, self:GetParent() )

    --self:PlayEffects()
end


