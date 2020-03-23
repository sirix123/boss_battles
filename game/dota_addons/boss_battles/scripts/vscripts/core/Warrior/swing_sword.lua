swing_sword = class({})
LinkLuaModifier("rage_stacks_modifier", "core/warrior/rage_stacks_modifier", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function swing_sword:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local attack_damage = self:GetSpecialValueFor("attack_damage")
	local mana_gain_pct = self:GetSpecialValueFor("mana_gain_pct")

	-- i think these need to be dynamic... keeping the same until this works
	local player = PlayerResource:GetPlayer(0)
	local hero = player:GetAssignedHero()

	local projectile_speed = 2000
	local projectile_direction = ( Vector( point.x - origin.x, point.y - origin.y, 0)):Normalized()
	local offset = 50

	local projectile = {
		vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 0),
		fDistance = self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
		fUniqueRadius = self:GetSpecialValueFor("hitbox"),
		Source = caster,
		vVelocity = projectile_direction * projectile_speed,
		UnitBehavior = PROJECTILES_NOTHING,
		bMultipleHits = true,
		TreeBehavior = PROJECTILES_NOTHING,
		WallBehavior = PROJECTILES_DESTROY,
		GroundBehavior = PROJECTILES_NOTHING,
		fGroundOffset = 0,
		-- not sure what this does (unittest)
		UnitTest = function(_self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= hero:GetTeamNumber() end,
		OnUnitHit = function(_self, unit) 
			local damageInfo = 
			{
				victim = unit,
				attacker = caster,
				damage = attack_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

			ApplyDamage( damageInfo )

			caster:AddNewModifier( caster, self, "rage_stacks_modifier", { duration = self:GetSpecialValueFor("duration") } )
			-- add stack
			local hBuff = caster:FindModifierByName( "rage_stacks_modifier" )
			local mStacks = 5
			if hBuff:GetStackCount() < mStacks then
				hBuff:IncrementStackCount()
			end
			
			caster:GiveManaPercent(mana_gain_pct, unit)

		  end,
		OnFinish = function(_self, pos)
			self:PlayEffectsOnFinish(pos)
		end,
	}

	-- Cast projectile
	Projectiles:CreateProjectile(projectile)
	self:PlayEffectsOnCast()
end

--------------------------------------------------------------------------------
-- Graphics & sounds

-- On Projectile Finish
function swing_sword:PlayEffectsOnFinish( pos )
	local caster = self:GetCaster()
	local offset = 40
	local origin = caster:GetOrigin()
	local direction = (pos - origin):Normalized()
	local final_position = origin + Vector(direction.x * offset, direction.y * offset, 0)

	-- Create Particles
	local particle_cast = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_blinkb.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, final_position )
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)	
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function swing_sword:PlayEffectsOnImpact( hTarget )
	return
end

-- On Projectile miss
function swing_sword:PlayEffectsOnCast()
	return
end

-- Misc
-- Add mana on attack modifier. Only first time upgraded
function swing_sword:OnUpgrade()
	if self:GetLevel()==1 then
		local caster = self:GetCaster()
		-- Gain mana
		caster:AddNewModifier(caster, self , "modifier_mana_on_attack", {})
	end
end

