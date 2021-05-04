e_qop_shield = class({})
LinkLuaModifier("e_qop_shield_modifier", "player/queenofpain/modifiers/e_qop_shield_modifier", LUA_MODIFIER_MOTION_NONE)

function e_qop_shield:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        return true
    end
end
---------------------------------------------------------------------------

function e_qop_shield:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

    end
end
---------------------------------------------------------------------------

function e_qop_shield:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- init
        self.caster = self:GetCaster()
        self.target = self:GetCursorTarget()

        local duration = self:GetSpecialValueFor( "duration" )

        self.target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "e_qop_shield_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------