droid_colour_modifier_blue = ({})

function droid_colour_modifier_blue:IsHidden()
	return false
end

function droid_colour_modifier_blue:IsDebuff()
	return false
end

function droid_colour_modifier_blue:DestroyOnExpire()
	return true
end

-----------------------------------------------------------------------------

function droid_colour_modifier_blue:OnCreated( kv )
    if IsServer() then
        local parent	=	self:GetParent()
		local particle	=	"particles/timber/droid_blue.vpcf"
		self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:SetParticleControlEnt(self.particle_fx, 0, parent, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(self.particle_fx)
    end
end

-----------------------------------------------------------------------------


