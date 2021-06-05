beastmaster_puddle_dot_debuff_attack = class({})

function beastmaster_puddle_dot_debuff_attack:IsHidden()
	return false
end

function beastmaster_puddle_dot_debuff_attack:IsDebuff()
	return true
end

function beastmaster_puddle_dot_debuff_attack:IsPurgable()
	return false
end

function beastmaster_puddle_dot_debuff_attack:GetHeroEffectName()
	return "particles/beastmaster/green_ursa_enrage_buff_beastmaster.vpcf"
end

---------------------------------------------------------------------------

function beastmaster_puddle_dot_debuff_attack:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.dmg = 3 * kv.stacks
	end
end
---------------------------------------------------------------------------

function beastmaster_puddle_dot_debuff_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function beastmaster_puddle_dot_debuff_attack:OnAttackLanded( keys )
	if IsServer() then
		local owner = self:GetParent()

		if owner ~= keys.attacker then
			return end

        local target = keys.target

        target:AddNewModifier(owner,self:GetAbility(),"beastmaster_puddle_dot_debuff_attack_player_debuff",{duration = 10, dmg_per_tick = self.dmg})

	end
end
