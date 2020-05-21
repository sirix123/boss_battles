aoe_taunt = class({})
LinkLuaModifier("aoe_taunt_modifier", "player/warrior/aoe_taunt_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("aoe_taunt_modifier_aura", "player/warrior/aoe_taunt_modifier_aura", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function aoe_taunt:OnSpellStart()

    local radius = self:GetSpecialValueFor("radius")
    local caster = self:GetCaster()

    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, 
                                        caster:GetOrigin(), 
                                        nil, 
                                        radius, 
                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                        DOTA_UNIT_TARGET_ALL, 
                                        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
                                        FIND_ANY_ORDER, 
                                        false)
    
    for _,target in pairs(enemies) do     
        target:SetForceAttackTarget(caster)
    end

    local increaseDurationPerStack = 1.0
    local duration = self:GetSpecialValueFor("duration")

    if caster:FindModifierByName("rage_stacks_modifier") ~= nil then
        local hBuff = caster:FindModifierByName("rage_stacks_modifier")

        if hBuff:GetStackCount() > 3 then
            local increasedDuration = duration + (hBuff:GetStackCount() * increaseDurationPerStack)
            caster:AddNewModifier( caster, self, "aoe_taunt_modifier_aura",  { duration = increasedDuration })
            hBuff:SetStackCount(0)
        end
    end
end

---------------------------------------------------------------------------------



