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
	return
end

function bonechill_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function bonechill_modifier:OnCreated( kv )
	if IsServer() then
        print("bonechill applied to caster")
    end
end
----------------------------------------------------------------------------

function bonechill_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function bonechill_modifier:OnDestroy()
    if IsServer() then
    end
end
----------------------------------------------------------------------------

function bonechill_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function bonechill_modifier:GetModifierConstantManaRegen ( params )
	return 10
end
--------------------------------------------------------------------------------

function bonechill_modifier:GetModifierPercentageCooldown( params )
	return 50
end
--------------------------------------------------------------------------------