droid_colour_modifier_red = ({})

function droid_colour_modifier_red:IsHidden()
	return true
end

function droid_colour_modifier_red:IsDebuff()
	return false
end

function droid_colour_modifier_red:DestroyOnExpire()
	return true
end

-----------------------------------------------------------------------------

function droid_colour_modifier_red:OnCreated( kv )
    if IsServer() then
        local parent	=	self:GetParent()
		local particle	=	"particles/timber/droid_red.vpcf"
		self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:SetParticleControlEnt(self.particle_fx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    end
end

-----------------------------------------------------------------------------


