space_disperse_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function space_disperse_modifier:IsHidden()
	return false
end

function space_disperse_modifier:IsDebuff()
	return false
end

function space_disperse_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function space_disperse_modifier:OnCreated( kv )
    --self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )
	--if IsServer() then
		-- references
		self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )
		self.invul = true
	--end
end

function space_disperse_modifier:OnRefresh( kv )
	-- same as oncreated
	self:OnCreated( kv )
end

function space_disperse_modifier:OnRemoved()
end

function space_disperse_modifier:OnDestroy()
	self.invul = false
	--local sound_cast = "Hero_PhantomAssassin.Blur.Break"
	--EmitSoundOn( sound_cast, caster )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function space_disperse_modifier:DeclareFunctions()
	--if IsServer() then
		local funcs = {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}

		return funcs
	--end
end

function space_disperse_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

function space_disperse_modifier:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = self.invul, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

--------------------------------------------------------------------------------
-- Graphics & Animations
function space_disperse_modifier:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function space_disperse_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end