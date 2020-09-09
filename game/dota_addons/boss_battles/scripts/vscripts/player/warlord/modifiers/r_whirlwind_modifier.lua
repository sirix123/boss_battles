r_whirlwind_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function r_whirlwind_modifier:IsHidden()
	return false
end

function r_whirlwind_modifier:IsDebuff()
	return false
end

function r_whirlwind_modifier:IsPurgable()
	return false
end

function r_whirlwind_modifier:DestroyOnExpire()
	return true
end

function r_whirlwind_modifier:GetTexture()
	return "juggernaut_blade_fury"
end
--------------------------------------------------------------------------------

function r_whirlwind_modifier:OnCreated( kv )

	self.caster = self:GetCaster()

	self.tick = self:GetAbility():GetSpecialValueFor( "tick" ) -- special value
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) -- special value
	self.dps = self:GetAbility():GetSpecialValueFor( "damage" ) -- special value
	self.mana_degen = self:GetAbility():GetSpecialValueFor( "mana_degen" )

	-- Start interval
	if IsServer() then
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.dps,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}

		self:StartIntervalThink( self.tick )
    end

	self:PlayEffects()
end

function r_whirlwind_modifier:OnRemoved( kv )
	-- enable abilties
	if IsServer() then
		if self.caster:HasModifier("space_chain_hook_modifier") == false then
			self.caster:FindAbilityByName("m1_sword_slash"):SetActivated(true)
			self.caster:FindAbilityByName("m2_sword_slam"):SetActivated(true)
			--self.caster:FindAbilityByName("q_warlord_def_stance"):SetActivated(true)
			--self.caster:FindAbilityByName("q_warlord_dps_stance"):SetActivated(true)
			self.caster:FindAbilityByName("e_spawn_ward"):SetActivated(true)
		end
	end

end

function r_whirlwind_modifier:OnDestroy( kv )



	local sound_cast = "Hero_Juggernaut.BladeFuryStart"
    StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
function r_whirlwind_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function r_whirlwind_modifier:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_1
end
function r_whirlwind_modifier:GetOverrideAnimationRate()
	return 1.0
end
function r_whirlwind_modifier:GetModifierConstantManaRegen()
	return self.mana_degen
end

--------------------------------------------------------------------------------
-- Interval Effects
function r_whirlwind_modifier:OnIntervalThink()

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if enemies ~= nil or enemies ~= 0 then
		for _,enemy in pairs(enemies) do
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )

			-- mana percent per mob hit
			self.caster:ManaOnHit(self:GetAbility():GetSpecialValueFor( "mana_gain_percent"))

			self:PlayEffects2( enemy )
		end
	end

	if self.caster:GetManaPercent() < 1 then
		self:Destroy()
	end

end

--------------------------------------------------------------------------------
function r_whirlwind_modifier:PlayEffects()

	local particle_cast = "particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf"
	local sound_cast = "Hero_Juggernaut.BladeFuryStart"

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.effect_cast, 5, Vector( self.radius, 0, 0 ) )

	self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		false
	)

	EmitSoundOn( sound_cast, self:GetParent() )
end

function r_whirlwind_modifier:PlayEffects2( target )
	local particle_cast = "particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end