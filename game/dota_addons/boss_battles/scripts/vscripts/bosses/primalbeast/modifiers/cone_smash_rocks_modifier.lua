cone_smash_rocks_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function cone_smash_rocks_modifier:IsHidden()
	return true
end

function cone_smash_rocks_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function cone_smash_rocks_modifier:OnCreated( kv )
    if IsServer() then

        --init
        self.parent = self:GetParent()
		self.parentOrgin = self.parent:GetAbsOrigin()
		self.radius = kv.radius
		self.dmg = kv.damage
		self.z_dist = kv.z_dist

		self.caster = self:GetCaster()
        self.parent = self:GetParent()
		self.delay =  self:GetDuration()

		-- Play effects
		self:PlayEffects1()
	end
end

function cone_smash_rocks_modifier:OnDestroy( kv )
	if IsServer() then

		-- Play effects
        self:PlayEffects2()

		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_ALL,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _, enemy in pairs(enemies) do
			-- apply damage
			self.damageTable = {
				victim = enemy,
				attacker = self:GetParent(),
				damage = self.dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self:GetAbility(),
			}

			ApplyDamage( self.damageTable )
		end

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function cone_smash_rocks_modifier:PlayEffects1()

	local explosion_particle = "particles/icemage/primal_blast_rock.vpcf"
	local particle = ParticleManager:CreateParticle(explosion_particle, PATTACH_WORLDORIGIN, self:GetCaster())

	-- distance vector between thinker origin and frostbomb particle effect spawn
	local particleZAxisSpawn = 1600
	local dist = Vector(self.parent:GetAbsOrigin().x, self.parent:GetAbsOrigin().y, particleZAxisSpawn) - self.parent:GetAbsOrigin()
	local velocity = Vector(0, 0, dist.z / self.delay)
	velocity = velocity * -1

	-- particle indicator

	-- particle start point
	ParticleManager:SetParticleControl(particle, 0, Vector(self.parent:GetAbsOrigin().x, self.parent:GetAbsOrigin().y, particleZAxisSpawn))
	-- particle velocity
	ParticleManager:SetParticleControl(particle, 1, velocity)
	-- particle duration
	ParticleManager:SetParticleControl(particle, 5, Vector(self.delay, 0, 0))

	ParticleManager:ReleaseParticleIndex(particle)
end
--------------------------------------------------------------------------------

function cone_smash_rocks_modifier:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/econ/events/ti10/hot_potato/hot_potato_explode.vpcf"
	-- "particles/timber/timber_invoker_sun_strike.vpcf"
	local sound_cast = "Hero_EarthShaker.Attack"

	self:GetParent():EmitSoundParams(sound_cast, 1, 0.3, 0.0)

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 0, 0, self.radius ) )
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( 0, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end