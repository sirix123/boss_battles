m2_energy_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function m2_energy_buff:IsHidden()
	return false
end

function m2_energy_buff:IsDebuff()
	return false
end

function m2_energy_buff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function m2_energy_buff:OnCreated( kv )
    if IsServer() then
        -- references
		self.energy_regen_bonus = self:GetAbility():GetSpecialValueFor( "energy_regen_bonus" )

    end
end

function m2_energy_buff:OnRefresh( kv )
	if IsServer() then
    end
end

function m2_energy_buff:OnRemoved()
end

function m2_energy_buff:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function m2_energy_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}

	return funcs
end

function m2_energy_buff:GetModifierConstantManaRegen()
	return self.energy_regen_bonus
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function m2_energy_buff:GetEffectName()
	return "particles/econ/items/clinkz/clinkz_ti9_immortal/clinkz_ti9_strafe_embers.vpcf"
end

function m2_energy_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end