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

	--print("kv.sub = ", kv.sub)
	--print("kv.target_x = ", kv.target_x)

    -- init
    self.parent = self:GetParent()
	self.caster = self:GetCaster()

	-- ref eventually replace these with values from kv
	self.speed = self:GetAbility():GetSpecialValueFor("speed")
	-- 200 radius is the spell particle effect, if we change this number we need to change particle effect
	self.destroy_tree_radius = self:GetAbility():GetSpecialValueFor("destroy_tree_radius")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.stay_duration = self:GetAbility():GetSpecialValueFor("stay_duration")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.manaAmount = self:GetAbility():GetSpecialValueFor("manaAmount")

	self.caught_enemies = {}

    -- ref from main ability
    self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )
	self.interval = 1
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
		damage = self.damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self,
	}

    self:StartIntervalThink( self.move_interval )

    self:PlayMoveEffects()

end
--------------------------------------------------------------------------------

function saw_blade_thinker:OnIntervalThink()

	-- if no heroes destroy
	local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
    local heroes = HERO_LIST
	for _, hero in pairs(heroes) do
		--print("hero name ",hero:GetUnitName())
        if hero.playerLives > 0 then
            areAllHeroesDead = false
            break
        end
    end
    if areAllHeroesDead or self.caster:IsAlive() == false then
		self:Destroy()
	end

	if self.parent == nil then self:Destroy() end


	-- check mode
	if areAllHeroesDead == false and self.caster:IsAlive() == true then
		AddFOWViewer(DOTA_TEAM_GOODGUYS, self.parent:GetAbsOrigin(), 350, 0.5, false)
		if self.mode == MODE_MOVE then
			self:MoveThink()
		elseif self.mode == MODE_STAY then
			self:StayThink()
		elseif self.mode == MODE_RETURN then
			self:ReturnThink()
		end
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
		--self:StartIntervalThink( self.interval )

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
	self.currentTarget = self.caster:GetAbsOrigin()
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
	--DebugDrawCircle(previousSawbladeLocation, Vector(0,0,255), 128, 100, true, 60)
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

	--	the numbers in the X Y are the map diemensions
	local vNewPositionX = RandomInt(8622, 11550)
	local vNewPositionY = RandomInt(-11882, -8910)
	vNewPosition = Vector(vNewPositionX, vNewPositionY, 131)

	return vNewPosition
end
--------------------------------------------------------------------------------

function saw_blade_thinker:DestroyTrees()

	if self.currentSawbladeLocation ~= 0 then
		local sound_tree = "Hero_Shredder.Chakram.Tree"
		local trees = GridNav:GetAllTreesAroundPoint( self.currentSawbladeLocation, self.destroy_tree_radius, true )
		for _,tree in pairs(trees) do
			EmitSoundOnLocationWithCaster( tree:GetOrigin(), sound_tree, self.parent )
			tree:CutDown(self.caster:GetTeamNumber())
			self.caster:GiveMana(self.manaAmount)
		end
		--GridNav:DestroyTreesAroundPoint( self.currentSawbladeLocation, self.destroy_tree_radius, true )
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
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			-- damage
			self.damageTable.victim = enemy
			self.damageTable.damage = self.damage
			ApplyDamage( self.damageTable )

			-- particle effect on player hit 
			-- particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_spray.vpcf
			local particle = "particles/timber/ls_ti9_open_wounds_blood_spray_sawblade_blood.vpcf"

			local particle_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, enemy)

			ParticleManager:ReleaseParticleIndex( particle_cast )
		end
	
		-- whens player touches the sawablade does dmg
		for _,enemy in pairs(enemies) do
			if not self.caught_enemies[enemy] then
				self.caught_enemies[enemy] = true

				self.damageTable.victim = enemy
				self.damageTable.damage = 70

				ApplyDamage( self.damageTable )
			end
		end
	end
end
--------------------------------------------------------------------------------

function saw_blade_thinker:MovingHit()

	if self.currentSawbladeLocation ~= 0 then
		-- find enemies
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.currentSawbladeLocation,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			-- damage
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )

			-- particle effect on player hit 
			-- particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_spray.vpcf
			local particle = "particles/timber/ls_ti9_open_wounds_blood_spray_sawblade_blood.vpcf"

			local particle_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, enemy)

			ParticleManager:ReleaseParticleIndex( particle_cast )
		end
	end


end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayMoveEffects()

	-- need to destroy the previouys playeffect on second move but not on the first cast from the boss
	if self.bFirstBlade ~= true then
		ParticleManager:DestroyParticle( self.effect_cast, false )
		ParticleManager:ReleaseParticleIndex( self.effect_cast )
		--StopSoundOn( sound_cast, self.parent )
	end

    local particle_cast = "particles/units/heroes/hero_shredder/shredder_chakram.vpcf"
	--local sound_cast = "Hero_Shredder.Chakram"

	local direction = ( self.currentTarget - self.parent:GetOrigin() )
	direction.z = 0
	direction = direction:Normalized()

	--DebugDrawCircle(self.currentTarget, Vector(0,0,255), 128, 100, true, 60)

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    
    --EmitSoundOn( sound_cast, self.parent )
end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayStayEffects()

	--DebugDrawCircle(self.currentSawbladeLocation, Vector(255,0,0), 128, 50, true, 60)

	-- destroy previous particle and stop previous sound
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	-- Get Resources
	local particle_cast = "particles/econ/items/shredder/hero_shredder_icefx/shredder_chakram_stay_ice.vpcf"

	-- "particles/units/heroes/hero_shredder/shredder_chakram_stay.vpcf"
	-- Create Particle`
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )

end
--------------------------------------------------------------------------------

function saw_blade_thinker:PlayEffectsReturn()
	-- destroy previous particle
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	--DebugDrawCircle(self.currentSawbladeLocation, Vector(0,255,0), 128, 50, true, 60)

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

	self.caught_enemies = {}

	-- stop effects
	self:StopEffects()
	self:OnIntervalThink(-1)
	-- remove
	UTIL_Remove( self.parent )
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
