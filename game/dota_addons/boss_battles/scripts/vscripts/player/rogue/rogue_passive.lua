rogue_passive = class({})
LinkLuaModifier("rogue_passive_modifier", "player/rogue/rogue_passive", LUA_MODIFIER_MOTION_NONE)
function rogue_passive:GetIntrinsicModifierName()
    return "rogue_passive_modifier"
end

rogue_passive_modifier = class({})

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


LinkLuaModifier("m2_combo_hit_3_bleed", "player/rogue/modifiers/m2_combo_hit_3_bleed", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------
-- Classifications
function rogue_passive_modifier:IsHidden()
	return true
end

-----------------------------------------------------------------------------

function rogue_passive_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
    end
end

function rogue_passive_modifier:OnDestroy()
    if IsServer() then
        
    end
end

-----------------------------------------------------------------------------
function rogue_passive_modifier:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

----------------------------------------------------------------------------

function rogue_passive_modifier:OnAttackLanded(params)
    if IsServer() then
        local caster = self:GetCaster()
        local target = params.target
        local attacker = params.attacker
    
        -- check attacker is the modifier parent
        if attacker ~= self:GetParent() then
            return
        end

        if target == nil and target:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            return
        end

        ---- if in editor mode, deal 10000 damage on right clicks
        if self:GetParent():HasModifier("admin_god_mode") then
            local dmgEditor = 10000

            local dmgTable = {
                victim = target,
                attacker = self:GetParent(),
                damage = dmgEditor,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self:GetAbility(),
            }

            ApplyDamage(dmgTable)
        end

        -- apply chill modifier
        if CheckRaidTableForBossName(target) ~= true and target:GetUnitName() ~= "npc_guard" then
            target:AddNewModifier(caster, self:GetAbility(), "m2_combo_hit_3_bleed", { duration = self:GetAbility():GetSpecialValueFor( "bleed_duration" ) })
        end
        
    end
end