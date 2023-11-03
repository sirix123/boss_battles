e_icefall = class({})
LinkLuaModifier( "e_icefall_modifier_thinker", "player/icemage/modifiers/e_icefall_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icefall_freeze_modifier", "player/icemage/modifiers/icefall_freeze_modifier", LUA_MODIFIER_MOTION_NONE )

function e_icefall:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function e_icefall:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function e_icefall:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function e_icefall:OnSpellStart()

    -- self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "e_icefall_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "duration" ),
            target_x = self:GetCursorPosition().x,
            target_y = self:GetCursorPosition().y,
            target_z = self:GetCursorPosition().z,
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------