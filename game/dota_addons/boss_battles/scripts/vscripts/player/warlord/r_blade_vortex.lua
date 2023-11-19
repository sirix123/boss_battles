r_blade_vortex = class({})
LinkLuaModifier( "r_blade_vortex_thinker", "player/warlord/modifiers/r_blade_vortex_thinker", LUA_MODIFIER_MOTION_NONE )

function r_blade_vortex:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function r_blade_vortex:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function r_blade_vortex:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local hTarget = self:GetCursorTarget()

        -- sound effect
        caster:EmitSound("Hero_Juggernaut.HealingWard.Cast")

        hTarget:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "r_blade_vortex_thinker", -- modifier name
            { duration = self:GetSpecialValueFor( "duration" )} -- kv
        )


    end
end
---------------------------------------------------------------------------

