stim_pack_buff = class({})

-----------------------------------------------------------------------------
-- Classifications
function stim_pack_buff:IsHidden()
	return false
end

function stim_pack_buff:IsDebuff()
	return false
end

function stim_pack_buff:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf"
end


-----------------------------------------------------------------------------

function stim_pack_buff:OnCreated( kv )
	if not IsServer() then return end

    self.rat_m2_ability = self:GetCaster():FindAbilityByName("rat_m2")
    self.base_cp_m2_ability = self.rat_m2_ability:GetCastPoint()
    self.rat_m2_ability:SetOverrideCastPoint(0)

    self:StartIntervalThink( 0.1 )

end

function stim_pack_buff:OnRefresh( kv )
	if not IsServer() then return end

end

function stim_pack_buff:OnRemoved()
    if not IsServer() then return end

end

function stim_pack_buff:OnDestroy()
	if not IsServer() then return end

    -- give rat crash
    self:GetParent():AddNewModifier(
        self:GetParent(), -- player source
        self:GetAbility(), -- ability source
        "stim_pack_debuff", -- modifier name
        { duration = self:GetAbility():GetSpecialValueFor( "duration_debuff") } -- kv
    )

    self.rat_m2_ability:SetOverrideCastPoint(self.base_cp_m2_ability)

end

function stim_pack_buff:OnIntervalThink()
    if not IsServer() then return end

    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        self:GetParent():Script_GetAttackRange(),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

    if #units > 0 then   
        self.target	= units[1]
        if self:GetParent():AttackReady() and self.target and not self.target:IsNull() and self.target:IsAlive() and (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self:GetParent():Script_GetAttackRange() then
            self:GetParent():PerformAttack(self.target, true, true, false, true, true, false, false)
        end
    end
end
----------------------------------------------------------------------------

