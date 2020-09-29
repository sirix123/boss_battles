m2_combo_breaker = class({})
LinkLuaModifier("m2_energy_buff", "player/rogue/modifiers/m2_energy_buff", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function m2_combo_breaker:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.5)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m2_combo_breaker:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m2_combo_breaker:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	-- remove casting animation
	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

	-- function in utility_functions
	local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)

	local radius = self:GetSpecialValueFor("radius")
	local direction = (Vector(point.x-origin.x, point.y-origin.y, 0)):Normalized()

    local damage = self:GetSpecialValueFor("damage")
    local m1_bleed_tick = self:GetSpecialValueFor("m1_bleed_tick")
    local rupture_bleed_tick = self:GetSpecialValueFor("rupture_bleed_tick")

    -- on attack end particle effect
    local offset = 40
    local direction = (point - origin):Normalized()
    local final_position = origin + Vector(direction.x * offset, direction.y * offset, 0)

    local particle_cast = "particles/rogue/rogue_m2_pa_arcana_attack_blinkb.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(effect_cast, 0, final_position)
    ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
    ParticleManager:ReleaseParticleIndex(effect_cast)

	-- function in utility_functions
	local enemies = FindUnitsInCone(
		caster:GetTeamNumber(),
		direction,
		0,
		origin,
		radius,
		nil,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false
	)

    for _, enemy in pairs(enemies) do

        damage = self:GetSpecialValueFor("damage")

        if enemy:HasModifier("m2_combo_hit_3_bleed") then
            local hBuff = enemy:FindModifierByNameAndCaster("m2_combo_hit_3_bleed", caster)
            local flBuffDuration = hBuff:GetRemainingTime()
            local bleedTickDmg = m1_bleed_tick
            local dmgPop = flBuffDuration * bleedTickDmg
            damage = damage + dmgPop
            enemy:RemoveModifierByName("m2_combo_hit_3_bleed")
        end

        if enemy:HasModifier("r_rupture_modifier") then
            local hBuff = enemy:FindModifierByNameAndCaster("r_rupture_modifier", caster)
            local flBuffDuration = hBuff:GetRemainingTime()
            local bleedTickDmg = rupture_bleed_tick
            local dmgPop = flBuffDuration * bleedTickDmg
            damage = damage + dmgPop
            enemy:RemoveModifierByName("r_rupture_modifier")
        end

        if caster:HasModifier("e_swallow_potion_modifier") then
            local hBuff = caster:FindModifierByName("e_swallow_potion_modifier")
            local nStackCount = hBuff:GetStackCount()
            if nStackCount == 3 then
                caster:AddNewModifier(caster, self, "m2_energy_buff", { duration = self:GetSpecialValueFor( "duration") })
                caster:RemoveModifierByName("e_swallow_potion_modifier")
            end
        end

		local dmgTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
            ability = self,
		}

        EmitSoundOn( "Hero_PhantomAssassin.CoupDeGrace", self:GetCaster() )

        ApplyDamage(dmgTable)

        -- particle effect
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
        ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
        ParticleManager:SetParticleControlForward( nFXIndex, 1, -caster:GetForwardVector() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

    end

end
--------------------------------------------------------------------------------


