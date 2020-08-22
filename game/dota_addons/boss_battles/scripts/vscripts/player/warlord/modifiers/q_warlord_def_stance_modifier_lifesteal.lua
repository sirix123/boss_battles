q_warlord_def_stance_modifier_lifesteal = class({})
--------------------------------------------------------------------------------

function q_warlord_def_stance_modifier_lifesteal:IsHidden()
    return false
end

function q_warlord_def_stance_modifier_lifesteal:IsBuff()
    if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return true
    end

    return false
end

function q_warlord_def_stance_modifier_lifesteal:IsPurgable()
    return false
end

function q_warlord_def_stance_modifier_lifesteal:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function q_warlord_def_stance_modifier_lifesteal:OnTooltip( params )
    return self.hero_lifesteal
end

function q_warlord_def_stance_modifier_lifesteal:GetTexture()
	return "dragon_knight_dragon_tail"
end

--------------------------------------------------------------------------------

function q_warlord_def_stance_modifier_lifesteal:OnCreated( kv )
  self.lifesteal_percent = self:GetAbility():GetSpecialValueFor( "lifesteal_amount" )

end

--------------------------------------------------------------------------------

function q_warlord_def_stance_modifier_lifesteal:OnRefresh( kv )
  self.lifesteal_percent = self:GetAbility():GetSpecialValueFor( "lifesteal_amount" )
end
--------------------------------------------------------------------------------

function q_warlord_def_stance_modifier_lifesteal:OnTakeDamage(params)
    local hero = self:GetParent()

    local life_steal_amount = self.lifesteal_percent * params.damage

    hero:Heal(life_steal_amount, self:GetAbility())

    -- play effect on hero
    ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)

end
--------------------------------------------------------------------------------

function q_warlord_def_stance_modifier_lifesteal:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }
    return funcs
end