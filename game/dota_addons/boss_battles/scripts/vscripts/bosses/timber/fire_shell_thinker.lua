fire_shell_thinker = class({})

local MODE_MOVE = 0

function fire_shell_thinker:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function fire_shell_thinker:OnCreated( kv )
	if not IsServer() then return end

    -- init
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    
    DebugDrawCircle(self.parent:GetAbsOrigin(), Vector(0,0,255), 128, 100, true, 60)

    -- ref eventually replace these with values from kv
    self.speed = 500
	self.interval = 1

    -- ref from kv
    self.direction = Vector( kv.direction_x, kv.direction_y, kv.direction_z )
    self.velocity = self.direction * self.speed

    -- init vars
    self.mode = MODE_MOVE
    self.move_interval = FrameTime()
    self.zLimit = 300

    self:StartIntervalThink( self.move_interval )

end
--------------------------------------------------------------------------------

function fire_shell_thinker:OnIntervalThink()
    -- check mode
	if self.mode == MODE_MOVE then
		self:MoveThink()
    end
end
--------------------------------------------------------------------------------

function fire_shell_thinker:MoveThink()

    -- this needs to follow the projectile 

	-- move logic
	local destoryProj = self:MoveLogic(self.parent:GetAbsOrigin() )

	-- if close, switch to stay mode
	if destoryProj then
		self:DestroyLogic()
    end
end
--------------------------------------------------------------------------------

function fire_shell_thinker:DestroyLogic()

   

end

--------------------------------------------------------------------------------
function fire_shell_thinker:MoveLogic(previousFireShellLocation)
	DebugDrawCircle(previousFireShellLocation, Vector(0,255,0), 128, 100, true, 60)
	self.currentFireShellLocation = previousFireShellLocation + self.direction * self.speed * self.move_interval

	--print(self.currentFireShellLocation.z)
	if self.currentFireShellLocation.z > 256 then
		print("YO IM REALLY HIGH UP")
	end

	self.parent:SetAbsOrigin( self.currentFireShellLocation )

	if ( self.currentFireShellLocation.z  > self.zLimit ) then
		return true
	end
end
