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

        --[[ disable abilities
        local tAbilties =
        {
            "m1_sword_slash",
            "m2_sword_slam",
            "q_warlord_def_stance",
            "e_spawn_ward",
            "q_warlord_dps_stance"
        }

        for _, ability in pairs(tAbilties) do
            ability:SetActivated(false)
		end]]

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