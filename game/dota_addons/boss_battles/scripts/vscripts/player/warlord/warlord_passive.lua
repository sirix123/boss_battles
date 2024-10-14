warlord_passive = class({})
LinkLuaModifier("warlord_passive_modifier", "player/warlord/warlord_passive", LUA_MODIFIER_MOTION_NONE)
function warlord_passive:GetIntrinsicModifierName()
    return "warlord_passive_modifier"
end

warlord_passive_modifier = class({})

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------
-- Classifications
function warlord_passive_modifier:IsHidden()
	return true
end

-----------------------------------------------------------------------------

function warlord_passive_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
    end
end

function warlord_passive_modifier:OnDestroy()
    if IsServer() then
        
    end
end

-----------------------------------------------------------------------------
function warlord_passive_modifier:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

----------------------------------------------------------------------------

function warlord_passive_modifier:OnAttackLanded(params)
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

        
    end
end