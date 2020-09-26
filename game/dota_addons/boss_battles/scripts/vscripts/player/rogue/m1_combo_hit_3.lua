m1_combo_hit_3 = class({})
LinkLuaModifier("m2_combo_hit_3_bleed", "player/rogue/modifiers/m2_combo_hit_3_bleed", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function m1_combo_hit_3:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN, 1)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_combo_hit_3:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_combo_hit_3:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	-- remove casting animation
	self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)

	-- function in utility_functions
	local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)

	local radius = self:GetSpecialValueFor("radius")
	local direction = (Vector(point.x-origin.x, point.y-origin.y, 0)):Normalized()

	local damage = self:GetSpecialValueFor("damage")

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

		local dmgTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
		}

        EmitSoundOn( "phantom_assassin_phass_attack_02", self:GetCaster() )

        -- add bleed
        enemy:AddNewModifier(caster, self, "m2_combo_hit_3_bleed", { duration = self:GetSpecialValueFor( "bleed_duration") })

        ApplyDamage(dmgTable)

	end

	-- on attack end particle effect
	local offset = radius - 80
	local direction = (point - origin):Normalized()
	local final_position = origin + Vector(direction.x * offset, direction.y * offset, 0)

	local particle_cast = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_blinkb.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effect_cast, 0, final_position)
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	caster:SwapAbilities("m1_combo_hit_3", "m1_combo_hit_1_2", false, true)

end
--------------------------------------------------------------------------------


