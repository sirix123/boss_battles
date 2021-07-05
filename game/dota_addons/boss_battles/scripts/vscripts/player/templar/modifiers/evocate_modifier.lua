evocate_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function evocate_modifier:IsHidden()
	return false
end

function evocate_modifier:IsDebuff()
	return false
end

function evocate_modifier:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end
-----------------------------------------------------------------------------

function evocate_modifier:OnCreated( kv )
	if not IsServer() then return end

end

function evocate_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function evocate_modifier:OnRemoved()
    if not IsServer() then return end

end

function evocate_modifier:OnDestroy()
	if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

    self:GetCaster():GiveMana(self:GetCaster():GetMaxMana())

    local sound_cast = "Hero_NyxAssassin.Burrow.Out"
    EmitSoundOn( sound_cast, self:GetCaster() )

    local particle = "particles/units/heroes/hero_meepo/meepo_burrow_end.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)

end
----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Status Effects
function evocate_modifier:CheckState()
	local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
