modifier_flying = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_flying:IsHidden()
	return false
end

function modifier_flying:IsDebuff()
	return false
end

function modifier_flying:IsPurgable()
	return true
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_flying:OnCreated( kv )

end

function modifier_flying:OnDestroy()

end

--------------------------------------------------------------------------------

function modifier_flying:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true }
end

