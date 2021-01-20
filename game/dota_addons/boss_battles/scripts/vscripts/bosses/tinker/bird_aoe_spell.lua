
bird_aoe_spell = class({})

----------------------------------------------------------------------------------------

function bird_aoe_spell:Precache( context )

	PrecacheResource( "particle", "particles/tinker/fire_bird_aoe_portal_revealed_nothing_good_ring.vpcf", context )

end
--------------------------------------------------------------------------------

function bird_aoe_spell:OnSpellStart()
    self.caster = self:GetCaster()
	self.radius = 300
	self.dmg = 10
    self.damage_interval = 1
    self.stopDamageLoop = false
    self.duration = 10

    self.i = 0

    --DebugDrawCircle(self.caster:GetAbsOrigin(), Vector(0,0,255), 128, self.radius, true, 60)

    Timers:CreateTimer(self.damage_interval, function()
        if IsValidEntity(thisEntity) == false then return false end

	    if self.i == self.duration or self.caster:IsAlive() == false then
		    return false
        end

        local particle_cast = ParticleManager:CreateParticle("particles/tinker/tinker_bird_aoe_stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(particle_cast, 0, self.caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex( particle_cast )

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

        self.i = self.i + 1
		return self.damage_interval
	end)

end
--------------------------------------------------------------------------------
