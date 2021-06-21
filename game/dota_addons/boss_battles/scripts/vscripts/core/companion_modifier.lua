companion_modifier = class({})

function companion_modifier:IsHidden() return true end
function companion_modifier:GetAbsoluteNoDamagePhysical() return 1 end
function companion_modifier:GetAbsoluteNoDamageMagical() return 1 end
function companion_modifier:GetAbsoluteNoDamagePure() return 1 end

-- Thanks dota imba and earthsalamander!

function companion_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	if self.is_flying == 1 then
		state[MODIFIER_STATE_FLYING] = true
	end

	return state
end

function companion_modifier:DeclareFunctions() return {
	MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
	MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
	MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
} end

function companion_modifier:GetVisualZDelta()
	if self.is_flying == 1 then
		return 290
	end

	return 0
end

-- add "ultimate_scepter" + "enchant_totem_leap_from_battle"
function companion_modifier:GetActivityTranslationModifiers()
	if self:GetParent():GetModelName() == "models/heroes/phantom_assassin/pa_arcana.vmdl" then
		return "arcana"
	end

	return ""
end

function companion_modifier:OnCreated()
	if IsServer() then
		self.is_flying = false
		self.set_final_pos = false

		self:StartIntervalThink(0.1)
	end
end


function companion_modifier:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function companion_modifier:OnIntervalThink()
	if IsServer() then
		local companion = self:GetParent()
		local hero = self:GetCaster()

		local hero_origin = hero:GetAbsOrigin()
		local hero_distance = (hero_origin - companion:GetAbsOrigin()):Length()
		local min_distance = 250
		local blink_distance = 750

		if companion:GetIdealSpeed() ~= hero:GetIdealSpeed() - 70 then
			companion:SetBaseMoveSpeed(hero:GetIdealSpeed() - 70)
		end

		if hero:IsInvisible() then
			companion:AddNewModifier(companion, nil, "modifier_invisible", {})
		else
			companion:RemoveModifierByNameAndCaster("modifier_invisible", companion)
		end

		if hero_distance < min_distance then
			if hero:IsMoving() == false and self.set_final_pos == false then
				self.set_final_pos = true
				companion:MoveToPosition(hero:GetAbsOrigin() + RandomVector(200))
				return
			elseif hero:IsMoving() and self.set_final_pos == true then
				self.set_final_pos = false
			end
		elseif hero_distance > blink_distance then
			FindClearSpaceForUnit(companion, hero_origin, false)
			self.set_final_pos = true
			companion:Stop()
		elseif hero_distance > min_distance then
			if not companion:IsMoving() then
				companion:MoveToNPC(hero)
			end
		end
	end
end