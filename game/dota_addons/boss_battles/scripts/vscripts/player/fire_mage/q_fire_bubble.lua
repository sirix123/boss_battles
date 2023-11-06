q_fire_bubble = class({})
LinkLuaModifier( "q_fire_bubble_modifier", "player/fire_mage/modifiers/q_fire_bubble_modifier", LUA_MODIFIER_MOTION_NONE )

function q_fire_bubble:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function q_fire_bubble:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function q_fire_bubble:OnSpellStart()
    if IsServer() then

        local hTarget = self:GetCursorTarget()

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )

        hTarget:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "q_fire_bubble_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------