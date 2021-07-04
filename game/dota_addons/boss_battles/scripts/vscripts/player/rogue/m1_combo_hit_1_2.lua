m1_combo_hit_1_2 = class({})
LinkLuaModifier("m2_combo_hit_3_bleed", "player/rogue/modifiers/m2_combo_hit_3_bleed", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
local nAttackCount = 0

function m1_combo_hit_1_2:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("e_whirling_winds_modifier") == true and caster:GetUnitName() ~= "npc_dota_hero_hoodwink" then
        return ability_cast_point - ( ability_cast_point * 0.25 ) --flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25 -- globals don't work here
    else
        return ability_cast_point
    end
end
--------------------------------------------------------------------------------

function m1_combo_hit_1_2:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
		if self:GetCaster().arcana_equipped == true then
			self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.5)
		else
			self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN, 1.5)
		end

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
			animation_sequence = "fast",
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_combo_hit_1_2:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
		if self:GetCaster().arcana_equipped == true then
			self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
		else
			self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)
		end

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_combo_hit_1_2:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	-- remove casting animation
	if self:GetCaster().arcana_equipped == true then
		self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
	else
		self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)
	end

	-- function in utility_functions
	local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)

	local radius = self:GetSpecialValueFor("radius")
	local direction = (Vector(point.x-origin.x, point.y-origin.y, 0)):Normalized()

	local damage = self:GetSpecialValueFor("damage")

	-- function in utility_functions
	local enemies = FindUnitsInCone(
		caster:GetTeamNumber(),
		direction,
		origin,
		5,
		radius,
		self:GetCastRange(Vector(0,0,0), nil),
		nil,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		FIND_ANY_ORDER,
		false)

	if enemies ~= nil and #enemies ~= 0 then

		for _, enemy in pairs(enemies) do

			local dmgTable = {
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}

			EmitSoundOn( "Hero_PhantomAssassin.Attack", self:GetCaster() )

			enemy:AddNewModifier(caster, self, "m2_combo_hit_3_bleed", { duration = self:GetSpecialValueFor( "bleed_duration") })

			ApplyDamage(dmgTable)

		end
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

end
--------------------------------------------------------------------------------


