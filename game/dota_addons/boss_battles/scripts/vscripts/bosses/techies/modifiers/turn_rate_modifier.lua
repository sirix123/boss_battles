turn_rate_modifier = class({})
-----------------------------------------------------------------------------

function turn_rate_modifier:RemoveOnDeath()
    return true
end

function turn_rate_modifier:OnCreated( kv )
    if IsServer() then

        self.turn_rate_reduction = -99
        self.turn_rate_reduction_override = nil

        if self:GetParent():GetUnitName() == "npc_gyrocopter" then
            self.turn_rate_reduction_override = 0.01
            print("this being applied?")
        end


    end
end
----------------------------------------------------------------------------


function turn_rate_modifier:OnRefresh( kv )
	if IsServer() then

    end
end

function turn_rate_modifier:OnDestroy( kv )
	if IsServer() then
    end
end
----------------------------------------------------------------------------

function turn_rate_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_TURN_RATE_OVERRIDE,
        }
        return funcs
end

function turn_rate_modifier:GetModifierTurnRate_Percentage()
    return self.turn_rate_reduction
end

function turn_rate_modifier:GetModifierTurnRate_Override()
	return self.turn_rate_reduction_override
end