q_conq_shout = class({})
LinkLuaModifier( "q_conq_shout_modifier", "player/warlord/modifiers/q_conq_shout_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "warlord_modifier_shouts", "player/warlord/modifiers/warlord_modifier_shouts", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function q_conq_shout:OnAbilityPhaseStart()

	return true
end
---------------------------------------------------------------------------

function q_conq_shout:OnAbilityPhaseInterrupted()

end
---------------------------------------------------------------------------


function q_conq_shout:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("radius")
        local generic_shout_duration = caster:FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "generic_shout_duration" )

        caster:AddNewModifier(caster, self, "q_conq_shout_modifier",
        {
            duration = 0.1,
        })

        local friends = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            caster:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
	    )

        -- for friendly in the table add the modifier
        if friends ~= nil and #friends ~= 0 then
            for _,friend in pairs(friends) do

                friend:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "warlord_modifier_shouts", -- modifier name
                    { duration = generic_shout_duration} -- kv
                )

            end
        end

        -- Create Sound
        EmitSoundOn( "Hero_Axe.Berserkers_Call", caster )

        -- particle
        local particle = 'particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf'

        local particle_stomp_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_stomp_fx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(self.radius, 1, 1))
        ParticleManager:SetParticleControl(particle_stomp_fx, 2, Vector(250,0,0))
        ParticleManager:ReleaseParticleIndex(particle_stomp_fx)

    end
end