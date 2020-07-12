casting_modifier_thinker = class({})

function casting_modifier_thinker:IsHidden() 
    return false 
end	

function casting_modifier_thinker:OnCreated(params)
    if IsServer() then
        self.parent = self:GetParent()
        self:StartIntervalThink(0.03)

        if params.bMovementLock == 1  then
            self.parent:SetMoveCapability(0)
        elseif params.pMovespeedReduction ~= nil then
            self.MoveSpeedReduction = params.pMovespeedReduction
        elseif params.bMovementLock == nil and params.pMovespeedReduction == nil then
            self.MoveSpeedReduction = -50

        end
	end
end

function casting_modifier_thinker:OnDestroy()
    if IsServer() then
        self.parent:SetMoveCapability(1)
    end
end

function casting_modifier_thinker:OnIntervalThink()
    if not self.parent:IsAlive() then
		self:Destroy()
    end

    -- init mouse locations
    local mouse = GameMode.mouse_positions[self.parent:GetPlayerID()]
    local mouseDirection = (mouse - self.parent:GetOrigin()):Normalized()

    -- while this modifier is active set the casters forward vector
    self.parent:SetForwardVector(Vector(mouseDirection.x, mouseDirection.y, self.parent:GetForwardVector().z ))
    self.parent:FaceTowards(self.parent:GetAbsOrigin() + Vector(mouseDirection.x, mouseDirection.y, self.parent:GetForwardVector().z ))

end

function casting_modifier_thinker:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function casting_modifier_thinker:GetModifierMoveSpeedBonus_Percentage()
	return self.MoveSpeedReduction
end
