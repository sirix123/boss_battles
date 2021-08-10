priest_holy_fire_modifier = class({})

function priest_holy_fire_modifier:RemoveOnDeath()
    return true
end

function priest_holy_fire_modifier:IsHidden()
	return false
end

function priest_holy_fire_modifier:IsDebuff()
	return false
end

function priest_holy_fire_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function priest_holy_fire_modifier:OnCreated( kv )
	if IsServer() then

        self.parent = self:GetParent()
        self.caster = self:GetCaster()
		self.parentOrgin = self.parent:GetAbsOrigin()
		self.radius = kv.radius
        self.location = (Vector(kv.target_x,kv.target_y,kv.target_z))

        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_marker.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.particle, 0, self.location )

    end
end
----------------------------------------------------------------------------


function priest_holy_fire_modifier:OnDestroy( kv )
	if IsServer() then

        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle, true)
        end

		-- Play effects
        self:PlayEffects2()

		local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		if units ~= nil and #units ~= 0 then
            for _, unit in pairs(units) do
                self.dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self:GetAbility():GetSpecialValueFor( "dmg_explode" ),
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)

                unit:AddNewModifier(
                    self.caster, -- player source
                    self:GetAbility(), -- ability source
                    "priest_holy_fire_modifier_dot", -- modifier name
                    { duration = self:GetAbility():GetSpecialValueFor( "duration" ) } -- kv
                )

            end
		end

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end
----------------------------------------------------------------------------

function priest_holy_fire_modifier:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_elated_fury_landing.vpcf"
	local sound_cast = "Hero_Leshrac.Split_Earth"

	-- Create Particle
    local particle_aoe_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_aoe_fx, 0, self.location)
    ParticleManager:SetParticleControl(particle_aoe_fx, 1, self.location)
    ParticleManager:ReleaseParticleIndex(particle_aoe_fx)

	-- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end
