q_warlord_dps_stance = class({})
LinkLuaModifier( "q_warlord_dps_stance_modifier", "player/warlord/modifiers/q_warlord_dps_stance_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function q_warlord_dps_stance:OnAbilityPhaseStart()


	return true
end
---------------------------------------------------------------------------

function q_warlord_dps_stance:OnAbilityPhaseInterrupted()


end
---------------------------------------------------------------------------


function q_warlord_dps_stance:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local point = caster:GetOrigin()

        -- remove def stance
        caster:RemoveModifierByName("q_warlord_def_stance_modifier_bubble")

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "q_warlord_dps_stance_modifier", -- modifier name
            {} -- kv
        )

        -- swap ability to dps stance
        caster:SwapAbilities("q_warlord_def_stance", "q_warlord_dps_stance", true, false)

        -- sound effect
        local sound_cast = "Hero_Sven.PreAttack"

        -- Create Sound
        EmitSoundOn( sound_cast, self:GetCaster() )

        -- particle effect
	    local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_beserkers_call_owner.vpcf"

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl(effect_cast, 0, Vector(0,0,0))
        ParticleManager:SetParticleControlEnt(
            effect_cast,
            1,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            "attach_head",
            Vector(0,0,0),
            true
        )
        ParticleManager:ReleaseParticleIndex( effect_cast )

    end
end