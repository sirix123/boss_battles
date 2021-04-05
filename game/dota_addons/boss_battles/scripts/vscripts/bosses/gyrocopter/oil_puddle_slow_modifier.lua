
oil_puddle_slow_modifier = class({})

-----------------------------------------------------------------------------

function oil_puddle_slow_modifier:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function oil_puddle_slow_modifier:GetEffectName()
	--return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end
-----------------------------------------------------------------------------

function oil_puddle_slow_modifier:GetStatusEffectName()
	--return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end
-----------------------------------------------------------------------------

function oil_puddle_slow_modifier:OnCreated( kv )
	--if IsServer() then

		self.ms_slow = -50

		--print(self.ms_slow)
		--print(self.as_slow)

    --end
end
----------------------------------------------------------------------------

function oil_puddle_slow_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function oil_puddle_slow_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms_slow
end
--------------------------------------------------------------------------------
