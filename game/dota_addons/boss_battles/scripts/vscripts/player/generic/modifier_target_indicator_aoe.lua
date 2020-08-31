modifier_target_indicator_aoe = class({})


--[[

    **HOW TO USE THIS**

    Apply this to your spell in ability phase start and remove... once the spell has finished casting

    TODO add line indicator 
        I guess this is for spceific abilities which are rare which do not fit into the panorama use cases 
                icelance
]]

function modifier_target_indicator_aoe:IsHidden()
    return true
end
-------------------------------------------------------------------------------------------------------

function modifier_target_indicator_aoe:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.origin = self.parent:GetAbsOrigin()
        self:StartIntervalThink( FrameTime() )

        self.cast_range = kv.cast_range
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        self.particle_circle = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/range_finder_aoe.vpcf", PATTACH_WORLDORIGIN, self.parent, self.parent:GetPlayerOwner())

        self:PlayAoeEffect()

	end
end
-------------------------------------------------------------------------------------------------------

function modifier_target_indicator_aoe:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle_circle, true)
        ParticleManager:ReleaseParticleIndex(self.particle_circle)
    end
end
-------------------------------------------------------------------------------------------------------

function modifier_target_indicator_aoe:OnIntervalThink()
    if IsServer() then
        if not self.parent:IsAlive() then
            self:Destroy()
        end

        self:PlayAoeEffect()


    end
end
-------------------------------------------------------------------------------------------------------

function modifier_target_indicator_aoe:PlayAoeEffect()
    if IsServer() then

        local point = Clamp(self.parent:GetAbsOrigin(), Vector(self.parent.mouse.x, self.parent.mouse.y, self.parent.mouse.z), self.cast_range, 0)
        ParticleManager:SetParticleControl(self.particle_circle, 0, point)
        ParticleManager:SetParticleControl(self.particle_circle, 2, point);
        ParticleManager:SetParticleControl(self.particle_circle, 3, Vector(self.radius,0,0));
    end
end
-------------------------------------------------------------------------------------------------------
