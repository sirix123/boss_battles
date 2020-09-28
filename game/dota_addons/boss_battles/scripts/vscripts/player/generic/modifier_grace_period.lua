modifier_grace_period = class ({})

--- Misc 
function modifier_grace_period:IsHidden()
    return false
end

function modifier_grace_period:DestroyOnExpire()
    return true
end

function modifier_grace_period:IsPurgable()
    return false
end

function modifier_grace_period:RemoveOnDeath()
    return true
end

function modifier_grace_period:GetTexture()
    return "omniknight_guardian_angel"
end


function modifier_grace_period:OnCreated( kv )
end
--------------------------------------------------------------------------------
-- Modifier Effects
-- Status Effects
function modifier_grace_period:CheckState()

    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end
