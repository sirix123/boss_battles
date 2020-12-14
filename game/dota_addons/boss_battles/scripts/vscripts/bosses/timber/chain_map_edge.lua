LinkLuaModifier( "chain_modifier", "bosses/timber/chain_modifier", LUA_MODIFIER_MOTION_HORIZONTAL )

chain_map_edge = class({})

function chain_map_edge:OnAbilityPhaseStart()
    if IsServer() then
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.4)

		self.vTargetPos = self:GetCursorPosition()

        return true
    end
end

-- Ability Start
function chain_map_edge:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)

	self:GetCaster():SetForwardVector(self.vTargetPos)
	self:GetCaster():FaceTowards(self.vTargetPos)

	-- load data
	local projectile_speed = self:GetSpecialValueFor( "speed" )
	local projectile_distance = self:GetSpecialValueFor( "range" )
	local projectile_radius = self:GetSpecialValueFor( "radius" )
	local projectile_direction = self.vTargetPos-caster:GetAbsOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	local tree_radius = self:GetSpecialValueFor( "chain_radius" )
	local vision = 100

	-- create effect
	local effect = self:PlayEffects( caster:GetOrigin() + projectile_direction * projectile_distance, projectile_speed, projectile_distance/projectile_speed )
		--[[
	local timber_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_shredder/shredder_timberchain.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(timber_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(timber_particle, 1, self:GetCaster():GetAbsOrigin() + ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * (self:GetTalentSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus())))
	ParticleManager:SetParticleControl(timber_particle, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0 ))
	ParticleManager:SetParticleControl(timber_particle, 3, Vector(((self:GetTalentSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed")) * 2, 0, 0 ))
]]

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    EffectName = "",
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = vision,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}

	-- play random sound effect on cast
	local tSoundEffects =
	{
		"shredder_timb_timberchain_02",
		"shredder_timb_timberchain_05",
		"shredder_timb_timberchain_07",
		"shredder_timb_timberchain_09"
	}

	EmitSoundOn(tSoundEffects[ RandomInt( 1, #tSoundEffects ) ], caster)


	-- register projectile
	local projectile = ProjectileManager:CreateLinearProjectile(info)
	local ExtraData = {
		effect = effect,
		radius = tree_radius,
	}
	self.projectiles[ projectile ] = ExtraData
end
--------------------------------------------------------------------------------
-- Projectile
chain_map_edge.projectiles = {}
function chain_map_edge:OnProjectileThinkHandle( handle )
	-- get data
	local ExtraData = self.projectiles[ handle ]
	local location = ProjectileManager:GetLinearProjectileLocation( handle )
	local dist = (location - Vector(self.vTargetPos.x,self.vTargetPos.y,self.vTargetPos.z)):Length2D()

	if dist < 150 then
		-- snag
		self:GetCaster():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"chain_modifier", -- modifier name
			{
				point_x = self.vTargetPos.x,
				point_y = self.vTargetPos.y,
				point_z = self.vTargetPos.z,
				effect = ExtraData.effect,
			} -- kv
		)

		-- modify effects
		self:ModifyEffects2( ExtraData.effect, self.vTargetPos )

		-- destroy projectile
		ProjectileManager:DestroyLinearProjectile( handle )
		self.projectiles[ handle ] = nil

		-- add vision
		AddFOWViewer( self:GetCaster():GetTeamNumber(), self.vTargetPos, 400, 1, true )
	end
end

function chain_map_edge:OnProjectileHitHandle( target, location, handle )
	local ExtraData = self.projectiles[ handle ]
	if not ExtraData then return end

	-- add vision
	AddFOWViewer( self:GetCaster():GetTeamNumber(), location, 400, 0.1, true )

	-- play effect
	self:ModifyEffects1( ExtraData.effect )

	-- destroy reference
	self.projectiles[ handle ] = nil
end

--------------------------------------------------------------------------------
function chain_map_edge:PlayEffects( point, speed, duration )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_shredder/shredder_timberchain.vpcf"
	local sound_cast = "Hero_Shredder.TimberChain.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		self:GetCaster():GetAbsOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( duration*2 + 0.3, 0, 0 ) )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )

	--[[
	local timber_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_shredder/shredder_timberchain.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(timber_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(timber_particle, 1, self:GetCaster():GetAbsOrigin() + ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * (self:GetTalentSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus())))
	ParticleManager:SetParticleControl(timber_particle, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0 ))
	ParticleManager:SetParticleControl(timber_particle, 3, Vector(((self:GetTalentSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed")) * 2, 0, 0 ))
]]
	return effect_cast
end

function chain_map_edge:ModifyEffects1( effect )
	-- retract
	ParticleManager:SetParticleControlEnt(
		effect,
		1,
		self:GetCaster(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect )

	-- play sound
	local sound_cast = "Hero_Shredder.TimberChain.Retract"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function chain_map_edge:ModifyEffects2( effect, point )
	-- set particle location
	ParticleManager:SetParticleControl( effect, 1, point )

	-- increase effect duration
	ParticleManager:SetParticleControl( effect, 3, Vector( 20, 0, 0 ) )

	-- play sound
	local sound_cast = "Hero_Shredder.TimberChain.Retract"
	local sound_target = "Hero_Shredder.TimberChain.Impact"
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOnLocationWithCaster( point, sound_target, self:GetCaster() )
end
