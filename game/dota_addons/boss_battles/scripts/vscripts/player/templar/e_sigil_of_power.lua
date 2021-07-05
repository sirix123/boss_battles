e_sigil_of_power = class({})
LinkLuaModifier("e_sigil_of_power_modifier", "player/templar/modifiers/e_sigil_of_power_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_sigil_of_power_modifier_thinker", "player/templar/modifiers/e_sigil_of_power_modifier_thinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_sigil_of_power_modifier_buff", "player/templar/modifiers/e_sigil_of_power_modifier_buff", LUA_MODIFIER_MOTION_NONE)


function e_sigil_of_power:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_sigil_of_power:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_sigil_of_power:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function e_sigil_of_power:OnSpellStart()

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "e_sigil_of_power_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "duration" ),
            target_x = point.x,
            target_y = point.y,
            target_z = point.z,
        },
        self.caster:GetAbsOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------