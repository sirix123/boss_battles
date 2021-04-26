m2_sword_slam_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function m2_sword_slam_debuff:IsHidden()
	return false
end

function m2_sword_slam_debuff:IsDebuff()
	return false
end

function m2_sword_slam_debuff:IsPurgable()
	return false
end

function m2_sword_slam_debuff:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function m2_sword_slam_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------
-- Initializations
function m2_sword_slam_debuff:OnCreated( kv )
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

function m2_sword_slam_debuff:OnRefresh( kv )
	if IsServer() then
		self:OnCreated()
	end
end

function m2_sword_slam_debuff:OnDestroy( kv )
	if IsServer() then
		-- destroy number stacks
		ParticleManager:DestroyParticle(self.particle, true)
	end
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function m2_sword_slam_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function m2_sword_slam_debuff:GetModifierBaseAttackTimeConstant()
	return -self.delta_bat
end]]

--------------------------------------------------------------------------------
