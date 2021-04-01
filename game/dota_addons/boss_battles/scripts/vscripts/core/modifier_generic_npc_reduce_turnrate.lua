modifier_generic_npc_reduce_turnrate = class({})
-----------------------------------------------------------------------------

function modifier_generic_npc_reduce_turnrate:RemoveOnDeath()
    return true
end

function modifier_generic_npc_reduce_turnrate:OnCreated( kv )
    if IsServer() then

        self.parent = self:GetParent()

        self.interval = 0.03

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            5000,
            DOTA_TEAM_BADGUYS,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false )

        if #enemies == 0 or enemies == nil then
            self:Destroy()
        else
            self.target = enemies[RandomInt(1,#enemies)]
            self.turn_rate = 25
            local vec = self.target:GetAbsOrigin()
            self:SetDirection( vec )
            self.current_dir = self.target_dir
            self.face_target = true
            self.parent:SetForwardVector( self.current_dir )
            self.turn_speed = self.interval*self.turn_rate

            self:StartIntervalThink(self.interval)

        end

    end
end
----------------------------------------------------------------------------

function modifier_generic_npc_reduce_turnrate:OnIntervalThink()
    if IsServer() then
        if not self.parent:IsAlive() then
            self:Destroy()
        end
        local vec = self.target:GetAbsOrigin()
        self:SetDirection( vec )
        self:TurnLogic()
    end
end

function modifier_generic_npc_reduce_turnrate:TurnLogic()
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

function modifier_generic_npc_reduce_turnrate:SetDirection( vec )
	self.target_dir = ((vec-self.parent:GetAbsOrigin())*Vector(1,1,0)):Normalized()
	self.face_target = false
end

