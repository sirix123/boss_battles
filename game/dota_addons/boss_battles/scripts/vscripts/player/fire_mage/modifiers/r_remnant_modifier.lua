r_remnant_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function r_remnant_modifier:IsHidden()
	return true
end

function r_remnant_modifier:IsDebuff()
	return false
end

function r_remnant_modifier:IsPurgable()
	return true
end

function r_remnant_modifier:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf"
end

function r_remnant_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function r_remnant_modifier:StatusEffectPriority()
	return 20
end

function r_remnant_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

--------------------------------------------------------------------------------
-- Initializations
function r_remnant_modifier:OnCreated( kv )
    if IsServer() then
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
    end
end

function r_remnant_modifier:OnRefresh( kv )
	if IsServer() then

    end
end

function r_remnant_modifier:OnRemoved()

end

function r_remnant_modifier:OnDestroy()
	if IsServer() then

		self.parent:Destroy()


	end
end

--------------------------------------------------------------------------------

function r_remnant_modifier:CheckState()
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