flak_cannon_modifier = class({})

function flak_cannon_modifier:GetEffectName()
	return "particles/units/heroes/hero_gyrocopter/gyro_flak_cannon_overhead.vpcf"
end

function flak_cannon_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function flak_cannon_modifier:OnCreated(keys)
	-- print("flak_cannon_modifier:OnCreated")
	--print("keys = ", dump(keys))

	self.stacks = keys.stacks
	self.duration = keys.duration
	self.radius = keys.radius
	self.fresh_rounds = 2 --no idea what this is used for 
	--self.fresh_rounds		= self:GetAbility():GetSpecialValueFor("fresh_rounds")
	--from: https://github.com/EarthSalamander42/dota_imba/blob/d6cec0e250bbd5308e3ea42993f4b7df738c9aa9/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_gyrocopter.lua
	--https://github.com/EarthSalamander42/dota_imba/blob/48c82a37ee4e9baa0c4b3025d6db88aa092d02a5/game/dota_addons/dota_imba_reborn/scripts/npc/heroes/gyrocopter/abilities.txt
	
	if not IsServer() then return end
	
	--not sure what this is/does, found in example code
	self.weapons = {"attach_attack1", "attach_attack2"}
	
	self:SetStackCount(self.stacks)
end

function flak_cannon_modifier:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function flak_cannon_modifier:OnAttack(keys)
	-- print("flak_cannon_modifier:OnAttack(keys)")
	-- print("keys.attacker = ", keys.attacker)
	-- print("keys.no_attack_cooldown = ", keys.no_attack_cooldown)

	--no idea what this is checking and it's breaking my code.. keys
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and not keys.no_attack_cooldown then
		self:GetParent():EmitSound("Hero_Gyrocopter.FlackCannon")
		
		--this code came from the dota_imba repo... maybe rewrite
		-- "Does not target couriers, wards, buildings, invisible units, or units inside the Fog of War."
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)) do
			if enemy ~= keys.target and not enemy:IsCourier() then

				self:GetParent():PerformAttack(enemy, false, self:GetStackCount() > self.stacks - self.fresh_rounds, true, true, true, false, false)
				--self:GetParent():RemoveModifierByName("modifier_imba_gyrocopter_flak_cannon_speed_handler")
			end
		end

		self:DecrementStackCount()
		
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
	end
end