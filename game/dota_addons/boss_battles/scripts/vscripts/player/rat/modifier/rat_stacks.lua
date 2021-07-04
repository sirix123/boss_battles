rat_stacks = class({})

-----------------------------------------------------------------------------
-- Classifications
function rat_stacks:IsHidden()
	return false
end

function rat_stacks:IsDebuff()
	return false
end

function rat_stacks:GetTexture()
	return "hoodwink_acorn_shot"
end
-----------------------------------------------------------------------------

function rat_stacks:OnCreated( kv )
	if not IsServer() then return end

	self.max_stacks = self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_max" )

	if self.particle and self:GetStackCount() < self.max_stacks then
		ParticleManager:DestroyParticle(self.particle, true)
	end

	if self:GetCaster():HasModifier("stim_pack_buff") == true then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
		local particleName = "particles/rat/rat_player_generic_stack_numbers.vpcf"
		self.particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self.max_stacks, 0))
	end

	if self:GetStackCount() < self.max_stacks and self:GetCaster():HasModifier("stim_pack_buff") == false then
		self:IncrementStackCount()

		local particleName = "particles/rat/rat_player_generic_stack_numbers.vpcf"
		self.particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self:GetStackCount(), 0))

	end
end

function rat_stacks:OnRefresh( kv )
	if not IsServer() then return end

	self:OnCreated()

end

function rat_stacks:OnRemoved()
    if not IsServer() then return end

end

function rat_stacks:OnDestroy()
	if not IsServer() then return end

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
	end

end
----------------------------------------------------------------------------

