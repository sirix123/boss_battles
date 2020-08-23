space_shadowstep_unit_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function space_shadowstep_unit_modifier:IsHidden()
	return false
end

function space_shadowstep_unit_modifier:IsDebuff()
	return false
end

function space_shadowstep_unit_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function space_shadowstep_unit_modifier:OnCreated( kv )
    if IsServer() then
        -- references
		--self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )

    end
end

function space_shadowstep_unit_modifier:OnRefresh( kv )
	if IsServer() then

    end
end

function space_shadowstep_unit_modifier:OnRemoved()
end

function space_shadowstep_unit_modifier:OnDestroy()

end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function space_shadowstep_unit_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function space_shadowstep_unit_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end]]

function space_shadowstep_unit_modifier:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
		}

		return state
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function space_shadowstep_unit_modifier:GetEffectName()
	return "particles/rogue/rogue_ember_spirit_fire_remnant.vpcf"
end

function space_shadowstep_unit_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end