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
	table.insert(tUNIT_TABLE, self:GetCaster():GetUnitName() )
end

function modifier_flying:OnDestroy()
	for k, unit in pairs(tUNIT_TABLE) do
        if unit == self:GetCaster():GetUnitName() then
            table.remove(tUNIT_TABLE,k)
        end
    end
end

--------------------------------------------------------------------------------

function modifier_flying:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true }
end

