
beastmaster_break = class({})
LinkLuaModifier("beastmaster_break_modifier", "bosses/beastmaster/beastmaster_break_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function beastmaster_break:OnSpellStart()
	if IsServer() then

		EmitSoundOn( "Hero_Tusk.IceShards.Projectile", self:GetCaster() )

		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local hero = self:GetCaster()
		local projectile_direction = caster:GetForwardVector()

		local vTargetPos = nil
		if self:GetCursorTarget() then
			vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			vTargetPos = self:GetCursorPosition()
		end

		local fRangeToTarget = ( self:GetCaster():GetOrigin() - vTargetPos ):Length2D()
		local offset = 80

		local projectile = 
		{
			EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
			vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 0),
			fDistance = fRangeToTarget + 600 , -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
			fStartRadius = 50,
			fEndRadius = 50,
			--fUniqueRadius = self:GetSpecialValueFor("hitbox"),
			Source = caster,
			vVelocity = projectile_direction * 200,
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
					local damageInfo = 
					{
						victim = unit,
						attacker = self:GetCaster(),
						ability = self,
					}
					ApplyDamage( damageInfo )
					unit:AddNewModifier( self:GetCaster(), self, "beastmaster_break_modifier", { duration = self:GetSpecialValueFor("duration")} )
					local hBuff = unit:FindModifierByName( "beastmaster_break_modifier" )
					hBuff:IncrementStackCount()
				end
			end,
			OnFinish = function(_self, pos) end,
		}
		
		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end