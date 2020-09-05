
beastmaster_net = class({})
LinkLuaModifier( "modifier_beastmaster_net", "bosses/beastmaster/modifier_beastmaster_net", LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------------------------------------

function beastmaster_net:OnSpellStart()
	if IsServer() then

		EmitSoundOn( "Hero_Beastmaster.Wild_Axes", self:GetCaster() )

		self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/events/ti9/rock_golem_tower/radiant_tower_attack_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

		local radius = self:GetSpecialValueFor( "radius" )
		local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local hero = self:GetCaster()
		local projectile_direction = caster:GetForwardVector()
		local offset = 20

		local vTargetPos = nil
		if self:GetCursorTarget() then
			vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			vTargetPos = self:GetCursorPosition()
		end

		local fRangeToTarget = ( self:GetCaster():GetOrigin() - vTargetPos ):Length2D()

		local projectile = {
			EffectName = "particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", --"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
			vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 80),
			--hero:GetAbsOrigin(), attach="attach_attack1", offset=Vector(0,0,0), 
			fDistance = 5500, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
			fStartRadius = radius,
			fEndRadius = radius,
			--fUniqueRadius = self:GetSpecialValueFor("hitbox"),
			Source = caster,
			vVelocity = projectile_direction * projectile_speed,
			UnitBehavior = PROJECTILES_NOTHING,
			bMultipleHits = true,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_DESTROY,
			GroundBehavior = PROJECTILES_FOLLOW,
			fGroundOffset = 80,
			draw = false,
			UnitTest = function(_self, unit) return unit:GetTeamNumber() ~= hero:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
			OnUnitHit = function(_self, unit) 
				if unit ~= nil and (unit:GetUnitName() ~= nil) then
					unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net", { duration = self:GetSpecialValueFor( "duration" ) } )

					EmitSoundOn( "Hero_Beastmaster.Wild_Axes_Damage", unit )
				end
			end,
			OnWallHit = function(_self, gnvPos) 

			end,
			OnFinish = function(_self, pos)

			end,
		}

		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end
---------------------------------------------------------------------------
