
easy_mode_modifier = class({})

--[[

    if EASY_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "easy_mode_modifier", { duration = -1 } )
    end

]]

-----------------------------------------------------------------------------

function easy_mode_modifier:IsHidden()
	return false
end

function easy_mode_modifier:RemoveOnDeath()
    return false
end

-----------------------------------------------------------------------------

function easy_mode_modifier:OnCreated( kv )
    if IsServer() then
        self.outgoing_minus = -20
        self.total_health = -20
    end
end
-----------------------------------------------------------------------------

function easy_mode_modifier:OnDestroy()
    if IsServer() then
    end
end
-----------------------------------------------------------------------------

function easy_mode_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function easy_mode_modifier:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.outgoing_minus
end

function easy_mode_modifier:GetModifierExtraHealthPercentage( params )
	return self.total_health
end

--------------------------------------------------------------------------------


