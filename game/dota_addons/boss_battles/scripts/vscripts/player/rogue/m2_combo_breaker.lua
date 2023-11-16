m2_combo_breaker = class({})
LinkLuaModifier("m2_energy_buff", "player/rogue/modifiers/m2_energy_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("m2_combo_breaker_modifier", "player/rogue/modifiers/m2_combo_breaker_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function m2_combo_breaker:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function m2_combo_breaker:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function m2_combo_breaker:OnSpellStart()
    if IsServer() then
        self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "m2_combo_breaker_modifier", -- modifier name
            { duration = -1 } -- kv
        )
    end
end
--------------------------------------------------------------------------------


