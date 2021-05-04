ally_buff_heal = class({})

-----------------------------------------------------------------------------
-- Classifications
function ally_buff_heal:IsHidden()
	return false
end

function ally_buff_heal:IsDebuff()
	return false
end

function ally_buff_heal:GetTexture()
	return "shadow_demon_soul_catcher"
end
-----------------------------------------------------------------------------

function ally_buff_heal:OnCreated( kv )
	if not IsServer() then return end

end
----------------------------------------------------------------------------

function ally_buff_heal:OnRefresh( kv )
	if not IsServer() then return end

end
----------------------------------------------------------------------------

function ally_buff_heal:OnDestroy()
	if not IsServer() then return end

end
----------------------------------------------------------------------------
