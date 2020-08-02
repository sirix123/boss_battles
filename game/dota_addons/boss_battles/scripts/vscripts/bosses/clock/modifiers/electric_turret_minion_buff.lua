
electric_turret_minion_buff = class({})

-----------------------------------------------------------------------------

function electric_turret_minion_buff:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function electric_turret_minion_buff:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function electric_turret_minion_buff:GetStatusEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end
-----------------------------------------------------------------------------

function electric_turret_minion_buff:OnCreated( kv )
	if IsServer() then
        self.ms_bonus = 20

    end
end
----------------------------------------------------------------------------

function electric_turret_minion_buff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function electric_turret_minion_buff:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms_bonus
end
--------------------------------------------------------------------------------
