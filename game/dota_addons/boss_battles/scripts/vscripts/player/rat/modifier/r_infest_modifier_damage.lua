r_infest_modifier_damage = class({})

-----------------------------------------------------------------------------
-- Classifications
function r_infest_modifier_damage:IsHidden()
	return false
end

function r_infest_modifier_damage:IsDebuff()
	return false
end

function r_infest_modifier_damage:GetTexture()
	return "queenofpain_blink"
end

function r_infest_modifier_damage:GetEffectName()
	return "particles/ranger/ranger_bristleback_viscous_nasal_goo_debuff.vpcf"
end

function r_infest_modifier_damage:GetStatusEffectName()
	return "particles/status_fx/status_effect_goo.vpcf"
end
-----------------------------------------------------------------------------

function r_infest_modifier_damage:OnCreated( kv )
	if not IsServer() then return end

    self.damage = kv.dmg / self:GetDuration()

    self:StartIntervalThink(1)

end

function r_infest_modifier_damage:OnIntervalThink()
    if not IsServer() then return end

    self.dmgTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility(),
    }

    ApplyDamage(self.dmgTable)
end

function r_infest_modifier_damage:OnRefresh( kv )
	if not IsServer() then return end

	self:OnCreated()

end

function r_infest_modifier_damage:OnRemoved()
    if not IsServer() then return end

end

function r_infest_modifier_damage:OnDestroy()
	if not IsServer() then return end

end
----------------------------------------------------------------------------
