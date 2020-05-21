shield_wall = class({})
LinkLuaModifier("shield_wall_modifier", "player/warrior/shield_wall_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shield_wall_modifier_aura", "player/warrior/shield_wall_modifier_aura", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function shield_wall:OnSpellStart()

    local increaseDurationPerStack = self:GetSpecialValueFor("increaseDurationPerStack")
    local duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local hero = self:GetCaster()
	local projectile_speed = 600
	local projectile_direction = -caster:GetForwardVector()
	local offset = 20

	local projectile = {
        EffectName = "particles/econ/items/death_prophet/death_prophet_acherontia/death_prophet_acher_swarm.vpcf",
		vSpawnOrigin = origin + Vector(projectile_direction.x * offset, projectile_direction.y * offset, 0),
		fDistance = 1000, -- self:GetSpecialValueFor("projectile_distance") ~= 0 and self:GetSpecialValueFor("projectile_distance") or self:GetCastRange(Vector(0,0,0), nil),
        fStartRadius = 10,
        fEndRadius = 500,
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
		UnitTest = function(_self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() == hero:GetTeamNumber() end,
		OnUnitHit = function(_self, unit) 
            if caster:FindModifierByName("rage_stacks_modifier") == nil then
                unit:AddNewModifier(caster, self, "shield_wall_modifier", { duration = self:GetSpecialValueFor("duration") })
            elseif caster:FindModifierByName("rage_stacks_modifier") ~= nil then
                local hBuff = caster:FindModifierByName("rage_stacks_modifier")
                local increasedDuration = duration + (hBuff:GetStackCount() * increaseDurationPerStack)
                unit:AddNewModifier( caster, self, "shield_wall_modifier",  { duration = increasedDuration })
                hBuff:SetStackCount(0)
            end
		  end,
        OnFinish = function(_self, pos)
            self:PlayEffectsOnFinish( pos )
		end,
	}
	-- Cast projectile
	Projectiles:CreateProjectile(projectile)
end
---------------------------------------------------------------------------------

-- On Projectile Finish
function shield_wall:PlayEffectsOnFinish( pos )
	local caster = self:GetCaster()

	-- Create Particles
	--local particle_cast = "particles/econ/events/ti9/mjollnir_shield_ti9.vpcf"
	--local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT, caster )
	--ParticleManager:SetParticleControl( effect_cast, 0, 0 )
	--ParticleManager:SetParticleControlForward(effect_cast, 0, 0)	
	--ParticleManager:ReleaseParticleIndex( effect_cast )
end
