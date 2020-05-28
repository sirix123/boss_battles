remove_attack_modifier = class ({})

--- Misc 
function remove_attack_modifier:IsHidden()
    return false
end

function remove_attack_modifier:DestroyOnExpire()
    return false
end

function remove_attack_modifier:IsPurgable()
    return false
end

function remove_attack_modifier:RemoveOnDeath()
    return false
end


function remove_attack_modifier:OnCreated( kv )
end
--------------------------------------------------------------------------------
-- Modifier Effects
-- Status Effects
function remove_attack_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

function remove_attack_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
    }
    return funcs
end


function remove_attack_modifier:GetDisableAutoAttack()
    return true
end
