q_fire_bubble = class({})
LinkLuaModifier( "q_fire_bubble_modifier", "player/fire_mage/modifiers/q_fire_bubble_modifier", LUA_MODIFIER_MOTION_NONE )

function q_fire_bubble:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)
        return true
    end
end
---------------------------------------------------------------------------

function q_fire_bubble:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_fire_bubble:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )
        self.target = self:GetCursorTarget()

        self.target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "q_fire_bubble_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------