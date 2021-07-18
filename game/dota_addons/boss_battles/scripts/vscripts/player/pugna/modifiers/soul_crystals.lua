soul_crystals = class({})

-----------------------------------------------------------------------------
-- Classifications
function soul_crystals:IsHidden()
	return false
end

function soul_crystals:IsDebuff()
	return false
end

function soul_crystals:GetTexture()
	return "necrolyte_death_pulse"
end
-----------------------------------------------------------------------------

function soul_crystals:OnCreated( kv )
	self.outgoing_plus = self:GetCaster():FindAbilityByName("pugna_passive"):GetSpecialValueFor( "outgoing_damage_per_shard" )
	if not IsServer() then return end

	self.max_stacks = self:GetCaster():FindAbilityByName("pugna_passive"):GetSpecialValueFor( "max_soul_shards" )

	self.outgoing_plus = self:GetCaster():FindAbilityByName("pugna_passive"):GetSpecialValueFor( "outgoing_damage_per_shard" )

	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end

end

function soul_crystals:OnStackCountChanged(iStackCount)
	if not IsServer() then return end

	if self.particle and self:GetStackCount() <= self.max_stacks then
		ParticleManager:DestroyParticle(self.particle, true)
	end

	if self:GetStackCount() <= self.max_stacks then
		local particleName = "particles/rat/rat_player_generic_stack_numbers.vpcf"
		self.particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self:GetStackCount(), 0))
	end

end

function soul_crystals:OnRefresh( kv )
	if not IsServer() then return end

	self:OnCreated()

end

function soul_crystals:OnRemoved()
    if not IsServer() then return end

end

function soul_crystals:OnDestroy()
	if not IsServer() then return end

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
	end

end
----------------------------------------------------------------------------

function soul_crystals:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function soul_crystals:GetModifierTotalDamageOutgoing_Percentage( params )
	if ( self.outgoing_plus * self:GetStackCount() ) ~= nil then
		return self.outgoing_plus * self:GetStackCount()
	end
end

--------------------------------------------------------------------------------

