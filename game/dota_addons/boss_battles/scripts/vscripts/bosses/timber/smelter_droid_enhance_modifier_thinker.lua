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
	self.mana = 2
	self.heal = 150

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

	-- every internval give him mana and health and playthis particle effect

	target:GiveMana(self.mana)
	local mana_word_length = string.len(tostring(math.floor(self.mana)))

	local mana_color =  Vector(70, 70, 250)
	local mana_effect_cast = ParticleManager:CreateParticle("particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) --particles/custom_msg_damage.vpcf particles/msg_fx/msg_damage.vpcf
	ParticleManager:SetParticleControl(mana_effect_cast, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(mana_effect_cast, 1, Vector(0, self.mana, 0))
	ParticleManager:SetParticleControl(mana_effect_cast, 2, Vector(0.5, mana_word_length, 0)) --vector(math.max(1, keys.damage / 10), word_length, 0))
	ParticleManager:SetParticleControl(mana_effect_cast, 3, mana_color)
	ParticleManager:ReleaseParticleIndex(mana_effect_cast)

	target:Heal(self.heal, self:GetCaster())
	local heal_word_length = string.len(tostring(math.floor(self.heal)))

	local heal_color =  Vector(70, 250, 70)
	local heal_effect_cast = ParticleManager:CreateParticle("particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) --particles/custom_msg_damage.vpcf particles/msg_fx/msg_damage.vpcf
	ParticleManager:SetParticleControl(heal_effect_cast, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(heal_effect_cast, 1, Vector(0, self.heal, 0))
	ParticleManager:SetParticleControl(heal_effect_cast, 2, Vector(0.5, heal_word_length, 0)) --vector(math.max(1, keys.damage / 10), word_length, 0))
	ParticleManager:SetParticleControl(heal_effect_cast, 3, heal_color)
	ParticleManager:ReleaseParticleIndex(heal_effect_cast)

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