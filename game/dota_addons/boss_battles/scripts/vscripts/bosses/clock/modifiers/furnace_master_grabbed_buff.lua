furnace_master_grabbed_buff = class({})

--------------------------------------------------------------------------------

function furnace_master_grabbed_buff:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function furnace_master_grabbed_buff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function furnace_master_grabbed_buff:DeclareFunctions()
	local funcs = 
	{
		--MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}
	return funcs
end

--------------------------------------------------------------------------------

--[[function furnace_master_grabbed_buff:GetActivityTranslationModifiers( params )
	return "tree"
end]]

--------------------------------------------------------------------------------

function furnace_master_grabbed_buff:GetModifierTurnRate_Percentage( params )
	return -95
end