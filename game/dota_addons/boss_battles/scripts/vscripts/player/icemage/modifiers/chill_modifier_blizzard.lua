
chill_modifier_blizzard = class({})

-----------------------------------------------------------------------------

function chill_modifier_blizzard:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function chill_modifier_blizzard:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function chill_modifier_blizzard:GetStatusEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function chill_modifier_blizzard:OnCreated( kv )
	--if IsServer() then

		self.ms_slow = kv.ms_slow
		self.as_slow = kv.as_slow


		--print(self.ms_slow)
		--print(self.as_slow)

    --end
end
----------------------------------------------------------------------------

function chill_modifier_blizzard:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end
-----------------------------------------------------------------------------

function chill_modifier_blizzard:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms_slow
end
--------------------------------------------------------------------------------

function chill_modifier_blizzard:GetModifierAttackSpeedBonus_Constant( params )
	return self.as_slow
end
--------------------------------------------------------------------------------