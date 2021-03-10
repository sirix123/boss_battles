e_spawn_ward_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function e_spawn_ward_buff:IsHidden()
	return false
end

function e_spawn_ward_buff:IsDebuff()
	return false
end

function e_spawn_ward_buff:IsPurgable()
	return false
end

function e_spawn_ward_buff:GetTexture()
	return "axe_berserkers_call"
end

--------------------------------------------------------------------------------
-- Initializations
function e_spawn_ward_buff:OnCreated( kv )
	--if IsServer() then
		-- references
		self.dmg_reduction = 20
		self.heal_amount_per_tick = 20
	--end
end

function e_spawn_ward_buff:OnRefresh( kv )
end

function e_spawn_ward_buff:OnRemoved()
end

function e_spawn_ward_buff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function e_spawn_ward_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function e_spawn_ward_buff:GetModifierConstantHealthRegen()
	return self.heal_amount_per_tick
end

function e_spawn_ward_buff:GetModifierIncomingDamage_Percentage()
	return -self.dmg_reduction
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function e_spawn_ward_buff:GetEffectName()
	return "particles/units/heroes/hero_juggernaut/juggernaut_ward_heal.vpcf"
end

function e_spawn_ward_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end