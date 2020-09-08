bonechill_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function bonechill_modifier:IsHidden()
	return false
end

function bonechill_modifier:IsDebuff()
	return false
end
-----------------------------------------------------------------------------

function bonechill_modifier:GetEffectName()
	return "particles/icemage/bonechill_wyvern_arctic_burn_slow.vpcf"
end

function bonechill_modifier:GetStatusEffectName()
	return "particles/icemage/bonechill_wyvern_arctic_burn_slow.vpcf"
end
-----------------------------------------------------------------------------

function bonechill_modifier:OnCreated( kv )
	--if not IsServer() then return end
	self.mana_regen = self:GetAbility():GetSpecialValueFor( "mana_regen")
end
----------------------------------------------------------------------------

function bonechill_modifier:OnRefresh( kv )
end
----------------------------------------------------------------------------

function bonechill_modifier:OnDestroy()
end
----------------------------------------------------------------------------

function bonechill_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end
-----------------------------------------------------------------------------

function bonechill_modifier:GetModifierConstantManaRegen ( params )
	return self.mana_regen
end
--------------------------------------------------------------------------------