green_bird_explode = class({})

function green_bird_explode:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function green_bird_explode:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        self.radius = 150
        self.damage = 90

        -- play explode effect
        local particle_cast = "particles/timber/droid_stun_grimstroke_ink_swell_aoe.vpcf"
        local sound_target = "Hero_TemplarAssassin.Trap.Explode"

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.radius, self.radius, self.radius ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        EmitSoundOn( sound_target, caster )

        -- deal the dmg
        local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

        for _,enemy in pairs(enemies) do
            self.damageTable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(self.damageTable)

		end

        -- killself
        caster:ForceKill(false)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------
