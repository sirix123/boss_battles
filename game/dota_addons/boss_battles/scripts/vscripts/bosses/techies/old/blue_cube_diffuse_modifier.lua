blue_cube_diffuse_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function blue_cube_diffuse_modifier:IsHidden()
	return true
end

function blue_cube_diffuse_modifier:IsDebuff()
	return true
end

function blue_cube_diffuse_modifier:IsPurgable()
	return false
end

function blue_cube_diffuse_modifier:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function blue_cube_diffuse_modifier:OnCreated( kv )
    if not IsServer() then return end

end

function blue_cube_diffuse_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function blue_cube_diffuse_modifier:OnRemoved()
	if not IsServer() then return end

end

function blue_cube_diffuse_modifier:OnDestroy()
	if not IsServer() then return end

end
--------------------------------------------------------------------------------

function blue_cube_diffuse_modifier:OnIntervalThink()
    if not IsServer() then return end

end
