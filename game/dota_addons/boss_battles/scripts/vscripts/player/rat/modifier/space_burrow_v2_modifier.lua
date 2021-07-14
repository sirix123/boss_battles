space_burrow_v2_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function space_burrow_v2_modifier:IsHidden()
	return false
end

function space_burrow_v2_modifier:IsDebuff()
	return false
end

-----------------------------------------------------------------------------

function space_burrow_v2_modifier:OnCreated( kv )
	if not IsServer() then return end

	--print("space_burrow_v2_modifier:OnCreated")

end

function space_burrow_v2_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function space_burrow_v2_modifier:OnRemoved()
    if not IsServer() then return end

end

function space_burrow_v2_modifier:OnDestroy()
	if not IsServer() then return end


end
----------------------------------------------------------------------------
