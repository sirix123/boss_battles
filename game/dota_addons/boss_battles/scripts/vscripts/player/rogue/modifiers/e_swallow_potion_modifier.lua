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

    end
end

function e_swallow_potion_modifier:OnRefresh( kv )
	if IsServer() then
		if self:GetStackCount() < 5 then
			self:IncrementStackCount()

		end

    end
end

function e_swallow_potion_modifier:OnRemoved()
end

function e_swallow_potion_modifier:OnDestroy()

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
-- Graphics & Animations
function e_swallow_potion_modifier:GetEffectName()
	return "particles/econ/courier/courier_wabbit/courier_wabbit_ambient_salve_lvl3_smoke.vpcf"
end

function e_swallow_potion_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end