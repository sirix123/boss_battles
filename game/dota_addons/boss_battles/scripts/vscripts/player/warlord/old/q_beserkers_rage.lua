q_beserkers_rage = class({})
LinkLuaModifier( "q_berserkers_rage_modifier", "player/warlord/modifiers/q_berserkers_rage_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function q_beserkers_rage:OnAbilityPhaseStart()


	return true
end
---------------------------------------------------------------------------

function q_beserkers_rage:OnAbilityPhaseInterrupted()


end
---------------------------------------------------------------------------


function q_beserkers_rage:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local point = caster:GetOrigin()
        local duration = self:GetSpecialValueFor( "duration" )

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "q_berserkers_rage_modifier", -- modifier name
            { duration = duration} -- kv
        )

        -- sound effect
        local sound_cast = "Hero_Sven.PreAttack"

        -- rage sound sounds/weapons/hero/bloodseeker/rage.vsnd

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