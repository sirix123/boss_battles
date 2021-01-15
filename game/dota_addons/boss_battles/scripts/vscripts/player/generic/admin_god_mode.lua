admin_god_mode = class({})

function admin_god_mode:IsDebuff() return false end

function admin_god_mode:OnCreated()
    if IsServer() then

	end
end

function admin_god_mode:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end

function admin_god_mode:GetModifierPercentageCooldown()
    return -80
end

function admin_god_mode:GetModifierIncomingDamage_Percentage()
    return -99
end

function admin_god_mode:GetModifierHealthRegenPercentage()
    return 10
end