q_arcane_cage_modifier_templar = class({})

function q_arcane_cage_modifier_templar:IsHidden()
	return false
end

function q_arcane_cage_modifier_templar:IsDebuff()
	return false
end

function q_arcane_cage_modifier_templar:IsPurgable()
	return false
end

function q_arcane_cage_modifier_templar:OnCreated()
    if IsServer() then
    end
end

function q_arcane_cage_modifier_templar:OnIntervalThink()
    if IsServer() then

    end
end

function q_arcane_cage_modifier_templar:OnDestroy()
    if IsServer() then

    end
end

function q_arcane_cage_modifier_templar:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function q_arcane_cage_modifier_templar:GetModifierTotalDamageOutgoing_Percentage( params )
	return self:GetAbility():GetSpecialValueFor( "outgoing_damage_bonus" )
end

function q_arcane_cage_modifier_templar:GetModifierConstantManaRegen( params )
    return self:GetAbility():GetSpecialValueFor( "mana_regen" )
end
--------------------------------------------------------------------------------

