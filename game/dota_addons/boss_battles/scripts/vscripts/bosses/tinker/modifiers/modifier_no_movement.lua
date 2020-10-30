modifier_no_movement = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_no_movement:IsHidden()
	return false
end

function modifier_no_movement:IsDebuff()
	return false
end

function modifier_no_movement:IsPurgable()
	return true
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_no_movement:OnCreated( kv )

end

function modifier_no_movement:OnDestroy()

end

--------------------------------------------------------------------------------

function modifier_no_movement:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true }
end

