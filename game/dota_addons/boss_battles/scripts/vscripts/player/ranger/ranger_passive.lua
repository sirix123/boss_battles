ranger_passive = class({})
LinkLuaModifier("ranger_passive_modifier", "player/ranger/ranger_passive", LUA_MODIFIER_MOTION_NONE)
function ranger_passive:GetIntrinsicModifierName()
    return "ranger_passive_modifier"
end

ranger_passive_modifier = class({})

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Classifications
function ranger_passive_modifier:IsHidden()
	return true
end

-----------------------------------------------------------------------------

function ranger_passive_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.dmg = self:GetAbility():GetSpecialValueFor( "base_dmg" )
        self.dmg_dist_multi = self:GetAbility():GetSpecialValueFor( "dmg_dist_multi" ) / 100
    end
end

function ranger_passive_modifier:OnDestroy()
    if IsServer() then
        
    end
end

-----------------------------------------------------------------------------
function ranger_passive_modifier:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

----------------------------------------------------------------------------

function ranger_passive_modifier:OnAttackLanded(params)
    if IsServer() then
        local target = params.target
        local attacker = params.attacker
    
        -- check attacker is the modifier parent
        if attacker ~= self:GetParent() then
            return
        end

        if target == nil and target:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            return
        end

        local distanceFromHero = (target:GetAbsOrigin() - self.caster:GetAbsOrigin() ):Length2D()

        if self.caster:HasModifier("e_whirling_winds_modifier") then
            distanceFromHero = attacker:GetBaseAttackRange()
            self.dmg = self.dmg + ( distanceFromHero * self.dmg_dist_multi )
        else
            self.dmg = self.dmg + ( distanceFromHero * self.dmg_dist_multi )
        end

        local dmgTable = {
            victim = target,
            attacker = self:GetParent(),
            damage = self.dmg,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(),
        }

        -- give mana
        self.caster:ManaOnHit(self:GetAbility():GetSpecialValueFor( "mana_gain_percent"))

        ApplyDamage(dmgTable)

        if self.caster:HasModifier("r_explosive_tip_modifier") then
            local hbuff = caster:FindModifierByNameAndCaster("r_explosive_tip_modifier", self.caster)
            local flBuffTimeRemaining = hbuff:GetRemainingTime()
            target:AddNewModifier(self.caster, self:GetAbility(), "r_explosive_tip_modifier_target", {duration = flBuffTimeRemaining})
        end

        self.dmg = self:GetAbility():GetSpecialValueFor( "base_dmg" )
        
    end
end