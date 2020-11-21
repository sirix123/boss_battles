timber_blast_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function timber_blast_thinker:IsHidden()
	return true
end

function timber_blast_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function timber_blast_thinker:OnCreated( kv )
    if IsServer() then

        --init
        self.parent = self:GetParent()
		self.parentOrgin = self.parent:GetAbsOrigin()
		self.radius = kv.radius

		-- Play effects
		self:PlayEffects1()
	end
end

function timber_blast_thinker:OnDestroy( kv )
	if IsServer() then

		-- Play effects
        self:PlayEffects2()
		GridNav:DestroyTreesAroundPoint( self.parentOrgin, self.radius, true )

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
				damage = 500,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}

			ApplyDamage( self.damageTable )
		end

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function timber_blast_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_team_immortal1.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Charge"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end
--------------------------------------------------------------------------------

function timber_blast_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end