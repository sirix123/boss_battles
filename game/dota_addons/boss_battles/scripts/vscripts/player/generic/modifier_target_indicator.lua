modifier_target_indicator = class({})


--[[

    **HOW TO USE THIS**

    Apply this to your spell in ability phase start and remove... once the spell has finished casting

]]

function modifier_target_indicator:IsHidden()
    return true
end

function modifier_target_indicator:OnCreated(params)
    if IsServer() then
        self.parent = self:GetParent()
        self.origin = self.parent:GetAbsOrigin()
        self:StartIntervalThink(0.03)

        -- check what the ability type is and do different indactors based on the type
        local particle_line = ParticleManager:CreateParticle("particles/targeting/line.vpcf", PATTACH_WORLDORIGIN, self.parent);

        local target = Vector(self.origin.x * self.parent:GetForwardVector().x, self.origin.y * self.parent:GetForwardVector().y, self.origin.z * self.parent:GetForwardVector().z)
        local target_offset = Vector(0,0,0)

        ParticleManager:SetParticleControl(particle_line, 0, self.origin)
        ParticleManager:SetParticleControl(particle_line, 1, target * 1000);
        ParticleManager:SetParticleControl(particle_line, 2, target * 1500);

	end
end

function modifier_target_indicator:OnDestroy()
    if IsServer() then

    end
end

function modifier_target_indicator:OnIntervalThink()
    if not self.parent:IsAlive() then
		self:Destroy()
    end

    -- check what the ability type is and do different indactors based on the type (update the position of them)



end
