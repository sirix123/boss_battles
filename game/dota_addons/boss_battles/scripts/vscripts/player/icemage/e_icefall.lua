e_icefall = class({})
LinkLuaModifier( "e_icefall_modifier_thinker", "player/icemage/modifiers/e_icefall_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function e_icefall:OnAbilityPhaseStart()
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

function e_icefall:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_icefall:OnSpellStart()

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "e_icefall_modifier_thinker",
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