ice_mage_passive = class({})
LinkLuaModifier("ice_mage_passive_modifier", "player/icemage/ice_mage_passive", LUA_MODIFIER_MOTION_NONE)
function ice_mage_passive:GetIntrinsicModifierName()
    return "ice_mage_passive_modifier"
end

ice_mage_passive_modifier = class({})

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


LinkLuaModifier("chill_modifier", "player/icemage/modifiers/chill_modifier", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------
-- Classifications
function ice_mage_passive_modifier:IsHidden()
	return true
end

-----------------------------------------------------------------------------

function ice_mage_passive_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
    end
end

function ice_mage_passive_modifier:OnDestroy()
    if IsServer() then
        
    end
end

-----------------------------------------------------------------------------
function ice_mage_passive_modifier:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

----------------------------------------------------------------------------

function ice_mage_passive_modifier:OnAttackLanded(params)
    if IsServer() then
        local caster = self:GetCaster()
        local target = params.target
        local attacker = params.attacker
    
        -- check attacker is the modifier parent
        if not attacker == self:GetParent() then
            return
        end

        -- apply shatter modifier to icemage
        self.caster:AddNewModifier(caster, self:GetAbility(), "shatter_modifier", { 
            duration = self:GetAbility():GetSpecialValueFor( "shatter_duration"), 
            max_shatter_stacks = self:GetAbility():GetSpecialValueFor( "max_shatter_stacks"), 
            ms_slow = self:GetAbility():GetSpecialValueFor( "max_shatter_stacks"), 
            as_slow = self:GetAbility():GetSpecialValueFor( "max_shatter_stacks")
        })
        
        -- mana on hit
        self.caster:ManaOnHit(self:GetAbility():GetSpecialValueFor( "mana_gain_percent" ))
        
        -- apply chill modifier
        if CheckRaidTableForBossName(target) ~= true and target:GetUnitName() ~= "npc_guard" then
            target:AddNewModifier(caster, self:GetAbility(), "chill_modifier", { duration = self:GetAbility():GetSpecialValueFor( "chill_duration" ) })
        end
        
    end
end