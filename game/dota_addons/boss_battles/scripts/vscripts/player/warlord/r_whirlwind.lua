r_whirlwind = class({})

LinkLuaModifier( "r_whirlwind_modifier", "player/warlord/modifiers/r_whirlwind_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function r_whirlwind:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

        return true
    end
end
---------------------------------------------------------------------------

function r_whirlwind:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    end
end
---------------------------------------------------------------------------

function r_whirlwind:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        local caster = self:GetCaster()
        local point = caster:GetOrigin()

        caster:FindAbilityByName("m1_sword_slash"):SetActivated(false)
        caster:FindAbilityByName("m2_sword_slam"):SetActivated(false)
        --caster:FindAbilityByName("q_warlord_def_stance"):SetActivated(false)
        --caster:FindAbilityByName("q_warlord_dps_stance"):SetActivated(false)
        caster:FindAbilityByName("e_spawn_ward"):SetActivated(false)

        local duration = self:GetSpecialValueFor("duration")

        -- Add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "r_whirlwind_modifier", -- modifier name
            { duration = duration } -- kv
        )

    end
end