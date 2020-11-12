elec_explode = class({})

function elec_explode:OnAbilityPhaseStart()
	if IsServer() then

		local radius = 200
		self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
		ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

        self:PlayEffects1()
        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function elec_explode:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        self.radius = 150
        self.damage = self:GetSpecialValueFor( "dmg" )

        -- end particle effect
        ParticleManager:DestroyParticle(self.effect_cast,true)

        -- play explode effect
        local particle_cast = "particles/tinker/tinker_elecvoid_spirit_taunt_impact_shockwave.vpcf"
        local sound_target = "Hero_Alchemist.UnstableConcoction.Stun"

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex( effect_cast )

        EmitSoundOn( sound_target, caster )

        -- deal the dmg
        local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

        for _,enemy in pairs(enemies) do
            self.damageTable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(self.damageTable)

		end

        -- killself
        caster:ForceKill(false)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function elec_explode:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/timber/droid_stun_zap_grimstroke_ink_swell_buff.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( self.radius, self.radius, self.radius ) )
	--[[ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		3,
		self:GetCaster(),
		PATTACH_ABSORIGIN_FOLLOW,
		nil,
		self:GetCaster():GetAbsOrigin(), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:GetCaster():AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		true
	)]]
end