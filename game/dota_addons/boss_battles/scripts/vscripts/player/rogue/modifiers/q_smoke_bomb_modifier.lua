q_smoke_bomb_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_smoke_bomb_modifier:IsHidden()
	return false
end

function q_smoke_bomb_modifier:IsDebuff()
	return false
end

function q_smoke_bomb_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function q_smoke_bomb_modifier:OnCreated( kv )
	if IsServer() then
		-- references
		self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )
		self.invul_time = self:GetAbility():GetSpecialValueFor( "invul_time" )
		self.invul = true
	end
end

function q_smoke_bomb_modifier:OnRefresh( kv )
	-- same as oncreated
	self:OnCreated( kv )
end

function q_smoke_bomb_modifier:OnRemoved()
end

function q_smoke_bomb_modifier:OnDestroy()
	self.invul = false
	local sound_cast = "Hero_PhantomAssassin.Blur.Break"
	EmitSoundOn( sound_cast, caster )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function q_smoke_bomb_modifier:DeclareFunctions()
	if IsServer() then
		local funcs = {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}

		return funcs
	end
end

function q_smoke_bomb_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

function q_smoke_bomb_modifier:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = self.invul, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

--------------------------------------------------------------------------------
-- Graphics & Animations
function q_smoke_bomb_modifier:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_active_blur.vpcf"
end

function q_smoke_bomb_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end