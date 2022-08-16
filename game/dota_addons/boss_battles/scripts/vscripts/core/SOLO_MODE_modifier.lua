
SOLO_MODE_modifier = class({})

--[[

    if SOLO_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "SOLO_MODE_modifier", { duration = -1 } )
    end

]]

-----------------------------------------------------------------------------

function SOLO_MODE_modifier:IsHidden()
	return false
end

function SOLO_MODE_modifier:RemoveOnDeath()
    return false
end

-----------------------------------------------------------------------------

function SOLO_MODE_modifier:OnCreated( kv )
    if IsServer() then
        self.outgoing_minus = -75
        self.total_health = -75
    end
end
-----------------------------------------------------------------------------

function SOLO_MODE_modifier:OnDestroy()
    if IsServer() then
    end
end
-----------------------------------------------------------------------------

function SOLO_MODE_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function SOLO_MODE_modifier:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.outgoing_minus
end

function SOLO_MODE_modifier:GetModifierExtraHealthPercentage( params )
	return self.total_health
end

--------------------------------------------------------------------------------


