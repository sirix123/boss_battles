
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
			fDistance = fRangeToTarget, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
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
				end
			end,
			OnFinish = function(_self, pos)end,
		}
		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end

---------------------------------------------------------------------------

