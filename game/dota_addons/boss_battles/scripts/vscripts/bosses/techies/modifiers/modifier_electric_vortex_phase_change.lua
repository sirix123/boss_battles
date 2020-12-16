modifier_electric_vortex_phase_change = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_electric_vortex_phase_change:IsHidden()
	return true
end

function modifier_electric_vortex_phase_change:IsDebuff()
	return false
end

function modifier_electric_vortex_phase_change:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_electric_vortex_phase_change:OnCreated( kv )
    if not IsServer() then return end

end

function modifier_electric_vortex_phase_change:OnRefresh( kv )
	if not IsServer() then return end

end

function modifier_electric_vortex_phase_change:OnRemoved()
	if not IsServer() then return end

end

function modifier_electric_vortex_phase_change:OnDestroy()
	if not IsServer() then return end

end