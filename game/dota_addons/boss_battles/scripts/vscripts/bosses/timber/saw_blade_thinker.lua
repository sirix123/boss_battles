--[[

    This file handles the 'thinking' after the sawblade has be created on the map / projectile launched
    This script needs to handle the following: 
        Launch speed
        Launch direction
        Movement direction and location
        Movement speed
        Damage + tick rate
        Radius
        Duration
        Destroying trees 
]]

saw_blade_thinker = class({})

local MODE_MOVE = 0
local MODE_STAY = 1
local MODE_MOVE_PLUS = 2

-- init globals
local LAST_MOVE_TIME = 0
local FlStayTriggerEndTime = 0

function saw_blade_thinker:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function saw_blade_thinker:OnCreated( kv )
	if not IsServer() then return end

    -- init
    self.parent = self:GetParent()
    self.caster = self:GetCaster()

    -- ref eventually replace these with values from kv
    self.speed = 400
    self.interval = 1
	self.radius = 100
	self.stay_duration = 5

    -- ref from kv
    self.point = Vector( kv.target_x, kv.target_y, kv.target_z )

    -- init vars
    self.mode = MODE_MOVE
	self.move_interval = FrameTime()
	self.bFirstBlade = true
	self.proximity = 80
	
	-- get position for second + move
	-- seperate into second function for more complex mvoment etc
	self.currentTarget = Vector( 0, 0, 0 )
	self.currentSawbladeLocation = 0

    -- init mode
    self:StartIntervalThink( self.move_interval )
    
    self:PlayMoveEffects()

end
--------------------------------------------------------------------------------

function saw_blade_thinker:OnIntervalThink()
    -- check mode
	if self.mode == MODE_MOVE then
		self:MoveThink()
	elseif self.mode == MODE_STAY then
		self:StayThink()
	elseif self.mode == MODE_MOVE_PLUS then
		self:MovePlusThink()
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:MoveThink()
	self.currentSawbladeLocation = self.parent:GetAbsOrigin()

	-- move logic
	local close = self:MoveLogic( self.currentSawbladeLocation )

	-- if close, switch to stay mode
	if close then
		LAST_MOVE_TIME = GameRules:GetGameTime()
		self.mode = MODE_STAY
		-- making this really small does good stuff. 0.1 eventually it will get there, 0.01 it gets there straight away, it only moves a couple map units per frame.
		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		-- play effects
		self:PlayStayEffects()
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:StayThink()

	-- check if we need to end the stay think and start moving again
	local endStay = self:StayLogic()

	if endStay then
		self:PlayMoveEffects2()
		self.mode = MODE_MOVE_PLUS
		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------

function saw_blade_thinker:MovePlusThink()
	-- move logic
	local close = self:MovePlusLogic(self.currentSawbladeLocation)

	-- if close, switch to stay mode
	if close then
		LAST_MOVE_TIME = GameRules:GetGameTime()
		self.mode = MODE_STAY
		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		-- play effects
		self:PlayStayEffects()
	end

end
--------------------------------------------------------------------------------

function saw_blade_thinker:MoveLogic(previousSawbladeLocation)
	-- move to the cursor point for the first blade
	local direction = (self.point - previousSawbladeLocation):Normalized()
	self.currentSawbladeLocation = previousSawbladeLocation + direction * self.speed * self.move_interval

	self.parent:SetAbsOrigin( self.currentSawbladeLocation )
	self.bFirstBlade = false

	return ( self.currentSawbladeLocation - self.point ):Length2D() < self.proximity
end
--------------------------------------------------------------------------------

function saw_blade_thinker:StayLogic()
	FlStayTriggerEndTime = LAST_MOVE_TIME + self.stay_duration
	print(FlStayTriggerEndTime,"  ",GameRules:GetGameTime())

	self.currentTarget = Vector( 14082, 14744, 255 )

	return GameRules:GetGameTime() > FlStayTriggerEndTime
end
--------------------------------------------------------------------------------

function saw_blade_thinker:MovePlusLogic(previousSawbladeLocation)
	local direction = (self.currentTarget - previousSawbladeLocation):Normalized()
	self.currentSawbladeLocation = previousSawbladeLocation + direction * self.speed * self.move_interval

	self.parent:SetAbsOrigin( self.currentSawbladeLocation )

	print("where are we?.... ", self.currentSawbladeLocation )
	print("trying to move to.... ", self.currentTarget )

	if ( self.currentSawbladeLocation - self.currentTarget ):Length2D() < self.proximity then
		return true
	end
end
--------------------------------------------------------------------------------

-- Aura Effects
function saw_blade_thinker:IsAura()
	return self.mode==MODE_STAY
end

function saw_blade_thinker:GetModifierAura()
	return --"saw_blade_modifier"
	-- might aid with code readability if we use this new modifier to do damage as well? keep timing/moving in this file only?
end

function saw_blade_thinker:GetAuraRadius()
	return self.radius
end

function saw_blade_thinker:GetAuraDuration()
	return 0.3
end

function saw_blade_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function saw_blade_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function saw_blade_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayMoveEffects()

    local particle_cast = "particles/units/heroes/hero_shredder/shredder_chakram.vpcf"
	local sound_cast = "Hero_Shredder.Chakram"

	local direction = ( self.point - self.parent:GetOrigin() )
	direction.z = 0
	direction = direction:Normalized()

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    
    EmitSoundOn( sound_cast, self.parent )
end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayStayEffects()

	DebugDrawCircle(self.currentSawbladeLocation, Vector(255,0,0), 128, 50, true, 60)
	DebugDrawCircle(self.currentTarget, Vector(0,0,255), 128, 100, true, 60)

	-- destroy previous particle
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_shredder/shredder_chakram_stay.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )

end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayMoveEffects2()
	-- destroy previous particle
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

    local particle_cast = "particles/units/heroes/hero_shredder/shredder_chakram.vpcf"
	local sound_cast = "Hero_Shredder.Chakram"

	local direction = ( self.currentTarget - self.parent:GetOrigin() )
	direction.z = 0
	direction = direction:Normalized()

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    
    EmitSoundOn( sound_cast, self.parent )
end
--------------------------------------------------------------------------------

function saw_blade_thinker:OnDestroy()
	-- remove
	UTIL_Remove( self.parent )
end
--------------------------------------------------------------------------------
