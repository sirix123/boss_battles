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

	local particle_cast = "particles/qop/qop_ally_buff_generic_stack_numbers.vpcf"
	self.effect_cast = ParticleManager:CreateParticleForPlayer(particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
	ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())

end
----------------------------------------------------------------------------

function ally_buff_heal:OnRefresh( kv )
	if not IsServer() then return end

end
----------------------------------------------------------------------------

function ally_buff_heal:OnDestroy()
	if not IsServer() then return end

	if self.effect_cast ~= nil then
		ParticleManager:DestroyParticle(self.effect_cast, true)
	end

end
----------------------------------------------------------------------------
