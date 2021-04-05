gyro_barrage = class ({})

function gyro_barrage:OnCreated( kv )

    self.radius = 250
    self.tick_rate = self:GetAbility():GetSpecialValueFor("barrage_tick_rate")
    self.dmg = self:GetAbility():GetSpecialValueFor("barrage_dmg")
    self.particle_attach = {"attach_attack1", "attach_attack2"}

	if IsServer() then
		-- Start interval
        self:GetParent():EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")

		self:StartIntervalThink( self.tick_rate )
	end
end

----------------------------------------------------------------------------------------------------------------

function gyro_barrage:OnIntervalThink()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetCaster():GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
        enemy:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Impact")

        self.barrage_particle	= ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_rocket_barrage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.barrage_particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, self.particle_attach[RandomInt(1, #self.particle_attach)], self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.barrage_particle, 1, enemy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(self.barrage_particle)

        self.damageTable = {
            victim = enemy,
            attacker = self:GetCaster(),
            damage = self.dmg / #enemies,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }

        ApplyDamage( self.damageTable )
	end
end
----------------------------------------------------------------------------------------------------------------

function gyro_barrage:OnDestroy( kv )
	if IsServer() then
        self:StartIntervalThink(-1)
	end
end
----------------------------------------------------------------------------------------------------------------

function gyro_barrage:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function gyro_barrage:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_1
end
