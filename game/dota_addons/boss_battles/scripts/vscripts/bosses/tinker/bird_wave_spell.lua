
bird_wave_spell = class({})

----------------------------------------------------------------------------------------

function bird_wave_spell:Precache( context )

	PrecacheResource( "particle", "particles/tinker/fire_bird_aoe_portal_revealed_nothing_good_ring.vpcf", context )

end
--------------------------------------------------------------------------------

function bird_wave_spell:OnSpellStart()
    self.caster = self:GetCaster()
	self.radius = 200
	self.dmg = self:GetSpecialValueFor( "dmg" )
    self.damage_interval = 1
    self.stopDamageLoop = false
    self.duration = 12

    --[[local particle_cast = "particles/custom/tinker_blast_wave/tinker_blast_wave.vpcf"
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector(0,500,0) )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )]]

    local particle_cast = "particles/custom/gyro_expand_circle/gyro_expand_circle.vpcf"
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector(1500,0,0) )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )

    local projectile_speed = 500
    local vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
    local projectile_direction = (Vector( vTargetPos.x - self.caster:GetAbsOrigin().x, vTargetPos.y - self.caster:GetAbsOrigin().y, 0 )):Normalized()

    local projectile = {
        EffectName = "particles/custom/tinker_blast_wave/tinker_blast_wave.vpcf",
        vSpawnOrigin = self.caster:GetAbsOrigin() + Vector(0, 0, 100),
        fDistance = 5000,
        fUniqueRadius = 50,
        Source = self.caster,
        vVelocity = projectile_direction * projectile_speed,
        UnitBehavior = PROJECTILES_DESTROY,
        TreeBehavior = PROJECTILES_DESTROY,
        WallBehavior = PROJECTILES_DESTROY,
        GroundBehavior = PROJECTILES_NOTHING,
        fGroundOffset = 80,
        UnitTest = function(_self, unit)
            return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
        end,
        OnUnitHit = function(_self, unit)
        end,
        OnFinish = function(_self, pos)
        end,
    }

    Projectiles:CreateProjectile(projectile)

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
