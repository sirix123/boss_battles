
bird_wave_spell = class({})

----------------------------------------------------------------------------------------

function bird_wave_spell:Precache( context )

	PrecacheResource( "particle", "particles/tinker/fire_bird_aoe_portal_revealed_nothing_good_ring.vpcf", context )

end
--------------------------------------------------------------------------------

function bird_wave_spell:OnSpellStart()
    self.caster = self:GetCaster()
	self.radius = 200
	self.dmg = 10
    self.damage_interval = 1
    self.stopDamageLoop = false
    self.duration = 12

    local particle_cast = "particles/tinker/fire_bird_aoe_portal_revealed_nothing_good_ring.vpcf"
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.caster:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )

    --DebugDrawCircle(self.caster:GetAbsOrigin(), Vector(0,0,255), 128, self.radius, true, 60)

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),	-- int, your team number
        self.caster:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, enemy in pairs(enemies) do
        local dmgTable = {
            victim = enemy,
            attacker = self:GetCaster(),
            damage = self.dmg,
            damage_type = DAMAGE_TYPE_PHYSICAL,
        }

        ApplyDamage(dmgTable)
    end


end
--------------------------------------------------------------------------------
