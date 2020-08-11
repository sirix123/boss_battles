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
        self:StartIntervalThink(0.03)

        -- check what the ability type is and do different indactors based on the type

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
