--[[

    This file handles the 'thinking' after the sawblade has be created on the map / projectile launched
    This script needs to handle the following: 
        Launch speed
        Launch direction
        Movement direction and location
        Movement speed
        Damage + tick rate
		Destroying trees
		Radius
		mana on tree death modifier or generic usable function
]]

saw_blade_thinker = class({})

local MODE_MOVE = 0
local MODE_STAY = 1
local MODE_RETURN = 2

function saw_blade_thinker:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function saw_blade_thinker:OnCreated( kv )
	if not IsServer() then return end

	print("kv.sub = ", kv.sub)
	print("kv.target_x = ", kv.target_x)

    -- init
    self.parent = self:GetParent()
	self.caster = self:GetCaster()

    -- ref eventually replace these with values from kv
    self.speed = 400
	self.interval = 1
	-- 200 radius is the spell particle effect, if we change this number we need to change particle effect
	self.destroy_tree_radius = 50
	self.radius = 200
	self.stay_duration = 5
	self.damage = 0
	self.manaAmount = 2

    -- ref from kv
    self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

    self.sub = kv.sub

    -- init vars
    self.mode = MODE_MOVE
	self.move_interval = FrameTime()
	self.bFirstBlade = true
	self.proximity = 40
	self.currentSawbladeLocation = 0
	self.last_move_time = 0
	self.fl_staytrigger_end_time = 0
	self.damageTable = {
		attacker = self.caster,
		damage = self.damage ,
		damage_type = self:GetAbility():GetAbilityDamageType(),
	}

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
	elseif self.mode == MODE_RETURN then
		self:ReturnThink()
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:MoveThink()

	if self.bFirstBlade == true then
		self.currentSawbladeLocation = self.parent:GetAbsOrigin()
	end

	self:DestroyTrees()
	self:ApplySawBladeDamage()
	
	-- move logic
	local close = self:MoveLogic( self.currentSawbladeLocation )

	-- if close, switch to stay mode
	if close then
		self.last_move_time = GameRules:GetGameTime()
		self.mode = MODE_STAY

		-- play effects
		self:PlayStayEffects()
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:StayThink()

	self:DestroyTrees()
	self:ApplySawBladeDamage()

	-- check if we need to end the stay think and start moving again
	local endStay = self:StayLogic()

	if endStay then
		self:PlayMoveEffects()
		self.mode = MODE_MOVE
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:ReturnThink()

	self:DestroyTrees()
	self:ApplySawBladeDamage()
	
	-- move logic
	local close = self:MoveLogic( self.currentSawbladeLocation )

	-- if close, switch to stay mode
	if close then
		self:Destroy()
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:ReturnChakram()
	-- if already returning, do nothing
	if self.mode == MODE_RETURN then return end

	-- switch mode
	self.mode = MODE_RETURN

	-- play effects
	self:PlayEffectsReturn()
end
--------------------------------------------------------------------------------

function saw_blade_thinker:MoveLogic(previousSawbladeLocation)
	local direction = (self.currentTarget - previousSawbladeLocation):Normalized()
	self.currentSawbladeLocation = previousSawbladeLocation + direction * self.speed * self.move_interval

	self.parent:SetAbsOrigin( self.currentSawbladeLocation )
	self.bFirstBlade = false

	if ( self.currentSawbladeLocation - self.currentTarget ):Length2D() < self.proximity then
		return true
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:StayLogic()
	self.fl_staytrigger_end_time = self.last_move_time + self.stay_duration

	self.currentTarget = self:NewPositionLogic()

	return GameRules:GetGameTime() > self.fl_staytrigger_end_time
end
--------------------------------------------------------------------------------

function saw_blade_thinker:NewPositionLogic()
	local vNewPosition = Vector(0,0,0)

	-- ideas
	-- 		the numbers in the X Y are the map diemensions
	-- 		at level 1 when arena is small only move them in a smaller raidus around the an origin (boss location). DO WE NEED LOGIC FOR EARLY FIGHT AND LATE FIGHT?
	local vNewPositionX = RandomInt(6590, 10467) + 200
	local vNewPositionY = RandomInt(11248, 15090) + 200
	vNewPosition = Vector(vNewPositionX, vNewPositionY, 255)

	return vNewPosition
end
--------------------------------------------------------------------------------

function saw_blade_thinker:DestroyTrees()

	if self.currentSawbladeLocation ~= 0 then
		local sound_tree = "Hero_Shredder.Chakram.Tree"
		local trees = GridNav:GetAllTreesAroundPoint( self.currentSawbladeLocation, self.destroy_tree_radius, true )
		for _,tree in pairs(trees) do
			EmitSoundOnLocationWithCaster( tree:GetOrigin(), sound_tree, self.parent )
			self.caster:GiveMana(self.manaAmount)
		end
		GridNav:DestroyTreesAroundPoint( self.currentSawbladeLocation, self.destroy_tree_radius, true )
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:ApplySawBladeDamage()

	if self.currentSawbladeLocation ~= 0 then
		-- find enemies
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.currentSawbladeLocation,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			-- damage
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )
		end
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

	-- need to destroy the previouys playeffect on second move but not on the first cast from the boss
	if self.bFirstBlade ~= true then
		ParticleManager:DestroyParticle( self.effect_cast, false )
		ParticleManager:ReleaseParticleIndex( self.effect_cast )
		StopSoundOn( sound_cast, self.parent )
	end

    local particle_cast = "particles/units/heroes/hero_shredder/shredder_chakram.vpcf"
	local sound_cast = "Hero_Shredder.Chakram"

	local direction = ( self.currentTarget - self.parent:GetOrigin() )
	direction.z = 0
	direction = direction:Normalized()

	DebugDrawCircle(self.currentTarget, Vector(0,0,255), 128, 100, true, 60)

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    
    EmitSoundOn( sound_cast, self.parent )
end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayStayEffects()

	DebugDrawCircle(self.currentSawbladeLocation, Vector(255,0,0), 128, 50, true, 60)

	-- destroy previous particle and stop previous sound
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

function saw_blade_thinker:PlayEffectsReturn()
	-- destroy previous particle
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	DebugDrawCircle(self.currentSawbladeLocation, Vector(0,255,0), 128, 50, true, 60)

	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_shredder/shredder_chakram_return.vpcf"
	local sound_cast = "Hero_Shredder.Chakram.Return"
	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		1,
		self.caster,
		PATTACH_ABSORIGIN_FOLLOW,
		nil,
		self.caster:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( self.speed, 0, 0 ) )
	ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end
--------------------------------------------------------------------------------

function saw_blade_thinker:OnDestroy()
	if not IsServer() then return end

	--below code is causing errors to be thrown and doesnt seem to help in removing particles
	-- stop effects
	--self:StopEffects()
	-- remove
	--UTIL_Remove( self.parent )
end
--------------------------------------------------------------------------------

function saw_blade_thinker:StopEffects()
	-- destroy previous particle
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	-- stop sound
	local sound_cast = "Hero_Shredder.Chakram"
	StopSoundOn( sound_cast, self.parent )
end
