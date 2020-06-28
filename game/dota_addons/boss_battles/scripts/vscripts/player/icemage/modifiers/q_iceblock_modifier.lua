q_iceblock_modifier = class({})

function q_iceblock_modifier:IsHidden()
	return false
end

function q_iceblock_modifier:IsDebuff()
	return false
end

function q_iceblock_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function q_iceblock_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:OnCreated( kv )
	if IsServer() then
		local iFrameTime= 1.0
		self.animation_rate = 0.5
		self.invulnerable = true

		self.armor_bonus = self:GetAbility():GetSpecialValueFor( "armor_bonus")
		self.magic_res_bonus = self:GetAbility():GetSpecialValueFor( "magic_res_bonus")
		self.health_regen_percent = self:GetAbility():GetSpecialValueFor( "health_regen_percent")

		self:StartIntervalThink(iFrameTime)

    end
end
----------------------------------------------------------------------------

function q_iceblock_modifier:OnIntervalThink()
	if IsServer() then
		self.invulnerable = false
    end
end
----------------------------------------------------------------------------

function q_iceblock_modifier:OnDestroy()
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function q_iceblock_modifier:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function q_iceblock_modifier:GetOverrideAnimationRate()
	return self.anim_rate
end
----------------------------------------------------------------------------

function q_iceblock_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = self.invulnerable,
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
----------------------------------------------------------------------------

function q_iceblock_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,

        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function q_iceblock_modifier:GetModifierPhysicalArmorBonus( params )
	return self.armor_bonus
end

function q_iceblock_modifier:GetModifierMagicalResistanceBonus( params )
	return self.magic_res_bonus
end

function q_iceblock_modifier:GetModifierHealthRegenPercentage( params )
	return self.health_regen_percent
end
