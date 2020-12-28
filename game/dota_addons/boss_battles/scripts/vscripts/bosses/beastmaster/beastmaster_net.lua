
beastmaster_net = class({})
LinkLuaModifier( "modifier_beastmaster_net", "bosses/beastmaster/modifier_beastmaster_net", LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------------------------------------

--[[
function beastmaster_net:OnAbilityPhaseStart()
    if IsServer() then

		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)

		EmitSoundOn( "beastmaster_beas_ability_axes_03", self:GetCaster() )

		self.vTargetPos = nil
		if self:GetCursorPosition() then
			self.vTargetPos = self:GetCursorPosition()
		end

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

		local direction_particle = ( self.vTargetPos - self:GetCaster():GetAbsOrigin() ):Normalized()
		local particle_distance = direction_particle * 200

		DebugDrawCircle(particle_distance, Vector(255,0,0), 60, 50, true, 60)

		local particle = "particles/custom/ui_mouseactions/range_finder_cone.vpcf"
		self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, nil)
		ParticleManager:SetParticleControl(self.particleNfx , 1, particle_distance)
		ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(125,125,0))
		ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0))
		
        return true
    end
end
---------------------------------------------------------------------------
]]

function beastmaster_net:OnAbilityPhaseStart()
    if IsServer() then

		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)

		EmitSoundOn( "beastmaster_beas_ability_axes_03", self:GetCaster() )

		--local self.vTargetPos = self:GetCursorTarget():GetAbsOrigin()
		self.target = self:GetCursorTarget()
		self.vTargetPos = self.target:GetAbsOrigin()
 		if self.vTargetPos == nil then
 			return false
 		end

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

		--DebugDrawCircle(self.vTargetPos, Vector(255,0,0), 60, 50, true, 60)

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

			self.target = self:GetCursorTarget()
			self.vTargetPos = self.target:GetAbsOrigin()
			
			ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
			ParticleManager:SetParticleControl(self.particleNfx , 2, self.vTargetPos) -- target

			return FrameTime()
		end)

		
        return true
    end
end
---------------------------------------------------------------------------

function beastmaster_net:OnAbilityPhaseInterrupted()
	if IsServer() then
		
		self.stop_timer = true

        -- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		ParticleManager:DestroyParticle(self.particleNfx, true)

    end
end
---------------------------------------------------------------------------

function beastmaster_net:OnSpellStart()
	if IsServer() then

		self.stop_timer = true

		EmitSoundOn( "Hero_Beastmaster.Wild_Axes", self:GetCaster() )

		self.target = self:GetCursorTarget()
		self.vTargetPos = self.target:GetAbsOrigin()

		ParticleManager:DestroyParticle(self.particleNfx, true)

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

		-- remove casting animation
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

		self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/events/ti9/rock_golem_tower/radiant_tower_attack_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

		local radius = self:GetSpecialValueFor( "radius" )
		local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()
		local hero = self:GetCaster()
		local projectile_direction = ( self.vTargetPos - origin ):Normalized()
		local offset = 150

		local projectile = {
			EffectName = "particles/beastmaster/beastmaster_axe.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", --"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
			vSpawnOrigin = origin + projectile_direction * offset,
			--hero:GetAbsOrigin(), attach="attach_attack1", offset=Vector(0,0,0), 
			fDistance = 5500, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
			fStartRadius = radius,
			fEndRadius = radius,
			--fUniqueRadius = self:GetSpecialValueFor("hitbox"),
			Source = caster,
			vVelocity = projectile_direction * projectile_speed,
			UnitBehavior = PROJECTILES_DESTROY,
			bMultipleHits = false,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_DESTROY,
			GroundBehavior = PROJECTILES_FOLLOW,
			fGroundOffset = 80,
			draw = false,
			UnitTest = function(_self, unit)
				--print("unit ",unit)
				--print("unit ",unit:GetUnitName())

				if unit:GetUnitName() ~= "npc_dota_thinker" or unit ~= nil then
					return true
				else
					return false
				end

			end, -- unit:GetTeamNumber() ~= hero:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end
			OnUnitHit = function(_self, unit)
				unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net", { duration = self:GetSpecialValueFor( "duration" ) } )

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
