q_meditate_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_meditate_modifier:IsHidden()
	return false
end

function q_meditate_modifier:IsDebuff()
	return false
end

function q_meditate_modifier:IsStunDebuff()
	return false
end

function q_meditate_modifier:IsPurgable()
	return true
end

function q_meditate_modifier:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

--------------------------------------------------------------------------------
-- Initializations
function q_meditate_modifier:OnCreated( kv )
	-- references
	--self.damage = self:GetAbility():GetSpecialValueFor( "fiend_grip_damage" ) -- special value
	--self.mana = self:GetAbility():GetSpecialValueFor( "fiend_grip_mana_drain" ) -- special value
	--self.interval = self:GetAbility():GetSpecialValueFor( "fiend_grip_tick_interval" ) -- special value

	-- Start interval
	if IsServer() then

		-- start interval
		self:OnIntervalThink()
		self:StartIntervalThink( 0.5 )

		-- play effects
	end
end

function q_meditate_modifier:OnDestroy( kv )
	if IsServer() then
        --if self:GetParent():IsChanneling() then
            self:GetParent():Stop()
            self:GetParent():FindAbilityByName("m1_sword_slash"):SetActivated(true)
            self:GetParent():FindAbilityByName("m2_sword_slam"):SetActivated(true)
            --self:GetParent():FindAbilityByName("q_meditate"):SetActivated(true)
            self:GetParent():FindAbilityByName("e_spawn_ward"):SetActivated(true)
			self:GetParent():FindAbilityByName("r_sword_slam"):SetActivated(true)
			self:GetParent():FindAbilityByName("space_chain_hook"):SetActivated(true)
		--end
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function q_meditate_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function q_meditate_modifier:GetOverrideAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

--------------------------------------------------------------------------------
-- Status Effects
function q_meditate_modifier:CheckState()
	local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function q_meditate_modifier:OnIntervalThink()
	if IsServer() then
        self:GetParent():GiveMana(16)
	end
end
