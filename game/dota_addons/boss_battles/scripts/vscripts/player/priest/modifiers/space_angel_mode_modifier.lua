space_angel_mode_modifier = class({})

function space_angel_mode_modifier:RemoveOnDeath()
    return true
end

function space_angel_mode_modifier:IsHidden()
	return false
end

function space_angel_mode_modifier:IsDebuff()
	return false
end

function space_angel_mode_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function space_angel_mode_modifier:GetEffectName()
	return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
end

function space_angel_mode_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
end

function space_angel_mode_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function space_angel_mode_modifier:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end
-----------------------------------------------------------------------------

function space_angel_mode_modifier:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function space_angel_mode_modifier:OnDestroy()
	if IsServer() then
	end
end
----------------------------------------------------------------------------

function space_angel_mode_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

function space_angel_mode_modifier:GetModifierPercentageCooldown()
	return self:GetAbility():GetSpecialValueFor( "reduce_cooldowns")
end

function space_angel_mode_modifier:GetModifierModelScale()
	return 60
end
