e_whirling_winds = class({})
LinkLuaModifier("e_whirling_winds_modifier", "player/ranger/modifiers/e_whirling_winds_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_whirling_winds_modifier_thinker", "player/ranger/modifiers/e_whirling_winds_modifier_thinker", LUA_MODIFIER_MOTION_NONE)

function e_whirling_winds:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_whirling_winds:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_whirling_winds:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function e_whirling_winds:OnSpellStart()

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "e_whirling_winds_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "duration" ),
            target_x = point.x,
            target_y = point.y,
            target_z = point.z,
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------