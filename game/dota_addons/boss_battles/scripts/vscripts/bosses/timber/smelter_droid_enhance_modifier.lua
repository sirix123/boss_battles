smelter_droid_enhance_modifier = ({})

function smelter_droid_enhance_modifier:IsHidden()
	return false
end

function smelter_droid_enhance_modifier:IsDebuff()
	return false
end

function smelter_droid_enhance_modifier:DestroyOnExpire()
	return true
end

-----------------------------------------------------------------------------

function smelter_droid_enhance_modifier:OnCreated( kv )
	self.stack_armor = 1
	self.stack_magic = 1
	self.mana_regen = 0.2
end

-----------------------------------------------------------------------------

function smelter_droid_enhance_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

-----------------------------------------------------------------------------

function smelter_droid_enhance_modifier:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self.stack_armor
end

function smelter_droid_enhance_modifier:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() * self.stack_magic
end

function smelter_droid_enhance_modifier:GetModifierConstantManaRegen()
	return self:GetStackCount() * self.mana_regen
end
