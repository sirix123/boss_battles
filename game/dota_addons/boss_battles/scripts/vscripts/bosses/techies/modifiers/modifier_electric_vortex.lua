modifier_electric_vortex = class({})
LinkLuaModifier( "modifier_electric_vortex_phase_change", "bosses/techies/modifiers/modifier_electric_vortex_phase_change", LUA_MODIFIER_MOTION_NONE )

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
	if not IsServer() then return end

	--self.distance = self:GetAbility():GetSpecialValueFor( "electric_vortex_pull_distance" )

	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	--print("parent name ",self.parent:GetUnitName())

	self.distance = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin() ):Length2D()

	self.center = Vector( kv.x, kv.y, 0 )
	self.center = GetGroundPosition( self.center, nil )

	self.speed = 400

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

	-- add a modifier to the caster (this modifier is removed in phase 3 electroc vortex ai trap)
	self:GetCaster():AddNewModifier( nil, nil, "modifier_electric_vortex_phase_change", { duration = -1 } )
	
	if self:GetParent():GetUnitName() == "npc_rock_techies" then

		-- particle effect, explode
		local particle = "particles/econ/items/rubick/rubick_arcana/rbck_arc_venomancer_poison_nova_cubes.vpcf"
		local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nfx) 
	
		
		self:GetParent():RemoveSelf()
		self:GetCaster():ForceKill(false)

	end

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

	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	self.distance = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin() ):Length2D()

	self.direction = self.center - me:GetOrigin()
	local dist = self.direction:Length2D()
	self.direction.z = 0
	self.direction = self.direction:Normalized()

	local target = me:GetOrigin() + self.direction*self.speed*dt
	me:SetOrigin( target )

	if self.distance < 50 then
		self:Destroy()
		--me:SetOrigin( self.center )
	end
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