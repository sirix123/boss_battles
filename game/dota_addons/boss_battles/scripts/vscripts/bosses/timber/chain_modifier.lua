--[[

    This script needs to handle the following: 
      


]]

chain_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function chain_modifier:IsHidden()
	return false
end

function chain_modifier:IsDebuff()
	return false
end

function chain_modifier:IsStunDebuff()
	return false
end

function chain_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function chain_modifier:OnCreated( kv )
	if not IsServer() then return end

	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.point = Vector( kv.point_x, kv.point_y, kv.point_z )
	self.effect = kv.effect

	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}

	-- init
	self.proximity = 50
	self.caught_enemies = {}

	-- start motion controller
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function chain_modifier:OnRefresh( kv )
	if not IsServer() then return end
	local old_effect = self.effect

	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.point = Vector( kv.point_x, kv.point_y, kv.point_z )
	self.effect = kv.effect

	-- update damage
	self.damageTable.damage = damage

	-- init
	self.caught_enemies = {}

	-- destroy previous effect
	ParticleManager:DestroyParticle( old_effect, false )
	ParticleManager:ReleaseParticleIndex( old_effect )
end

function chain_modifier:OnRemoved()
end

function chain_modifier:OnDestroy()
	if not IsServer() then return end

	-- remove effect
	ParticleManager:DestroyParticle( self.effect, false )
	ParticleManager:ReleaseParticleIndex( self.effect )

	-- play sound
	local sound_cast = "Hero_Shredder.TimberChain.Impact"
	EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Status Effects
function chain_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function chain_modifier:UpdateHorizontalMotion( me, dt )
	local origin = me:GetOrigin()
	local direction = (self.point-origin)
	direction.z = 0
	direction = direction:Normalized()

	-- set origin
	local target = origin + direction * self.speed * dt
	me:SetOrigin( target )

	-- find enemies
	local enemies = FindUnitsInRadius(
		me:GetTeamNumber(),	-- int, your team number
		origin,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- check if already hit
		if not self.caught_enemies[enemy] then
			self.caught_enemies[enemy] = true

			-- damage
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )

			-- play effects
			self:PlayEffects( enemy )
		end
	end

	-- destroy if stunned
	if me:IsStunned() then
		me:RemoveHorizontalMotionController( self )
		self:Destroy()
	end

	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), 20, true )

	-- destroy if reached target
	-- does something here when he reaches destination? 
	if (self.point-origin):Length2D()<self.proximity then
		-- destroy tree
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), 20, true )

		-- set position
		self:GetParent():SetOrigin( self.point )

		-- destroy
		me:RemoveHorizontalMotionController( self )
		self:Destroy()
	end

end

function chain_modifier:OnHorizontalMotionInterrupted()
	-- destroy
	self:GetParent():RemoveHorizontalMotionController( self )
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function chain_modifier:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_shredder/shredder_timber_dmg.vpcf"
	local sound_cast = "Hero_Shredder.TimberChain.Damage"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end