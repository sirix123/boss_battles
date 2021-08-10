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

		self.health_bar_off_set = self:GetCaster():GetBaseHealthBarOffset()

		self:GetCaster():SetHealthBarOffsetOverride(500)

        local particle = "particles/orcale/techies_earthshaker_totem_ti6_buff_longer.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle, PATTACH_POINT_FOLLOW, self:GetCaster() )
        local attach = "attach_hitloc"
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            0,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            attach,
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )

    end
end
----------------------------------------------------------------------------


function space_angel_mode_modifier:OnDestroy()
	if IsServer() then
		if self.effect_cast then
			ParticleManager:DestroyParticle(self.effect_cast,true)
		end

		self:GetCaster():SetHealthBarOffsetOverride(self.health_bar_off_set)
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
