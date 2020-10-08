e_swallow_potion_modifier_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function e_swallow_potion_modifier_debuff:IsHidden()
	return false
end

function e_swallow_potion_modifier_debuff:IsDebuff()
	return true
end

function e_swallow_potion_modifier_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function e_swallow_potion_modifier_debuff:OnCreated( kv )
    if IsServer() then
        -- references
		--self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )

		local particle_cast = "particles/rogue/rogue_abaddon_curse_counter_debuff.vpcf"
        self.effect_cast = ParticleManager:CreateParticleForPlayer(particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self.caster:GetPlayerOwner())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())

    end
end

function e_swallow_potion_modifier_debuff:OnRefresh( kv )
	if IsServer() then

    end
end

function e_swallow_potion_modifier_debuff:OnRemoved()
end

function e_swallow_potion_modifier_debuff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.effect_cast, true)
	end
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function e_swallow_potion_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function e_swallow_potion_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end]]

--------------------------------------------------------------------------------
--[[ Graphics & Animations
function e_swallow_potion_modifier_debuff:GetEffectName()
	return "particles/rogue/rogue_abaddon_curse_counter_debuff.vpcf"
end

function e_swallow_potion_modifier_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end]]