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
	self.proximity = 10
	
	-- get position for second + move
	-- seperate into second function for more complex mvoment etc
	self.position = Vector( 1, 1, kv.target_z )

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
	local origin = self.parent:GetOrigin()

	-- move logic
	local close = self:MoveLogic( origin )

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

	local origin = self.parent:GetOrigin()
	-- move logic
	local close = self:MovePlusThink(  )

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

function saw_blade_thinker:MoveLogic(origin)
	-- move to the cursor point for the first blade
	print("moving (firstmove).. ")
	print("movelogic, origin = ", origin)
	local direction = (self.point - origin):Normalized()
	local target = origin + direction * self.speed * self.move_interval

	self.parent:SetOrigin( target )

	self.bFirstBlade = false

	return ( target - self.point ):Length2D() < self.proximity
end
--------------------------------------------------------------------------------

function saw_blade_thinker:StayLogic()
	FlStayTriggerEndTime = LAST_MOVE_TIME + self.stay_duration
	print(FlStayTriggerEndTime,"  ",GameRules:GetGameTime())

	self.secondOrigin = self.parent:GetOrigin()

	return GameRules:GetGameTime() > FlStayTriggerEndTime
end
--------------------------------------------------------------------------------

function saw_blade_thinker:MovePlusThink()
	print("position = ",self.position)
	print("origin = ", origin)
	local direction = (self.position - self.secondOrigin):Normalized()
	print("direction = ", direction)
	local target = self.secondOrigin + direction * self.speed * self.move_interval

	self.parent:SetOrigin( target )

	print("trying to move to.... ", target )

	return ( target - self.position ):Length2D() < self.proximity
end
--------------------------------------------------------------------------------

-- Aura Effects
function saw_blade_thinker:IsAura()
	return self.mode==MODE_STAY
end

function saw_blade_thinker:GetModifierAura()
	return --aura mod here if we wanna slow while inside etc
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

function saw_blade_thinker:OnDestroy()
	-- remove
	UTIL_Remove( self.parent )
end
--------------------------------------------------------------------------------
