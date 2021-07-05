e_sigil_of_power_modifier = class({})

function e_sigil_of_power_modifier:IsHidden()
	return false
end

function e_sigil_of_power_modifier:IsDebuff()
	return false
end

function e_sigil_of_power_modifier:IsPurgable()
	return false
end

function e_sigil_of_power_modifier:OnCreated()
    if IsServer() then

        self.total_mana_spent = 0

    end
end

function e_sigil_of_power_modifier:OnIntervalThink()
    if IsServer() then

    end
end

function e_sigil_of_power_modifier:OnDestroy()
    if IsServer() then

        -- do some calc here to determine the % dmg gain from spent mana
        self.damage_boost = self.total_mana_spent / 15

        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "e_sigil_of_power_modifier_buff",
        {
            duration = self:GetAbility():GetSpecialValueFor("duration_buff"),
            damage_boost = self.damage_boost,
        })

    end
end

function e_sigil_of_power_modifier:DeclareFunctions()
	local funcs = {
	    MODIFIER_EVENT_ON_SPENT_MANA,
	}
	return funcs
end

function e_sigil_of_power_modifier:OnSpentMana(params)
    if IsServer() then

        if params.unit == self:GetParent() then
            local ability = params.ability
            local mana_cost = ability:GetManaCost(-1)

            if mana_cost then
                self.total_mana_spent = self.total_mana_spent +  mana_cost
            end

        end

    end
end