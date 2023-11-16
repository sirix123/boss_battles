m2_combo_breaker_modifier = class({})
LinkLuaModifier("m2_energy_buff", "player/rogue/modifiers/m2_energy_buff", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------
-- Classifications
function m2_combo_breaker_modifier:IsHidden()
	return false
end

function m2_combo_breaker_modifier:IsDebuff()
	return false
end

function m2_combo_breaker_modifier:IsStunDebuff()
	return false
end

function m2_combo_breaker_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function m2_combo_breaker_modifier:GetEffectName()
	return "particles/rogue/bb_test_phantom_assassin_mark_overhead.vpcf"
end

function m2_combo_breaker_modifier:GetStatusEffectName()
	return
end

function m2_combo_breaker_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
-----------------------------------------------------------------------------

function m2_combo_breaker_modifier:OnCreated( kv )
	if IsServer() then
    end
end

function m2_combo_breaker_modifier:OnRefresh( kv )
	if IsServer() then
    end
end

function m2_combo_breaker_modifier:OnDestroy()
    if IsServer() then
    end
end
-----------------------------------------------------------------------------

function m2_combo_breaker_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function m2_combo_breaker_modifier:OnAttack( params )
	if not IsServer() then return end
	if params.attacker~=self:GetParent() then return end

    local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
    local damage = self:GetAbility():GetSpecialValueFor("damage")

    self.m1_bleed = caster:FindAbilityByName("rogue_passive")
    local m1_bleed_tick = self.m1_bleed:GetSpecialValueFor("dmg_dot_base")

    self.ruptureAbility = caster:FindAbilityByName("r_rupture")
    local rupture_bleed_tick = self.ruptureAbility:GetSpecialValueFor("dmg_dot_base")

    local env_bonus = self.ruptureAbility:GetSpecialValueFor("bonus_bleed_percent") / 100

    local direction = caster:GetForwardVector()
    local final_position = caster:GetAbsOrigin()

    local particle_cast = "particles/rogue/rogue_m2_pa_arcana_attack_blinkb.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(effect_cast, 0, final_position)
    ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
    ParticleManager:ReleaseParticleIndex(effect_cast)

	-- function in utility_functions
	local enemies = FindUnitsInCone(
		caster:GetTeamNumber(),
		direction,
		origin,
		5,
		radius,
		self:GetAbility():GetCastRange(Vector(0,0,0), nil),
		nil,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		FIND_ANY_ORDER,
		false)

    for _, enemy in pairs(enemies) do

        damage = self:GetAbility():GetSpecialValueFor("damage")

        if enemy:HasModifier("m2_combo_hit_3_bleed") then
            local hBuff = enemy:FindModifierByNameAndCaster("m2_combo_hit_3_bleed", caster)
            local flBuffDuration = hBuff:GetRemainingTime()
            local bleedTickDmg = m1_bleed_tick

            if enemy:HasModifier("e_swallow_potion_modifier_debuff") then
                bleedTickDmg = m1_bleed_tick + ( m1_bleed_tick * env_bonus )
            end

            local dmgPop = ( flBuffDuration * bleedTickDmg ) / self:GetAbility():GetSpecialValueFor("bleed_pop_dmg_reduction")
            damage = damage + dmgPop
            enemy:RemoveModifierByName("m2_combo_hit_3_bleed")
        end

        if enemy:HasModifier("r_rupture_modifier") then
            local hBuff = enemy:FindModifierByNameAndCaster("r_rupture_modifier", caster)
            local flBuffDuration = hBuff:GetRemainingTime()
            local bleedTickDmg = rupture_bleed_tick

            if enemy:HasModifier("e_swallow_potion_modifier_debuff") then
                bleedTickDmg = rupture_bleed_tick + ( rupture_bleed_tick * env_bonus )
            end

            local dmgPop = ( flBuffDuration * bleedTickDmg ) / self:GetAbility():GetSpecialValueFor("bleed_pop_dmg_reduction")
            damage = damage + dmgPop

            enemy:RemoveModifierByName("r_rupture_modifier")
        end

        if caster:HasModifier("e_swallow_potion_modifier") then
            local hBuff = caster:FindModifierByName("e_swallow_potion_modifier")
            local nStackCount = hBuff:GetStackCount()
            if nStackCount == 3 then
                caster:AddNewModifier(caster, self, "m2_energy_buff", { duration = self:GetAbility():GetSpecialValueFor( "duration") })
                caster:RemoveModifierByName("e_swallow_potion_modifier")
            end
        end

		local dmgTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility(),
		}

        EmitSoundOn( "Hero_PhantomAssassin.CoupDeGrace", self:GetCaster() )

        ApplyDamage(dmgTable)

        -- particle effect
        local particle = nil
        if caster.arcana_equipped == true then
            particle = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_impact_dagger_arcana.vpcf"
        else
            particle = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
        end

        local nFXIndex = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
        ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
        ParticleManager:SetParticleControlForward( nFXIndex, 1, -caster:GetForwardVector() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

    end
    self:Destroy()
end