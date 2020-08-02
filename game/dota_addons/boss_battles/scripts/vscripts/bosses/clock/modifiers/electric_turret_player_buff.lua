electric_turret_player_buff = class({})

-----------------------------------------------------------------------------

function electric_turret_player_buff:IsHidden()
	return false
end

function electric_turret_player_buff:IsDebuff()
	return false
end
-----------------------------------------------------------------------------

function electric_turret_player_buff:GetEffectName()
	return "particles/clock/player_minion_ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function electric_turret_player_buff:GetStatusEffectName()
	return "particles/clock/player_minion_ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end
-----------------------------------------------------------------------------

function electric_turret_player_buff:OnCreated( kv )
	if IsServer() then
        self.damage_increase = 20

    end
end
----------------------------------------------------------------------------

function electric_turret_player_buff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function electric_turret_player_buff:GetModifierBaseDamageOutgoing_Percentage( params )
	return self.damage_increase
end
--------------------------------------------------------------------------------
