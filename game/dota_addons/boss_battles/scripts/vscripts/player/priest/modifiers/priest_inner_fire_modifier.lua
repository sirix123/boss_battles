priest_inner_fire_modifier = class({})

function priest_inner_fire_modifier:RemoveOnDeath()
    return true
end

function priest_inner_fire_modifier:IsHidden()
	return false
end

function priest_inner_fire_modifier:IsDebuff()
	return false
end

function priest_inner_fire_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function priest_inner_fire_modifier:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
end

function priest_inner_fire_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end
-----------------------------------------------------------------------------

function priest_inner_fire_modifier:OnCreated( kv )

		self.armor_bonus = self:GetAbility():GetSpecialValueFor( "armor_inc")
		self.dmg_bonus = self:GetAbility():GetSpecialValueFor( "dmg_inc")
		self.mana_gain = self:GetAbility():GetSpecialValueFor( "mana_gain_amount_per_attack")

    if IsServer() then
        local particle_cast = "particles/orcale/nerif_ally_buff_generic_stack_numbers.vpcf"
        self.effect_cast = ParticleManager:CreateParticleForPlayer(particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())
    end
end
----------------------------------------------------------------------------


function priest_inner_fire_modifier:OnDestroy()
	if IsServer() then
        if self.effect_cast ~= nil then
            ParticleManager:DestroyParticle(self.effect_cast, true)
        end

        if self:GetCaster():FindAbilityByName("priest_inner_fire"):IsCooldownReady() == false then
            self:GetCaster():FindAbilityByName("priest_inner_fire"):StartCooldown(10)
        end

	end
end
----------------------------------------------------------------------------

function priest_inner_fire_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function priest_inner_fire_modifier:GetModifierPhysicalArmorBonus( params )
	return self.armor_bonus
end

function priest_inner_fire_modifier:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.dmg_bonus
end

function priest_inner_fire_modifier:OnTakeDamage( params )
    if IsServer() then
        --print("params.attacker.name ",params.attacker:GetUnitName())
        if params.attacker:GetUnitName() == self:GetParent():GetUnitName() then
            if params.inflictor then
                if params.inflictor:GetAbilityIndex() == 0 then
                    self:GetCaster():GiveMana(self.mana_gain)
                end
            end
        end
    end
end