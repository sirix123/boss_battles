q_iceblock = class({})
LinkLuaModifier("q_iceblock_modifier", "player/icemage/modifiers/q_iceblock_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bonechill_modifier", "player/icemage/modifiers/bonechill_modifier", LUA_MODIFIER_MOTION_NONE)

function q_iceblock:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        return true
    end
end
---------------------------------------------------------------------------

function q_iceblock:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

    end
end
---------------------------------------------------------------------------

function q_iceblock:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )
        self.target = self:GetCursorTarget()

        self.modifier = self.target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "q_iceblock_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------
