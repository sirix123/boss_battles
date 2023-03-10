casting_modifier_thinker = class({})

function casting_modifier_thinker:IsHidden()
    return true
end
-----------------------------------------------------------------

function casting_modifier_thinker:OnCreated(params)
    if IsServer() then
        self.parent = self:GetParent()
        self.interval = 0.03
        self:StartIntervalThink(self.interval)

        if params.bMovementLock == 1  then
            self.parent:SetMoveCapability(0)
        elseif params.pMovespeedReduction ~= nil then
            self.MoveSpeedReduction = params.pMovespeedReduction
        elseif params.bMovementLock == nil and params.pMovespeedReduction == nil then
            self.MoveSpeedReduction = -50
        end

        if params.bSpellLock == 1  then
            self.silenced = true
        else
            self.silenced = false
        end

        if params.animation_sequence then
            self.animation_sequence = params.animation_sequence
        else
            self.animation_sequence = nil
        end

        if params.bTurnRateLimit == 1 then
            self.bTurnRateLimit = true

            -- init turn rate limiting
            self.turn_rate = 60
            local vec = Vector(self.parent.mouse.x, self.parent.mouse.y, self.parent.mouse.z)
            self:SetDirection( vec )
            self.current_dir = self.target_dir
            self.face_target = true
            self.parent:SetForwardVector( self.current_dir )
            self.turn_speed = self.interval*self.turn_rate

        end

        if params.bFaceTarget == 1 then
            self.bFaceTarget = true

            self.target = EntIndexToHScript(params.target)

			self.parent:SetForwardVector(Vector(self.target:GetAbsOrigin().x, self.target:GetAbsOrigin().y, self.parent:GetForwardVector().z ))
			self.parent:FaceTowards(self.parent:GetAbsOrigin() + Vector(self.target:GetAbsOrigin().x, self.target:GetAbsOrigin().y, self.parent:GetForwardVector().z ))

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

    if self.bTurnRateLimit ~= true then
        local mouse = Vector(self.parent.mouse.x, self.parent.mouse.y, self.parent.mouse.z)
        local mouseDirection = (mouse - self.parent:GetOrigin()):Normalized()
        self.parent:SetForwardVector(Vector(mouseDirection.x, mouseDirection.y, self.parent:GetForwardVector().z ))
        self.parent:FaceTowards(self.parent:GetAbsOrigin() + Vector(mouseDirection.x, mouseDirection.y, self.parent:GetForwardVector().z ))
    elseif self.bTurnRateLimit == true then
        local vec = Vector(self.parent.mouse.x, self.parent.mouse.y, self.parent.mouse.z)
        self:SetDirection( vec )
        self:TurnLogic()
    end

    if self.bFaceTarget == true then
        local targetDirection = (self.target:GetAbsOrigin() - self.parent:GetOrigin()):Normalized()
        self.parent:SetForwardVector(Vector(targetDirection.x, targetDirection.y, self.parent:GetForwardVector().z ))
        self.parent:FaceTowards(self.parent:GetAbsOrigin() + Vector(targetDirection.x, targetDirection.y, self.parent:GetForwardVector().z )) 
    end

end

function casting_modifier_thinker:TurnLogic()
    if self.face_target then return end

	local current_angle = VectorToAngles( self.current_dir ).y
    local target_angle = VectorToAngles( self.target_dir ).y
	local angle_diff = AngleDiff( current_angle, target_angle )

	local sign = -1
	if angle_diff<0 then sign = 1 end

	if math.abs( angle_diff )<1.1*self.turn_speed then
		-- end rotating
		self.current_dir = self.target_dir
		self.face_target = true
	else
		-- rotate
		self.current_dir = RotatePosition( Vector(0,0,0), QAngle(0, sign*self.turn_speed, 0), self.current_dir )
	end

	-- set facing when not motion controlled
	local a = self.parent:IsCurrentlyHorizontalMotionControlled()
    local b = self.parent:IsCurrentlyVerticalMotionControlled()
    if not (a or b) then
		self.parent:SetForwardVector( self.current_dir )
	end
end
-----------------------------------------------------------------

function casting_modifier_thinker:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
    }
end

function casting_modifier_thinker:GetModifierMoveSpeedBonus_Percentage()
	return self.MoveSpeedReduction
end
-----------------------------------------------------------------

function casting_modifier_thinker:SetDirection( vec )
	self.target_dir = ((vec-self.parent:GetAbsOrigin())*Vector(1,1,0)):Normalized()
	self.face_target = false
end

-----------------------------------------------------------------

function casting_modifier_thinker:GetActivityTranslationModifiers()
    if self.animation_sequence then
        return self.animation_sequence
    end
end
-----------------------------------------------------------------

function casting_modifier_thinker:CheckState()

	state = {
			[MODIFIER_STATE_SILENCED] = self.silenced
    }

	return state
end
