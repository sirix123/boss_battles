frenzy = class({})
LinkLuaModifier("frenzy_modifier", "player/warrior/frenzy_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function frenzy:OnSpellStart()

    -- pull spell details from kv file
    local duration = self:GetSpecialValueFor("duration")
    local increaseDurationPerStack = self:GetSpecialValueFor("durationPerStack")

    -- setup
    local caster = self:GetCaster()

    -- adds increased duration depending on rage stacks
    if caster:FindModifierByName("rage_stacks_modifier") ~= nil then
        local hBuff = caster:FindModifierByName("rage_stacks_modifier")

        if hBuff:GetStackCount() > 0 then
            local increasedDuration = duration + (hBuff:GetStackCount() * increaseDurationPerStack)
            caster:AddNewModifier( caster, self, "frenzy_modifier",  { duration = increasedDuration })
            hBuff:SetStackCount(0)
        end
    end
end
