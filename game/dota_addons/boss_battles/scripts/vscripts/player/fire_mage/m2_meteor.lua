m2_meteor = class({})
LinkLuaModifier( "m2_meteor_fire_weakness", "player/fire_mage/modifiers/m2_meteor_fire_weakness", LUA_MODIFIER_MOTION_NONE )

function m2_meteor:OnAbilityPhaseStart()
    if IsServer() then
        local sound_cast = "Ability.PreLightStrikeArray"
        -- Create Sound
        EmitSoundOnLocationForAllies( self:GetCursorPosition(), sound_cast, self:GetCaster() )

        local particle = "particles/fire_mage/array_meteor_hammer_aoe.vpcf"
        self.indicator_particle = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.indicator_particle, 0, self:GetCursorPosition() )
        ParticleManager:SetParticleControl( self.indicator_particle, 1, Vector( self:GetSpecialValueFor( "radius" ), -self:GetSpecialValueFor( "radius" ), -self:GetSpecialValueFor( "radius" ) ) )

        return true
    end
end
---------------------------------------------------------------------------

function m2_meteor:OnAbilityPhaseInterrupted()
    if IsServer() then
        ParticleManager:DestroyParticle(self.indicator_particle,true)
    end
end
---------------------------------------------------------------------------

function m2_meteor:OnSpellStart()
    if IsServer() then

        ParticleManager:DestroyParticle(self.indicator_particle,true)

        local damage = self:GetSpecialValueFor( "damage" )

        local damageTable = {
            attacker = self:GetCaster(),
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }

        local particle_cast = "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf"

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
        ParticleManager:SetParticleControl( effect_cast, 0, self:GetCursorPosition() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( self:GetSpecialValueFor( "radius" ), 1, 1 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCursorPosition(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self:GetSpecialValueFor( "radius" ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies ~= nil and #enemies ~= 0 then
            for _,enemy in pairs(enemies) do
                damageTable.victim = enemy

                if enemy:HasModifier("m2_meteor_fire_weakness") then
                    damageTable.damage = damage + ( damage * self:GetCaster():FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" ) )
                else
                    damageTable.damage = damage
                end

                ApplyDamage(damageTable)

                enemy:AddNewModifier(self:GetCaster(),self,"m2_meteor_fire_weakness", { duration = self:GetSpecialValueFor( "fire_weakness_duration" ) })
            end
        end

        local particle = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
        self.light_strike = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.light_strike, 0, self:GetCursorPosition() )
        ParticleManager:SetParticleControl( self.light_strike, 1, Vector( self:GetSpecialValueFor( "radius" ), 1, 1 ) )
        ParticleManager:ReleaseParticleIndex(self.light_strike)

        EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Ability.LightStrikeArray", self:GetCaster())

	end
end
----------------------------------------------------------------------------------------------------------------