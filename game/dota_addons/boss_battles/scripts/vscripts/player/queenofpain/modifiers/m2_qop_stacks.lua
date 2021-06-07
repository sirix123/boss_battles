m2_qop_stacks = class({})

-----------------------------------------------------------------------------
-- Classifications
function m2_qop_stacks:IsHidden()
	return false
end

function m2_qop_stacks:IsDebuff()
	return false
end

function m2_qop_stacks:GetTexture()
	return "queenofpain_blink"
end
-----------------------------------------------------------------------------

function m2_qop_stacks:OnCreated( kv )
	if not IsServer() then return end

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
	end

	if self:GetStackCount() < 3 then
		self:IncrementStackCount()

		--[[local particleName = "particles/qop/qop_player_generic_stack_numbers.vpcf"
		self.particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		print("self:GetStackCount() ",self:GetStackCount())
		ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self:GetStackCount(), 0))]]
	end
end

function m2_qop_stacks:OnRefresh( kv )
	if not IsServer() then return end

	self:OnCreated()

end

function m2_qop_stacks:OnRemoved()
    if not IsServer() then return end

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
	end

	if self:GetStackCount() > 1 then
		local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "m2_qop_stacks", { duration = 3 } )
		if modifier then
			modifier:SetStackCount( self:GetStackCount() - 1 )
		end
	end

end

function m2_qop_stacks:OnDestroy()
	if not IsServer() then return end

end
----------------------------------------------------------------------------

