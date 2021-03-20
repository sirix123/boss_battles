
quilboar_puddle = class({})
LinkLuaModifier( "quillboar_puddle_modifier", "bosses/beastmaster/quillboar_puddle_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "puddle_slow_modifier", "bosses/beastmaster/puddle_slow_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function quilboar_puddle:OnAbilityPhaseStart()
    if IsServer() then

		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.5)

		self.hTargetPos = nil
		if self:GetCursorTarget() then
			self.hTarget = self:GetCursorTarget()
		end

		local particle = "particles/beastmaster/viper_poison_debuff_ti7_drips_beastmaster.vpcf"
		self.particle_1 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.hTarget)
        ParticleManager:SetParticleControl(self.particle_1 , 0, self.hTarget:GetAbsOrigin())

        return true
    end
end
---------------------------------------------------------------------------

function quilboar_puddle:OnAbilityPhaseInterrupted()
	if IsServer() then
		if self.particle_1 then
			ParticleManager:DestroyParticle(self.particle_1,true)
		end
	end
end

function quilboar_puddle:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function quilboar_puddle:OnSpellStart()
	if IsServer() then

		self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		local caster = self:GetCaster()

		-- create projectile
		local info = {
			EffectName = "particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_attack_ti7.vpcf",
			Ability = self,
			iMoveSpeed = self.projectile_speed,
			Source = caster,
			Target = self.hTarget,
			bDodgeable = false,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			bProvidesVision = true,
			iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = 300,
		}

		-- shoot proj
		ProjectileManager:CreateTrackingProjectile( info )

		-- sound effect
		caster:EmitSound("Beastmaster_Boar.Attack")

	end
end

---------------------------------------------------------------------------

function quilboar_puddle:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
		if self.particle_1 then
			ParticleManager:DestroyParticle(self.particle_1,true)
		end
		CreateModifierThinker( self:GetCaster(), self, "quillboar_puddle_modifier", { self:GetSpecialValueFor( "duration" ) }, vLocation, self:GetCaster():GetTeamNumber(), false )
		self:PlayEffects(vLocation)
    end
end
---------------------------------------------------------------------------

function quilboar_puddle:PlayEffects(pos)
	if IsServer() then
		--print("play effects")
		local particle_cast = "particles/beastmaster/puddle_explode_venomancer_venomous_gale_impact.vpcf"
		self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , nil  )
		ParticleManager:SetParticleControl( self.nFXIndex_1, 0, pos )
		ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )
	end
end
