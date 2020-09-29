r_explosive_tip_modifier_target = class({})

--------------------------------------------------------------------------------
-- Classifications
function r_explosive_tip_modifier_target:IsHidden()
	return false
end

function r_explosive_tip_modifier_target:IsDebuff()
	return true
end

function r_explosive_tip_modifier_target:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function r_explosive_tip_modifier_target:OnCreated( kv )
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		--print(self.caster:GetPlayerOwner())

		self.ability = self.caster:FindAbilityByName("r_explosive_tip")

		self.dmg_per_stack = self.ability:GetSpecialValueFor("dmg_per_stack")
		self.aoe_radius = self.ability:GetSpecialValueFor("aoe_radius")

		self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")

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

function r_explosive_tip_modifier_target:OnRefresh( kv )
	if IsServer() then
		self:OnCreated()
	end
end

function r_explosive_tip_modifier_target:OnDestroy()
	if IsServer() then

		-- dmg formulae -- dmg part
		local dmg = self:GetStackCount() * self.dmg_per_stack

		local enemies = FindUnitsInRadius(
            self.caster:GetTeam(),
            self.parent:GetAbsOrigin(),
            nil,
            self.aoe_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        if enemies ~= nil then
			for _, enemy in pairs(enemies) do
				-- dmg
				local dmgTable = {
					victim = enemy,
					attacker = self.caster,
					damage = dmg,
					damage_type = self.ability:GetAbilityDamageType(),
					ability = self,
				}

				ApplyDamage(dmgTable)
            end
        end

		-- play explode effect
		local particleEffect = "particles/ranger/ranger_techies_land_mine_explode.vpcf"--"particles/ranger/ranger_phoenix_supernova_reborn_sphere_shockwave.vpcf"
		self.particle_2 = ParticleManager:CreateParticle(particleEffect, PATTACH_WORLDORIGIN, self.parent)
		ParticleManager:SetParticleControl(self.particle_2, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle_2, 1, Vector(0,0,100))
		ParticleManager:ReleaseParticleIndex(self.particle_2)

		-- destroy number stacks
		ParticleManager:DestroyParticle(self.particle, true)
	end
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function r_explosive_tip_modifier_target:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function r_explosive_tip_modifier_target:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end]]

--------------------------------------------------------------------------------
-- Graphics & Animations
function r_explosive_tip_modifier_target:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function r_explosive_tip_modifier_target:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end