
r_outgoing_dmg_buff = class({})

-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:IsHidden()
	return false
end

function r_outgoing_dmg_buff:RemoveOnDeath()
    return false
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:GetEffectName()
	return "particles/nocens/nocens_vengeful_shard_buff_hands.vpcf"
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:GetStatusEffectName()
	return "particles/nocens/nocens_vengeful_shard_buff_hands.vpcf"
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:OnCreated( kv )
	--if IsServer() then
	    self.outgoing_plus = self:GetAbility():GetSpecialValueFor( "outgoing_plus" )
        if IsServer() then
            self.caster = self:GetCaster()
            --[[self.caster = self:GetCaster()
            self.caster:FindAbilityByName("q_armor_aura"):SetActivated(false)
            self.caster:FindAbilityByName("e_regen_aura"):SetActivated(false)
            self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(false)]]
        end
    --end
end
-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:OnDestroy()
    if IsServer() then
        --[[self.caster:FindAbilityByName("q_armor_aura"):SetActivated(true)
        self.caster:FindAbilityByName("e_regen_aura"):SetActivated(true)
        self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(true)]]
        self.caster:FindAbilityByName("e_regen_aura"):SetActivated(true)
		self.caster:FindAbilityByName("q_armor_aura"):SetActivated(true)
    end
end
-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function r_outgoing_dmg_buff:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.outgoing_plus
end

--------------------------------------------------------------------------------
