casting_modifier_thinker = class({})

function casting_modifier_thinker:IsHidden() 
    return true 
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

		if not self.ignore_activation_cycle then
			for i = 0, 15 do
				local ability = self.parent:GetAbilityByIndex(i)
				if ability and ability ~= self:GetAbility() then
					ability:SetActivated(false)
				end
			end
		end

	end
end

function casting_modifier_thinker:OnDestroy()
    if IsServer() then
        self.parent:SetMoveCapability(1)

		if not self.ignore_activation_cycle then
			for i = 0, 15 do
				local ability = self.parent:GetAbilityByIndex(i)
				if ability and ability ~= self:GetAbility() then
					ability:SetActivated(true)
				end
			end
		end

    end
end

function casting_modifier_thinker:OnIntervalThink()
    if not self.parent:IsAlive() then
		self:Destroy()
    end

    -- init mouse locations
    --local mouse = PlayerManager.mouse_positions[self.parent:GetPlayerID()]
    local mouse = Vector(self.parent.mouse.x, self.parent.mouse.y, self.parent.mouse.z)
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
