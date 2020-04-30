smelter_droid_enhance_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function smelter_droid_enhance_modifier:IsHidden()
	return false
end

function smelter_droid_enhance_modifier:IsDebuff()
	return true
end

function smelter_droid_enhance_modifier:IsStunDebuff()
	return false
end

function smelter_droid_enhance_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function smelter_droid_enhance_modifier:OnCreated( kv )
	-- references
	self.buffTickRate = 0.5
	self.radius = 500
	local interval = 0.1

	self.buffTickRate = self.buffTickRate * interval

	if IsServer() then
		self.parent = self:GetParent()

		-- Start interval
		self:StartIntervalThink( interval )
		-- play effects
		self:PlayEffects()
	end
end

function smelter_droid_enhance_modifier:OnRefresh( kv )
end

function smelter_droid_enhance_modifier:OnRemoved()
end

function smelter_droid_enhance_modifier:OnDestroy()
	if not IsServer() then return end

	-- unregister if not forced destroy
	if not self.forceDestroy then
		self:GetAbility():Unregister( self )
	end

end

--------------------------------------------------------------------------------
-- Interval Effects
function smelter_droid_enhance_modifier:OnIntervalThink()

	-- check distance
	if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>self.radius then
		self:Destroy()
		return
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function smelter_droid_enhance_modifier:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/timber/droid_smelter_lion_spell_mana_drain.vpcf"

	-- Get Data

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_mouth",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end