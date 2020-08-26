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
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
    end
end

function space_shadowstep_unit_modifier:OnRefresh( kv )
	if IsServer() then

    end
end

function space_shadowstep_unit_modifier:OnRemoved()

end

function space_shadowstep_unit_modifier:OnDestroy()
	if IsServer() then

		self.parent:Destroy()

		-- check what ability is in slot spacebar
		if self.caster:GetAbilityByIndex(5):GetAbilityName() == "space_shadowstep_teleport" then -- if dagger expires before teleporting to it then switch back to step 1
			self.caster:SwapAbilities("space_shadowstep_teleport", "space_shadowstep", false, true)
		elseif self.caster:GetAbilityByIndex(5):GetAbilityName() == "space_shadowstep_teleport_back" then -- normal use case of following daggers before modfier expires
            self.caster:SwapAbilities("space_shadowstep_teleport_back", "space_shadowstep", false, true)
        end

	end
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