furnace_modifier_1 = class({})

--------------------------------------------------------------------------------
-- Classifications
function furnace_modifier_1:IsHidden()
	return false
end

function furnace_modifier_1:IsDebuff()
	return false
end

function furnace_modifier_1:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function furnace_modifier_1:OnCreated( kv )
end

function furnace_modifier_1:OnRefresh( kv )
end

function furnace_modifier_1:OnRemoved()
end

function furnace_modifier_1:OnDestroy()
end
