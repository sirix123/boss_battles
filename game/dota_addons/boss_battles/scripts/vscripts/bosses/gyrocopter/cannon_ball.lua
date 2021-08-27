
cannon_ball = class({})

function cannon_ball:OnAbilityPhaseStart()
    if IsServer() then

        if self:GetCursorPosition() then
			self.vTargetPos = self:GetCursorPosition()
		end

        EmitSoundOn( "Hero_Beastmaster.Wild_Axes", self:GetCaster() )

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)
		self.stop_timer = false

		local particle = "particles/custom/sirix_mouse/range_finder_cone.vpcf"

		-- depending on the level of the ball spell... cast more balls
		self.num_balls = self:GetSpecialValueFor("balls_to_summon")
		self.balls = {}
		local direction = Vector(0,0,GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()).z )
		local randomVectorDirection = Vector(0,0,0)

		for i = 1, self.num_balls, 1 do

			self.ball_data = {}

			self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(125,125,0)) -- line width
			ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

			if i == 1 then
				direction = (( self.vTargetPos - self:GetCaster():GetAbsOrigin()):Normalized() )
			else
				direction = RandomVector(1):Normalized()
			end

			self.distance = self:GetCaster():GetAbsOrigin() + direction * 1000

			ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
			ParticleManager:SetParticleControl(self.particleNfx , 2, self.distance)  -- target

			local portal_particle = "particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_portal.vpcf"
			self.particleNfx_portal = ParticleManager:CreateParticle(portal_particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(self.particleNfx_portal , 0, self:GetCaster():GetAbsOrigin())

			self.ball_data["direction"] = direction
			self.ball_data["particle_index"] = self.particleNfx
			self.ball_data["particleNfx_portal"] = self.particleNfx_portal

			table.insert(self.balls,self.ball_data)
		end

        return true
    end
end
---------------------------------------------------------------------------

function cannon_ball:OnAbilityPhaseInterrupted()
	if IsServer() then

		--self.stop_timer = true

        -- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		for _, value in ipairs(self.balls) do
			ParticleManager:DestroyParticle(value["particle_index"], true)
			ParticleManager:DestroyParticle(value["particleNfx_portal"], true)
		end

    end
end
---------------------------------------------------------------------------

function cannon_ball:OnSpellStart()
	if IsServer() then

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

		if self.height_timer then
			Timers:RemoveTimer(self.height_timer)
		end

		if self.oil_spawner_timer then
			Timers:RemoveTimer(self.oil_spawner_timer)
		end

		self:OilSpawner()

		self.tProjs = {}

		--self.stop_timer = true

        -- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		for _, value in ipairs(self.balls) do
			ParticleManager:DestroyParticle(value["particle_index"], true)
			ParticleManager:DestroyParticle(value["particleNfx_portal"], true)
		end

		local radius = self:GetSpecialValueFor("radius")
		local projectile_speed = self:GetSpecialValueFor("ball_speed")
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()
		local offset = 150

		self.time_limit = self:GetSpecialValueFor("distance") / projectile_speed

		for _, value in ipairs(self.balls) do
			local projectile_direction = value["direction"]

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
				GroundBehavior = PROJECTILES_NOTHING,
				fGroundOffset = 1,
				nChangeMax = 99,
				bGroundLock = true,
				draw = false,
				--bZCheck = false,
				UnitTest = function(_self, unit)

					if unit:GetUnitName() == "npc_dota_thinker" or CheckGlobalUnitTableForUnitName(unit) == true or unit:GetTeamNumber() == caster:GetTeamNumber() then
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
						ability = self,
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
			local projectile_data = Projectiles:CreateProjectile(projectile)
			table.insert(self.tProjs,projectile_data)
		end
	end
end
---------------------------------------------------------------------------


function cannon_ball:OilSpawner()
	if IsServer() then
		self.oil_spawner_timer = Timers:CreateTimer(function()
			if IsValidEntity(self:GetCaster()) == false then
				return false
			end

			if self:GetCaster():IsAlive() == false then
                return false
            end

			--print("#self.tProjs ",#self.tProjs)

			for index, proj in pairs(self.tProjs) do
				if proj then

					--print("cure time = ",GameRules:GetGameTime(), "end time = ",proj:GetCreationTime() + self.time_limit)
					if ( GameRules:GetGameTime() ) > ( proj:GetCreationTime() + self.time_limit )  then
						--print("do not create")
						proj:Destroy()
						return 1.4
					end

					--print("ball creating oil")
					local puddle = CreateModifierThinker(
						self:GetCaster(),
							self,
							"oil_drop_thinker",
							{
								target_x = proj:GetPosition().x,
								target_y = proj:GetPosition().y,
								target_z = GetGroundPosition( proj:GetPosition(), nil ).z,
							},
							GetGroundPosition( proj:GetPosition(), nil ),
							self:GetCaster():GetTeamNumber(),
							false
						)

					table.insert(_G.Oil_Puddles, puddle)
				else
					table.remove(self.tProjs,index)
				end
			end

			return 2.0
		end)
	end
end

function cannon_ball:HeightChecker()
	if IsServer() then
		self.height_timer = Timers:CreateTimer(function()
			if IsValidEntity(self:GetCaster()) == false then
				return false
			end

			if self:GetCaster():IsAlive() == false then
                return false
            end

			for _, proj in pairs(self.tProjs) do
				if proj then
					if proj:GetPosition().z > 134 then
						proj:Destroy()
					end
				end
			end

			return FrameTime()
		end)
	end
end