root_thinker_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function root_thinker_modifier:IsHidden()
	return true
end

function root_thinker_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function root_thinker_modifier:OnCreated( kv )
	if IsServer() then

        --init
        self.parent = self:GetParent()
        self.parentOrgin = self.parent:GetAbsOrigin()
		self.pos_x = kv.pos_x
		self.pos_y = kv.pos_y
        self.radius = 120

        self.pos = Vector(self.pos_x,self.pos_y,self.parent:GetAbsOrigin().z)

		-- Play effects
		self:PlayEffects1()
	end
end

function root_thinker_modifier:OnDestroy( kv )
	if IsServer() then

		-- Play effects
        self:PlayEffects2()

        local units = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.pos,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units ~= nil or #units ~= 0 then
            for _, unit in pairs(units) do
                unit:AddNewModifier( self.parent, nil, "modifier_rooted_clock", { duration = 3 } )
            end
        end

        if self.particle_effect_rock_spawn then
            ParticleManager:DestroyParticle(self.particle_effect_rock_spawn,true)
        end

	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function root_thinker_modifier:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/custom/swirl/clock_green_dota_swirl.vpcf"
	local sound_cast = "Hero_Rattletrap.Power_Cogs"

	-- Create Particle
    self.particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(self.particle_effect_rock_spawn, 0, self.pos )

    -- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end
--------------------------------------------------------------------------------

function root_thinker_modifier:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/clock/bigger_abaddon_death_coil_alliance_explosion.vpcf"
	--local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.pos )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    --EmitSoundOn(sound_cast,self.parent)
end