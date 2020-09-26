smelter_droid_enhance_modifier_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function smelter_droid_enhance_modifier_thinker:IsHidden()
	return true
end

function smelter_droid_enhance_modifier_thinker:IsDebuff()
	return false
end

function smelter_droid_enhance_modifier_thinker:IsStunDebuff()
	return false
end

function smelter_droid_enhance_modifier_thinker:IsPurgable()
	return false
end

function smelter_droid_enhance_modifier_thinker:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function smelter_droid_enhance_modifier_thinker:OnCreated( kv )
	-- references
	self.radius = 600
	local interval = 1.5

	if IsServer() then
		self.parent = self:GetParent()

		-- Start interval
		self:StartIntervalThink( interval )
		-- play effects
		self:PlayEffects()
	end
end

function smelter_droid_enhance_modifier_thinker:OnRefresh( kv )
end

function smelter_droid_enhance_modifier_thinker:OnRemoved()
end

function smelter_droid_enhance_modifier_thinker:OnDestroy()
	if not IsServer() then return end

	-- unregister if not forced destroy
	if not self.forceDestroy then
		self:GetAbility():Unregister( self )
	end

end

--------------------------------------------------------------------------------
-- Interval Effects
function smelter_droid_enhance_modifier_thinker:OnIntervalThink()

	local target = self:GetParent()

	-- add buff
	target:AddNewModifier( target, self, "smelter_droid_enhance_modifier", { duration = 5 } )
	-- add stack
	local hBuff = target:FindModifierByName( "smelter_droid_enhance_modifier" )
	hBuff:IncrementStackCount()
	-- get stack count and play sounds at each stack
	local nStackCount = hBuff:GetStackCount()
	if nStackCount == 5 then
		self.sound_cast = "shredder_timb_reactivearmor_01"
		EmitGlobalSound(self.sound_cast)
	elseif nStackCount == 10 then
		self.sound_cast = "shredder_timb_reactivearmor_02"
		EmitGlobalSound(self.sound_cast)
	elseif nStackCount == 15 then
		self.sound_cast = "shredder_timb_reactivearmor_03"
		EmitGlobalSound(self.sound_cast)
	elseif nStackCount == 20 then
		self.sound_cast = "shredder_timb_reactivearmor_04"
		EmitGlobalSound(self.sound_cast)
	elseif nStackCount == 25 then
		self.sound_cast = "shredder_timb_reactivearmor_05"
		EmitGlobalSound(self.sound_cast)
	end

	-- check distance
	if (target:GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>self.radius then
		self:Destroy()
		return
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function smelter_droid_enhance_modifier_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/timber/droid_smelter_lion_spell_mana_drain.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
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