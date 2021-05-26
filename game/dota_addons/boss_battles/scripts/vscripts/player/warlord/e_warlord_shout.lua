e_warlord_shout = class({})
LinkLuaModifier( "e_warlord_shout_modifier", "player/warlord/modifiers/e_warlord_shout_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "warlord_modifier_shouts", "player/warlord/modifiers/warlord_modifier_shouts", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function e_warlord_shout:OnAbilityPhaseStart()

	return true
end
---------------------------------------------------------------------------

function e_warlord_shout:OnAbilityPhaseInterrupted()

end
---------------------------------------------------------------------------


function e_warlord_shout:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )
        local generic_shout_duration = self:GetSpecialValueFor( "generic_shout_duration" )
        self.radius = self:GetSpecialValueFor( "radius" )

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
                    "e_warlord_shout_modifier", -- modifier name
                    { duration = duration} -- kv
                )

                friend:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "warlord_modifier_shouts", -- modifier name
                    { duration = generic_shout_duration} -- kv
                )

            end
        end

        -- particle
        local particle = 'particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf'
        local particle_stomp_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_stomp_fx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(self.radius, 1, 1))
        ParticleManager:SetParticleControl(particle_stomp_fx, 2, Vector(150,150,0))
        ParticleManager:ReleaseParticleIndex(particle_stomp_fx)

        -- Create Sound
        EmitSoundOn( "Hero_Axe.Berserkers_Call", self:GetCaster() )

    end
end