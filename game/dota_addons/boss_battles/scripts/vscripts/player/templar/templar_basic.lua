templar_basic = class({})

function templar_basic:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("e_whirling_winds_modifier") == true and caster:GetUnitName() ~= "npc_dota_hero_hoodwink" then
        return ability_cast_point - ( ability_cast_point * 0.25 ) --flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25 -- globals don't work here -- self:GetCastPoint()
    else
        return ability_cast_point
    end
end

--------------------------------------------------------------------------------

function templar_basic:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function templar_basic:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function templar_basic:GetManaCost(level)
	local caster = self:GetCaster()
	local modifier = "templar_power_charge"
	local base_mana_cost = self.BaseClass.GetManaCost(self, level)

	local stacks = 0
	if caster:HasModifier(modifier) then
		stacks = caster:GetModifierStackCount(modifier, caster)
	end

	local mana_cost = base_mana_cost

    local mana_reduction_per_stack = self:GetCaster():FindAbilityByName("templar_passive"):GetSpecialValueFor( "power_charge_m1_mana_cost_reduction_per_stack" )

    if stacks == 1 then
        mana_cost = mana_cost - ( mana_cost * ( mana_reduction_per_stack / 100 ) ) -- 10%
    elseif stacks == 2 then
        mana_cost = mana_cost - ( mana_cost * ( mana_reduction_per_stack * 2 / 100 ) ) -- 20%
    elseif stacks == 3 then
        mana_cost = mana_cost - ( mana_cost * ( mana_reduction_per_stack * 3 / 100 ) ) -- 30%
    end

    if caster:GetMana() <= 10 then
        mana_cost = 0
    end

	return mana_cost
end
---------------------------------------------------------------------------

function templar_basic:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)
	local direction = (Vector(point.x-origin.x, point.y-origin.y, 0)):Normalized()

    local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local base_mana = self:GetSpecialValueFor( "mana_gain_percent" )

    damage = damage + ( self:GetCaster():GetMana() )

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
        EmitSoundOn( "Hero_Huskar.ProjectileImpact", self:GetCaster() )

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
    end
end
--------------------------------------------------------------------------------


