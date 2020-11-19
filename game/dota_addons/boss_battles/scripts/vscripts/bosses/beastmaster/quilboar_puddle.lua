
quilboar_puddle = class({})
LinkLuaModifier( "quillboar_puddle_modifier", "bosses/beastmaster/quillboar_puddle_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function quilboar_puddle:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function quilboar_puddle:OnSpellStart()
	if IsServer() then
		self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()
		local enemies = {}

		enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			2500,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
			false )

		if #enemies == 0 or enemies == nil then
			return
		end

		if enemies ~= nil and enemies ~= 0 then
			self.i = RandomInt(1,#enemies)
			self.point = enemies[self.i]:GetAbsOrigin()

			local direction = (self.point - origin):Normalized()
			local distance = (self.point - origin):Length2D()

			local projectile = {
				EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,0),
				fDistance = distance,
				fUniqueRadius = 100,--200
				Source = caster,
				vVelocity = direction * self.projectile_speed,
				UnitBehavior = PROJECTILES_NOTHING,
				TreeBehavior = PROJECTILES_NOTHING,
				WallBehavior = PROJECTILES_DESTROY,
				GroundBehavior = PROJECTILES_NOTHING,
				fGroundOffset = 256,
				UnitTest = function(_self, unit)
					return unit:GetTeamNumber() ~= caster:GetTeamNumber()
				end,
				OnUnitHit = function(_self, unit)

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
