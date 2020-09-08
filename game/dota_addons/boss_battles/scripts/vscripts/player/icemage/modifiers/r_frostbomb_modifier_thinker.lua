
r_frostbomb_modifier_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function r_frostbomb_modifier_thinker:IsHidden()
	return true
end

function r_frostbomb_modifier_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function r_frostbomb_modifier_thinker:OnCreated( kv )
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.delay =  self:GetAbility():GetSpecialValueFor( "delay" )

        -- reference from kv
        self.fb_bse_dmg = kv.fb_bse_dmg
        self.damage_interval = kv.damage_interval
        self.fb_dmg_per_shatter_stack = kv.fb_dmg_per_shatter_stack
        self.nStackCount = kv.nStackCount
        self.damage_type = kv.damage_type
        self.dot_duration = kv.dot_duration

		-- Play effects
		self:PlayEffects1()
	end
end

function r_frostbomb_modifier_thinker:OnDestroy( kv )
	if IsServer() then

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(self:GetCaster(), self, "r_frostbomb_modifier",
            {
                duration = self.dot_duration,
                fb_bse_dmg = self.fb_bse_dmg,
                damage_interval = self.damage_interval,
                nStackCount = self.nStackCount,
                fb_dmg_per_shatter_stack = self.fb_dmg_per_shatter_stack,
                damage_type = self.damage_type
            })

			if CheckRaidTableForBossName(enemy) ~= true then
				--enemy:AddNewModifier(self.caster, self, "chill_modifier", { duration = self:GetAbility():GetSpecialValueFor( "chill_duration") })
			end

		end

        -- Play effects
		self:PlayEffects2()

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function r_frostbomb_modifier_thinker:PlayEffects1()

	local sound_cast = "Hero_Invoker.SunStrike.Charge"
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )

	local explosion_particle = "particles/icemage/icemage__frostbomb_ancient_apparition_ice_blast_final.vpcf"
	local particle = ParticleManager:CreateParticle(explosion_particle, PATTACH_WORLDORIGIN, self:GetCaster())

	-- distance vector between thinker origin and frostbomb particle effect spawn
	local particleZAxisSpawn = 800
	local dist = Vector(self.parent:GetAbsOrigin().x, self.parent:GetAbsOrigin().y, particleZAxisSpawn) - self.parent:GetAbsOrigin()
	local velocity = Vector(0, 0, dist.z / self.delay)
	velocity = velocity * -1

	-- particle start point
	ParticleManager:SetParticleControl(particle, 0, Vector(self.parent:GetAbsOrigin().x, self.parent:GetAbsOrigin().y, particleZAxisSpawn))
	-- particle velocity
	ParticleManager:SetParticleControl(particle, 1, velocity)
	-- particle duration
	ParticleManager:SetParticleControl(particle, 5, Vector(self.delay, 0, 0))

	ParticleManager:ReleaseParticleIndex(particle)

end

function r_frostbomb_modifier_thinker:PlayEffects2()

	local sound_cast = "Hero_Ancient_Apparition.IceBlast.Target"
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )

	local explosion_particle = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf"
	local particle = ParticleManager:CreateParticle(explosion_particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 3, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

end
