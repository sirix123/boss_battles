e_swallow_potion = class({})
LinkLuaModifier( "e_swallow_potion_modifier", "player/rogue/modifiers/e_swallow_potion_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "e_swallow_potion_modifier_debuff", "player/rogue/modifiers/e_swallow_potion_modifier_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function e_swallow_potion:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN, 1.5)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_swallow_potion:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_swallow_potion:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	-- remove casting animation
	self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)

	-- function in utility_functions
	local point = Clamp(origin, self:GetCursorPosition(), self:GetCastRange(Vector(0,0,0), nil), self:GetCastRange(Vector(0,0,0), nil))

	local radius = self:GetSpecialValueFor("radius")
	local direction = (Vector(point.x-origin.x, point.y-origin.y, 0)):Normalized()

    local damage = self:GetSpecialValueFor("damage")

    -- load data
    local duration = self:GetSpecialValueFor( "duration" )

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

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "e_swallow_potion_modifier", -- modifier name
            { duration = duration } -- kv
        )

        -- add modifier
        enemy:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "e_swallow_potion_modifier_debuff", -- modifier name
            { duration = duration } -- kv
        )

		EmitSoundOn( "Hero_PhantomAssassin.Attack", self:GetCaster() )

        ApplyDamage(dmgTable)

    end

	-- on attack end particle effect
	local offset = radius - 80
	local direction = (point - origin):Normalized()
	local final_position = origin + Vector(direction.x * offset, direction.y * offset, 0)

	local particle_cast = "particles/rogue/rogue_m2_pa_arcana_attack_blinkb.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effect_cast, 0, final_position)
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

end
--------------------------------------------------------------------------------