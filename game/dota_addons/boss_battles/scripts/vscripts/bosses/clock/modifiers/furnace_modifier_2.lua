furnace_modifier_2 = class({})

--------------------------------------------------------------------------------
-- Classifications
function furnace_modifier_2:IsHidden()
	return false
end

function furnace_modifier_2:IsDebuff()
	return false
end

function furnace_modifier_2:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function furnace_modifier_2:OnCreated( kv )
end

function furnace_modifier_2:OnRefresh( kv )
end

function furnace_modifier_2:OnRemoved()
end

function furnace_modifier_2:OnDestroy()
end
