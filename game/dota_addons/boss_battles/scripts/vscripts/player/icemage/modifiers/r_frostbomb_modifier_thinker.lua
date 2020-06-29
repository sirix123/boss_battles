
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

            enemy:AddNewModifier(self.caster, self, "chill_modifier", { duration = self:GetAbility():GetSpecialValueFor( "chill_duration") })
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
	-- Get Resources
    local particle_cast = "particles/icemage/r_frostbomb_invoker_sun_strike_team_immortal1.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Charge"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationForAllies( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end

function r_frostbomb_modifier_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end
