
cannon_ball = class({})

function cannon_ball:OnAbilityPhaseStart()
    if IsServer() then

        if self:GetCursorPosition() then
			self.vTargetPos = self:GetCursorPosition()
		end

        EmitSoundOn( "Hero_Beastmaster.Wild_Axes", self:GetCaster() )

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

		local particle = "particles/custom/sirix_mouse/range_finder_cone.vpcf"
		self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		self.stop_timer = false

		ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
		ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(125,125,0)) -- line width
		ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

		Timers:CreateTimer(function()

			if self.stop_timer == true then
				return false
			end

			self.distance = ( ( self.vTargetPos - self:GetCaster():GetAbsOrigin() ):Normalized() ) * 700

			ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
			ParticleManager:SetParticleControl(self.particleNfx , 2, self:GetCaster():GetAbsOrigin() + self.distance)  -- target self:GetCaster():GetAbsOrigin() + (direction * 1600) self.vTargetPos

			return FrameTime()
		end)

        return true
    end
end
---------------------------------------------------------------------------

function cannon_ball:OnAbilityPhaseInterrupted()
	if IsServer() then

		self.stop_timer = true

        -- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		ParticleManager:DestroyParticle(self.particleNfx, true)

    end
end
---------------------------------------------------------------------------

function cannon_ball:OnSpellStart()
	if IsServer() then

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

		self.stop_timer = true

        -- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		ParticleManager:DestroyParticle(self.particleNfx, true)

		local radius = self:GetSpecialValueFor("radius")
		local projectile_speed = self:GetSpecialValueFor("ball_speed")
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()
		local projectile_direction = ( self.vTargetPos - origin ):Normalized()
		local offset = 150

		local projectile = {
			EffectName = "particles/gyrocopter/gyro_cannon_ball.vpcf",
			vSpawnOrigin = origin + projectile_direction * offset,
			fDistance = self:GetSpecialValueFor("distance"),
			fStartRadius = radius,
			fEndRadius = radius,
			Source = caster,
			vVelocity = projectile_direction * projectile_speed,
			UnitBehavior = PROJECTILES_NOTHING,
			bMultipleHits = true,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_BOUNCE,
			GroundBehavior = PROJECTILES_FOLLOW,
			fGroundOffset = 80,
            nChangeMax = 99,
			draw = false,
			UnitTest = function(_self, unit)

				if unit:GetUnitName() == "npc_dota_thinker" and CheckGlobalUnitTableForUnitName(unit) == true then
					return false
				else
					return true
				end

			end,
			OnUnitHit = function(_self, unit)

				local dmgTable = {
					victim = unit,
					attacker = caster,
					damage = self:GetSpecialValueFor("damage"),
					damage_type = self:GetAbilityDamageType(),
				}

				ApplyDamage(dmgTable)

				EmitSoundOn( "Hero_Beastmaster.Wild_Axes_Damage", unit )
			end,
			OnWallHit = function(_self, gnvPos)

			end,
			OnFinish = function(_self, pos)

                local particle_cast = "particles/gyrocopter/crumber_metal_ball.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 3, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)

			end,
		}

		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end
---------------------------------------------------------------------------
