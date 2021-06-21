m2_direct_heal_modifier_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function m2_direct_heal_modifier_thinker:IsHidden()
	return true
end

function m2_direct_heal_modifier_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function m2_direct_heal_modifier_thinker:OnCreated( kv )
    if IsServer() then

        --init
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
		self.parentOrgin = self.parent:GetAbsOrigin()
		self.radius = kv.radius
        self.location = (Vector(kv.target_x,kv.target_y,kv.target_z))

	end
end

function m2_direct_heal_modifier_thinker:OnDestroy( kv )
	if IsServer() then

		-- Play effects
        self:PlayEffects2()

		local friendlies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		if friendlies ~= nil and #friendlies ~= 0 then

			if #friendlies == 1 then
				friendlies[1]:Heal(self:GetAbility():GetSpecialValueFor( "heal" ),self.caster)
			else
				for _, friend in pairs(friendlies) do
					friend:Heal( ( self:GetAbility():GetSpecialValueFor( "heal" ) / #friendlies ) ,self.caster)
				end
			end
		end

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------

function m2_direct_heal_modifier_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
	local sound_cast = "Hero_Omniknight.Purification"

	-- Create Particle
    local particle_aoe_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_aoe_fx, 0, self.location)
    ParticleManager:SetParticleControl(particle_aoe_fx, 1, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(particle_aoe_fx)

	-- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end