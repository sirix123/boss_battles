
beastmaster_net = class({})
LinkLuaModifier( "modifier_beastmaster_net", "bosses/beastmaster/modifier_beastmaster_net", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beastmaster_net_dot", "bosses/beastmaster/modifier_beastmaster_net_dot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beastmaster_net_dot_player", "bosses/beastmaster/modifier_beastmaster_net_dot_player", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function beastmaster_net:OnSpellStart()
	if IsServer() then

		-- should emit sound when cast so players know a net has been cast...
		EmitSoundOn( "Hero_Tusk.IceShards.Projectile", self:GetCaster() )

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

		-- calc slop from spawn to target
		local targetPosWithZ = Projectiles:CalcSlope(vTargetPos, self:GetCursorTarget(), projectile_direction)

		local fRangeToTarget = ( self:GetCaster():GetOrigin() - vTargetPos ):Length2D()

		local projectile = {
			EffectName = "particles/beastmaster/net_spear.vpcf",--"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
			vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 800),
			fDistance = fRangeToTarget, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
			fStartRadius = radius,
			fEndRadius = radius,
			Source = caster,
			vVelocity = targetPosWithZ * projectile_speed,
			UnitBehavior = PROJECTILES_NOTHING,
			bMultipleHits = true,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_DESTROY,
			GroundBehavior = PROJECTILES_NOTHING,
			bZCheck = true,
			bGroundLock = false,
			draw = true,
			UnitTest = function(_self, unit) return unit:GetUnitName() == "npc_beastmaster_bear" or unit:GetTeamNumber() ~= hero:GetTeamNumber() end,
			OnUnitHit = function(_self, unit) 
				if unit ~= nil and (unit:GetUnitName() ~= nil) then
					unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net", { duration = self:GetSpecialValueFor( "duration" ) } )

					if unit == "npc_beastmaster_bear" then
						unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net_dot", { duration = self:GetSpecialValueFor( "duration_dot" ) } )
					end

					if unit ~= "npc_beastmaster_bear" then
						unit:AddNewModifier( self:GetCaster(), self, "modifier_beastmaster_net_dot_player", { duration = self:GetSpecialValueFor( "duration_dot" ) } )
					end

					self:OnSpearHitTarget(_self, unit)
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
		-- testttttttttttt
		--local pos = 
		--local unit = 
		--local dir = 
		--Projectiles:CalcSlope(pos, unit, dir)
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
function beastmaster_net:OnSpearHitTarget(_self ,unit)
	ParticleManager:DestroyParticle( self.nPreviewFX, false )
	local particle_cast = "particles/beastmaster/radiant_tower_attack_explode.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW , _self) --self:GetCaster()  )
	ParticleManager:SetParticleControl( nFXIndex, 0, unit:GetAbsOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector(0,0,0) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
