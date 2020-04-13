
beastmaster_break = class({})
LinkLuaModifier("beastmaster_break_modifier", "bosses/beastmaster/beastmaster_break_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function beastmaster_break:OnSpellStart()
	if IsServer() then

		EmitSoundOn( "Hero_Tusk.IceShards.Projectile", self:GetCaster() )
		--self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

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
			EffectName = "",
			vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 0),
			fDistance = fRangeToTarget, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
			fStartRadius = 100,
			fEndRadius = 100,
			--fUniqueRadius = self:GetSpecialValueFor("hitbox"),
			Source = caster,
			vVelocity = projectile_direction * 700,
			UnitBehavior = PROJECTILES_NOTHING,
			bMultipleHits = true,
			TreeBehavior = PROJECTILES_NOTHING,
			WallBehavior = PROJECTILES_DESTROY,
			GroundBehavior = PROJECTILES_NOTHING,
			fGroundOffset = 0,
			draw = false,
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
			OnFinish = function(_self, pos) 
				self:PlayEffectsOnFinish(pos)
			end,
		}
		
		-- Cast projectile
		Projectiles:CreateProjectile(projectile)
	end
end


-- On Projectile Finish
function beastmaster_break:PlayEffectsOnFinish(pos)
	--[[
	local particle_cast = "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , self:GetCaster()  )
	ParticleManager:SetParticleControl( nFXIndex, 0, pos:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	]]

	local caster = self:GetCaster()
	local offset = 40
	local origin = caster:GetOrigin()
	local direction = (pos - origin):Normalized()
	local final_position = origin + Vector(direction.x * offset, direction.y * offset, 0)

	-- Create Particles
	local particle_cast = "particles/units/heroes/hero_mars/mars_shield_bash_crit_strike.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT, caster )
	ParticleManager:SetParticleControl( effect_cast, 1, final_position )
	ParticleManager:SetParticleControlForward(effect_cast, 1, direction)	
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function beastmaster_break:PlayEffectsOnImpact( hTarget )



	return
end