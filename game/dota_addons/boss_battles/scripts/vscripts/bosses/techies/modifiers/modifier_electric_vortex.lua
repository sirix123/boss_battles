modifier_electric_vortex = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_electric_vortex:IsHidden()
	return false
end

function modifier_electric_vortex:IsDebuff()
	return true
end

function modifier_electric_vortex:IsStunDebuff()
	return true
end

function modifier_electric_vortex:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_electric_vortex:OnCreated( kv )
	-- references
	self.distance = self:GetAbility():GetSpecialValueFor( "electric_vortex_pull_distance" )

	if not IsServer() then return end
	self.center = Vector( kv.x, kv.y, 0 )
	self.center = GetGroundPosition( self.center, nil )

	self.speed = self.distance/self:GetDuration()

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

	self:PlayEffects()
end

function modifier_electric_vortex:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_electric_vortex:OnRemoved()
end

function modifier_electric_vortex:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )

	-- stop effects
	local sound_cast = "Hero_StormSpirit.ElectricVortex"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_electric_vortex:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_electric_vortex:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_electric_vortex:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_electric_vortex:UpdateHorizontalMotion( me, dt )
	self.direction = self.center - me:GetOrigin()
	local dist = self.direction:Length2D()
	self.direction.z = 0
	self.direction = self.direction:Normalized()

	if dist<10 then
		me:SetOrigin( self.center )
		return
	end

	local target = me:GetOrigin() + self.direction*self.speed*dt
	me:SetOrigin( target )
end

function modifier_electric_vortex:OnHorizontalMotionInterrupted()
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_electric_vortex:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf"
	local sound_cast = "Hero_StormSpirit.ElectricVortex"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self.center )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end