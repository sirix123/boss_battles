turn_rate_modifier = class({})
-----------------------------------------------------------------------------

function turn_rate_modifier:RemoveOnDeath()
    return true
end

function turn_rate_modifier:OnCreated( kv )
    if IsServer() then

        self.turn_rate_reduction = -95

    end
end
----------------------------------------------------------------------------


function turn_rate_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function turn_rate_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        }
        return funcs
end

function turn_rate_modifier:GetModifierTurnRate_Percentage()
    return self.turn_rate_reduction
end