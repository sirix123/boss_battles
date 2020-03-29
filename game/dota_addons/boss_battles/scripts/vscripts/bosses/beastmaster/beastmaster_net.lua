
beastmaster_net = class({})
LinkLuaModifier( "modifier_beastmaster_net", "bosses/beastmaster/modifier_beastmaster_net", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function beastmaster_net:OnSpellStart()
	if IsServer() then

		-- should emit sound when cast so players know a net has been cast...
		EmitSoundOn( "Hero_Tusk.IceShards.Projectile", self:GetCaster() )

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
			EffectName = "particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_spear.vpcf",
			vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 0),
			fDistance = fRangeToTarget + 9000, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
			fStartRadius = 10,
			fEndRadius = radius,
			--fUniqueRadius = self:GetSpecialValueFor("hitbox"),
			Source = caster,
			vVelocity = projectile_direction * projectile_speed,
			UnitBehavior = PROJECTILES_NOTHING,
			bMultipleHits = true,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_DESTROY,
			GroundBehavior = PROJECTILES_NOTHING,
			fGroundOffset = 0,
			draw = true,
			UnitTest = function(_self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= hero:GetTeamNumber() end,
			OnUnitHit = function(_self, unit) 
				if unit ~= nil and (unit:GetUnitName() ~= nil) then
					unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net", { duration = self:GetSpecialValueFor( "duration" ) } )
					self:OnSpearHitTarget(unit)
				end
			end,
			OnWallHit = function(self, gnvPos) 
				--self:OnSpearDestroy(gnvPos)
			end,
			OnFinish = function(_self, pos)
				
			end,
		}
		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end

---------------------------------------------------------------------------
function beastmaster_net:OnSpearDestroy(pos)
	local caster = self:GetCaster()
	local offset = 100
	local origin = caster:GetOrigin()
	local direction = (pos - origin):Normalized()
	local final_position = origin + Vector(direction.x * offset, direction.y * offset, 0)

	local particle_cast = "particles/dire_fx/tower_bad_face_end_explode.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, final_position )
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)	
	ParticleManager:ReleaseParticleIndex( effect_cast )

end

---------------------------------------------------------------------------
function beastmaster_net:OnSpearHitTarget(hTarget)
	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
	ParticleManager:SetParticleControl( nFXIndex, 1, hTarget:GetOrigin() )
	if self:GetCaster() then
		ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
	end
	ParticleManager:SetParticleControlEnt( nFXIndex, 10, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
