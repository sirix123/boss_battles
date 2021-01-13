m2_sword_slam_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function m2_sword_slam_buff:IsHidden()
	return false
end

function m2_sword_slam_buff:IsDebuff()
	return false
end

function m2_sword_slam_buff:IsPurgable()
	return false
end

function m2_sword_slam_buff:GetEffectName()
    --return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function m2_sword_slam_buff:GetEffectAttachType()
    --return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------
-- Initializations
function m2_sword_slam_buff:OnCreated( kv )
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()

		self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")

		if self.particle and self:GetStackCount() < self.max_stacks then
			ParticleManager:DestroyParticle(self.particle, true)
		end

		if self:GetStackCount() < self.max_stacks then
			self:IncrementStackCount()

			local particleName = "particles/player_generic_stack_numbers.vpcf"
			self.particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_OVERHEAD_FOLLOW, self.parent, self.caster:GetPlayerOwner())
			ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self:GetStackCount(), 0))
			--ParticleManager:ReleaseParticleIndex(self.particle)
			--ParticleManager:DestroyParticle(self.particle, true)
		end
	end
end

function m2_sword_slam_buff:OnRefresh( kv )
	if IsServer() then
		self:OnCreated()
	end
end

function m2_sword_slam_buff:OnDestroy( kv )
	if IsServer() then
		-- destroy number stacks
		ParticleManager:DestroyParticle(self.particle, true)
	end
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function m2_sword_slam_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function m2_sword_slam_buff:GetModifierBaseAttackTimeConstant()
	return -self.delta_bat
end]]

--------------------------------------------------------------------------------
