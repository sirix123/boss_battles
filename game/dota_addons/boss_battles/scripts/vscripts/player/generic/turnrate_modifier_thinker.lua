turnrate_modifier_thinker = class({})

function turnrate_modifier_thinker:IsHidden()
    return true
end
-----------------------------------------------------------------

function turnrate_modifier_thinker:OnCreated(params)
    if IsServer() then
        self.parent = self:GetParent()




	end
end

function turnrate_modifier_thinker:OnDestroy()
    if IsServer() then
    end
end

function turnrate_modifier_thinker:OnIntervalThink()
    if IsServer() then

        self:TurnLogic()

    end
end

function turnrate_modifier_thinker:TurnLogic()
	-- only rotate when target changed
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

function turnrate_modifier_thinker:SetDirection( vec )
	self.target_dir = ((vec-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
	self.face_target = false
end
-----------------------------------------------------------------
