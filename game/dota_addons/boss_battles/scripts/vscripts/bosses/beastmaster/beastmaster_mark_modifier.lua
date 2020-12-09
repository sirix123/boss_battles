
beastmaster_mark_modifier = class({})


-----------------------------------------------------------------------------
function beastmaster_mark_modifier:IsDebuff()
	return true
end

-----------------------------------------------------------------------------
function beastmaster_mark_modifier:IsHidden()
	return false
end

-- Initializations
function beastmaster_mark_modifier:OnCreated( kv )
	if IsServer() then
		--[[local particle = "particles/beastmaster/beastrmark_overhead_icon.vpcf"
		self.head_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.head_particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.head_particle, 1, Vector(0,0,0))
		ParticleManager:SetParticleControl(self.head_particle, 3, Vector(0,0,0))]]
	end
end

function beastmaster_mark_modifier:OnRefresh( kv )

end

function beastmaster_mark_modifier:OnDestroy( kv )
	if IsServer() then
		--ParticleManager:DestroyParticle(self.head_particle, true)
	end
end

-----------------------------------------------------------------------------

function beastmaster_mark_modifier:GetEffectName()
	--return "particles/beastmaster/beastrmark_overhead_icon.vpcf"
end

function beastmaster_mark_modifier:GetEffectAttachType()
	--return PATTACH_OVERHEAD_FOLLOW
end
