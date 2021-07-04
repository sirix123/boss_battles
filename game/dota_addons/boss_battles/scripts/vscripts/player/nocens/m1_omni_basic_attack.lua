m1_omni_basic_attack = class({})
--------------------------------------------------------------------------------

function m1_omni_basic_attack:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("e_whirling_winds_modifier") == true and caster:GetUnitName() ~= "npc_dota_hero_hoodwink" then
        return ability_cast_point - ( ability_cast_point * 0.25 ) --flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25 -- globals don't work here -- self:GetCastPoint()
    else
        return ability_cast_point
    end
end

function m1_omni_basic_attack:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.8)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_omni_basic_attack:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_omni_basic_attack:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	-- remove casting animation
	self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

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

	for _, enemy in pairs(enemies) do

		local dmgTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}

        ApplyDamage(dmgTable)
	end

	-- mana percent per mob hit
	-- add more rage generation more mobs but dimishing returns
	if #enemies >= 1 then
		EmitSoundOn( "Hero_OmniKnight.Attack", self:GetCaster() )
	end
end
--------------------------------------------------------------------------------