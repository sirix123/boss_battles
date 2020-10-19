
beastmaster_net = class({})
LinkLuaModifier( "modifier_beastmaster_net", "bosses/beastmaster/modifier_beastmaster_net", LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------------------------------------

function beastmaster_net:OnAbilityPhaseStart()
    if IsServer() then

		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)

		EmitSoundOn( "beastmaster_beas_ability_axes_03", self:GetCaster() )

		self.vTargetPos = nil
		if self:GetCursorTarget() then
			self.vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			self.vTargetPos = self:GetCursorPosition()
		end

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        return true
    end
end
---------------------------------------------------------------------------

function beastmaster_net:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    end
end
---------------------------------------------------------------------------

function beastmaster_net:OnSpellStart()
	if IsServer() then

		EmitSoundOn( "Hero_Beastmaster.Wild_Axes", self:GetCaster() )

		-- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/events/ti9/rock_golem_tower/radiant_tower_attack_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

		local radius = self:GetSpecialValueFor( "radius" )
		local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local hero = self:GetCaster()
		local projectile_direction = caster:GetForwardVector()
		local offset = 150

		local fRangeToTarget = ( self:GetCaster():GetOrigin() - self.vTargetPos ):Length2D()

		local projectile = {
			EffectName = "particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", --"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
			vSpawnOrigin = origin + caster:GetForwardVector() * offset,
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
					--unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net", { duration = self:GetSpecialValueFor( "duration" ) } )
					
					local dmgTable = {
						victim = unit,
						attacker = caster,
						damage = self:GetSpecialValueFor( "damage_bear" ),
						damage_type = self:GetAbilityDamageType(),
					}

					ApplyDamage(dmgTable)

					local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_beastmaster/beastmaster_wildaxes_hit.vpcf", PATTACH_CUSTOMORIGIN, nil )
					ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true )
					ParticleManager:ReleaseParticleIndex( nFXIndex )

					EmitSoundOn( "Hero_Beastmaster.Wild_Axes_Damage", unit )
				end
			end,
			OnWallHit = function(_self, gnvPos)

			end,
			OnFinish = function(_self, pos)

				local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_spear_end.vpcf", PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl(nFXIndex, 0, pos)
				ParticleManager:SetParticleControl(nFXIndex, 3, pos)
				ParticleManager:ReleaseParticleIndex( nFXIndex )

			end,
		}

		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end
---------------------------------------------------------------------------
