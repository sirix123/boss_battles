e_swallow_potion = class({})

LinkLuaModifier( "e_swallow_potion_modifier_ability", "player/rogue/modifiers/e_swallow_potion_modifier_ability", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function e_swallow_potion:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function e_swallow_potion:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function e_swallow_potion:OnSpellStart()
    if IsServer() then
        self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "e_swallow_potion_modifier_ability", -- modifier name
            { duration = -1 } -- kv
        )
    end
end
--------------------------------------------------------------------------------