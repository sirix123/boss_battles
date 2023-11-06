priest_holy_fire = class({})
LinkLuaModifier("priest_holy_fire_modifier", "player/priest/modifiers/priest_holy_fire_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("priest_holy_fire_modifier_dot", "player/priest/modifiers/priest_holy_fire_modifier_dot", LUA_MODIFIER_MOTION_NONE)

function priest_holy_fire:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("space_angel_mode_modifier") == true then
        return ability_cast_point - ( ability_cast_point * caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_cps" ) )
    else
        return ability_cast_point
    end
end

function priest_holy_fire:OnAbilityPhaseStart()
    if IsServer() then
        self.point = nil
        self.point = Vector(self:GetCursorPosition().x, self:GetCursorPosition().y, self:GetCursorPosition().z)
        return true
    end
end
---------------------------------------------------------------------------

function priest_holy_fire:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function priest_holy_fire:GetManaCost(level)
	local caster = self:GetCaster()
	local modifier = "space_angel_mode_modifier"
	local base_mana_cost = self.BaseClass.GetManaCost(self, level)

    local mana_cost = base_mana_cost

	if caster:HasModifier(modifier) then
		--mana_cost = base_mana_cost / caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_mana_cost" )
        mana_cost = 0
	end

	return mana_cost
end
---------------------------------------------------------------------------

function priest_holy_fire:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function priest_holy_fire:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        -- init
        self.caster = self:GetCaster()

        self.modifier = CreateModifierThinker(
            self.caster,
            self,
            "priest_holy_fire_modifier",
            {
                duration = self:GetSpecialValueFor( "delay" ),
                radius = self:GetSpecialValueFor( "radius" ),
                target_x = self.point.x,
                target_y = self.point.y,
                target_z = self.point.z,
            },
            self.caster:GetOrigin(),
            self.caster:GetTeamNumber(),
            false
        )

	end
end
----------------------------------------------------------------------------------------------------------------
