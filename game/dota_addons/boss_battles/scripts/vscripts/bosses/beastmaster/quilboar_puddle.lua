
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

		--[[ mark target (particle)
		local particle = "particles/beastmaster/quillboar_overhead_icon.vpcf"
		self.head_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.hTarget)
		ParticleManager:SetParticleControl(self.head_particle, 0, self.hTarget:GetAbsOrigin())]]

		local particle = "particles/custom/sirix_mouse/range_finder_cone.vpcf"
		self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		self.stop_timer = false

		ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
		ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(100,100,0)) -- line width
		ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(0,255,0)) -- colour

		Timers:CreateTimer(function()

			if self.stop_timer == true then
				return false
			end

			self.vTargetPos = self.hTarget:GetAbsOrigin()

			ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
			ParticleManager:SetParticleControl(self.particleNfx , 2, self.vTargetPos) -- target

			return FrameTime()
		end)

		self:GetCaster():SetForwardVector(self.hTarget:GetAbsOrigin())
		self:GetCaster():FaceTowards(self.hTarget:GetAbsOrigin())

        return true
    end
end
---------------------------------------------------------------------------

function quilboar_puddle:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle(self.particleNfx, true)
	end
end

function quilboar_puddle:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function quilboar_puddle:OnSpellStart()
	if IsServer() then
		self.stop_timer = true

		ParticleManager:DestroyParticle(self.particleNfx, true)

		self:GetCaster():SetForwardVector(self.hTarget:GetAbsOrigin())
		self:GetCaster():FaceTowards(self.hTarget:GetAbsOrigin())

		self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()
		self.point = self.hTarget:GetAbsOrigin()

		local direction = (self.point - origin):Normalized()
		local distance = (self.point - origin):Length2D()

		local projectile = {
			EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,0),
			fDistance = distance,
			fUniqueRadius = 100,--200
			Source = caster,
			vVelocity = direction * self.projectile_speed,
			UnitBehavior = PROJECTILES_DESTROY,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_DESTROY,
			GroundBehavior = PROJECTILES_NOTHING,
			fGroundOffset = 256,
			UnitTest = function(_self, unit)
				return unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit ~= nil
			end,
			OnUnitHit = function(_self, unit)
				CreateModifierThinker( self:GetCaster(), self, "quillboar_puddle_modifier", { self:GetSpecialValueFor( "duration" ) }, unit:GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
				self:PlayEffects(unit:GetAbsOrigin())
			end,
			OnFinish = function(_self, pos)
				CreateModifierThinker( self:GetCaster(), self, "quillboar_puddle_modifier", { self:GetSpecialValueFor( "duration" ) }, pos, self:GetCaster():GetTeamNumber(), false )
				self:PlayEffects(pos)
			end,
		}

		Projectiles:CreateProjectile(projectile)

		-- sound effect
		caster:EmitSound("Beastmaster_Boar.Attack")

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
