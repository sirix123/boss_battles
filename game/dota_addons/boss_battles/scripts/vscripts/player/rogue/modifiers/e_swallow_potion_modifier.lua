e_swallow_potion_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function e_swallow_potion_modifier:IsHidden()
	return false
end

function e_swallow_potion_modifier:IsDebuff()
	return false
end

function e_swallow_potion_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function e_swallow_potion_modifier:OnCreated( kv )
    if IsServer() then
        -- references
		--self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )
		self:SetStackCount(1)

		local caster = self:GetCaster()
		self.effectIndex = ParticleManager:CreateParticle(
			"particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave_playerglow.vpcf",
			PATTACH_CUSTOMORIGIN,
			caster)
		ParticleManager:SetParticleControlEnt(self.effectIndex , 0, caster, 5, "attach_attack2", Vector(0,0,0), true)
    end
end

function e_swallow_potion_modifier:OnRefresh( kv )
	if IsServer() then
		if self:GetStackCount() < 3 then
			self:IncrementStackCount()

		end

    end
end

function e_swallow_potion_modifier:OnRemoved()
end

function e_swallow_potion_modifier:OnDestroy()
	ParticleManager:DestroyParticle(self.effectIndex, true)
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function e_swallow_potion_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function e_swallow_potion_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end]]

--------------------------------------------------------------------------------
--[[ Graphics & Animations
function e_swallow_potion_modifier:GetEffectName()
	return "particles/econ/items/bristleback/bristle_quest_ti8/bristle_quest_weapon_ti8_ambient_glow.vpcf"
end

function e_swallow_potion_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end]]