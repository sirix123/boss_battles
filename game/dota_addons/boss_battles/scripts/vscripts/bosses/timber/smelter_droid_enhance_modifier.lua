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
	self.stack_armor = 15
	self.healthregen = 15
end

-----------------------------------------------------------------------------
--[[
function smelter_droid_enhance_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-----------------------------------------------------------------------------

function smelter_droid_enhance_modifier:GetModifierPhysicalArmorBonus()
	return self.stack_armor
end

function smelter_droid_enhance_modifier:GetModifierConstantHealthRegen()
	return self.healthregen
end]]


