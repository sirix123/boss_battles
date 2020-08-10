summone_flame_turret_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function summone_flame_turret_thinker:IsHidden()
	return true
end

function summone_flame_turret_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function summone_flame_turret_thinker:OnCreated( kv )
	if IsServer() then

        --init
        self.parent = self:GetParent()
        self.parentOrgin = self.parent:GetAbsOrigin()
		self.turret = "npc_flame_turret"
		self.direction_x = kv.direction_x
		self.direction_y = kv.direction_y

		-- Play effects
		self:PlayEffects1()
	end
end

function summone_flame_turret_thinker:OnDestroy( kv )
	if IsServer() then

		-- Play effects
        self:PlayEffects2()

        -- summon turret
		self.spawnedTurret = CreateUnitByName( self.turret, self.parentOrgin, true, nil, nil, DOTA_TEAM_BADGUYS)
		-- face direction
		self.spawnedTurret:SetForwardVector(Vector(self.direction_x,self.direction_y, self.spawnedTurret:GetForwardVector().z ))

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function summone_flame_turret_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf"
	local sound_cast = "Hero_Rattletrap.Power_Cogs"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end
--------------------------------------------------------------------------------

function summone_flame_turret_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf"
	--local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    --EmitSoundOn(sound_cast,self.parent)
end