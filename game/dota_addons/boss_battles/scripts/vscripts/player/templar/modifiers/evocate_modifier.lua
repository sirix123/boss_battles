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
	return "particles/items2_fx/rod_of_atos.vpcf"
end
-----------------------------------------------------------------------------

function evocate_modifier:OnCreated( kv )
	if not IsServer() then return end

    local particle = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf"
    self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 3, self:GetCaster():GetAbsOrigin())

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

    local sound_cast = "Hero_ObsidianDestroyer.AstralImprisonment.End"
    EmitSoundOn( sound_cast, self:GetCaster() )

    if self.effect_cast then
        ParticleManager:DestroyParticle(self.effect_cast, true)
    end

end
----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Status Effects
function evocate_modifier:CheckState()
	local state = {
        [MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_INVULNERABLE] = true,
        --[MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
