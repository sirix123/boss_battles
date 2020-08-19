q_warlord_shout = class({})

LinkLuaModifier( "q_warlord_shout_modifier", "player/warlord/modifiers/q_warlord_shout_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function q_warlord_shout:OnAbilityPhaseStart()

	local sound_cast = "Hero_Axe.BerserkersCall.Start"
	EmitSoundOn( sound_cast, self:GetCaster() )

	return true 
end
---------------------------------------------------------------------------

function q_warlord_shout:OnAbilityPhaseInterrupted()

	local sound_cast = "Hero_Axe.BerserkersCall.Start"
    StopSoundOn( sound_cast, self:GetCaster() )

end
---------------------------------------------------------------------------

function q_warlord_shout:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local point = caster:GetOrigin()

        -- if 1-2 stacks of rage

        -- if 3-4 stacks of rage

        -- if 5 stacks of rage

        --[[ load data
        local duration = self:GetSpecialValueFor( "duration" )

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_sprint", -- modifier name
            { duration = duration } -- kv
        )]]

        -- sound effect
        local sound_cast = "Hero_Axe.Berserkers_Call"
        EmitSoundOn( sound_cast, self:GetCaster() )

        -- particle effect
	    local particle_cast = "particles/warlord/warlord_shout_axe_ti9_beserkers_call_owner.vpcf"

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