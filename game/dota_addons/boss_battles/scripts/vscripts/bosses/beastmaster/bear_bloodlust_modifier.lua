
bear_bloodlust_modifier = class({})

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_e.vpcf"
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:GetStatusEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_e.vpcf"
end
-----------------------------------------------------------------------------

function bear_bloodlust_modifier:OnCreated( kv )
	self.bloodlust_speed = self:GetAbility():GetSpecialValueFor( "bloodlust_speed" )
	self.bloodlust_as_speed = self:GetAbility():GetSpecialValueFor( "bloodlust_as_speed" )
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	return self.bloodlust_speed * self:GetStackCount()
end

--------------------------------------------------------------------------------

function bear_bloodlust_modifier:GetModifierAttackSpeedBonus_Constant( params )
		return self.bloodlust_as_speed * self:GetStackCount()
end


