
-- particle effect
-- 

stun_droid_zap_modifier_thinker = class ({})

function stun_droid_zap_modifier_thinker:OnCreated( kv )
	-- references
	self.interval = 0.1
	self.radius = kv.radius
	self.base_stun = kv.base_stun
	self.vLocation = Vector( kv.target_x, kv.target_y, kv.target_z )

	if IsServer() then
		-- Start interval
		self:StartIntervalThink( self.interval )

		-- play effects
		self:PlayEffects1()
	end
end
----------------------------------------------------------------------------------------------------------------

function stun_droid_zap_modifier_thinker:OnIntervalThink()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self.vLocation,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		if enemy:GetModelName() ~= "invisiblebox" then
			-- play effects
			self:PlayEffects2( enemy )
		end
	end
end
----------------------------------------------------------------------------------------------------------------

function stun_droid_zap_modifier_thinker:OnDestroy( kv )
	if IsServer() then
		-- find enemies
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.vLocation,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		
		for _,enemy in pairs(enemies) do
			-- stun
			enemy:AddNewModifier(
				self:GetParent(), -- player source
				nil, -- ability source
				"modifier_generic_stunned", -- modifier name
				{ duration = self.base_stun } -- kv
			)
		end

		-- play effects
        self:PlayEffects3()
        
        -- destroy droid
        UTIL_Remove( self )
 
	end
end
----------------------------------------------------------------------------------------------------------------

function stun_droid_zap_modifier_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/timber/droid_stun_zap_grimstroke_ink_swell_buff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.radius, self.radius, self.radius ) )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		nil,
		self:GetParent():GetAbsOrigin(), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		true
	)
end
----------------------------------------------------------------------------------------------------------------

function stun_droid_zap_modifier_thinker:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/timber/droid_stun_grimstroke_ink_swell_tick_damage.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

----------------------------------------------------------------------------------------------------------------

function stun_droid_zap_modifier_thinker:PlayEffects3()
	-- Get Resources
    local particle_cast = "particles/timber/droid_stun_grimstroke_ink_swell_aoe.vpcf"
    local sound_target = "Hero_Alchemist.UnstableConcoction.Stun"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.radius, self.radius, self.radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    
    EmitSoundOn( sound_target, self:GetParent() )

    -- kill parent
    --self:GetParent():ForceKill( false )
end
