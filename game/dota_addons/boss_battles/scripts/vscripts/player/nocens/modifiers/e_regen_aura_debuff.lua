
e_regen_aura_debuff = class({})

-----------------------------------------------------------------------------

function e_regen_aura_debuff:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function e_regen_aura_debuff:GetEffectName()
	return "particles/econ/items/warlock/warlock_ti9/warlock_ti9_shadow_word_debuff.vpcf"
end

-----------------------------------------------------------------------------

function e_regen_aura_debuff:GetStatusEffectName()
	return "particles/econ/items/warlock/warlock_ti9/warlock_ti9_shadow_word_debuff.vpcf"
end

-----------------------------------------------------------------------------

function e_regen_aura_debuff:OnCreated( kv )
	if IsServer() then
		local ability = self:GetCaster():FindAbilityByName("e_regen_aura")
	    self.regen_minus = ability:GetSpecialValueFor( "regen_minus" )
		self.damage_interval = 1
		self.stop_timer = false

		Timers:CreateTimer(self.damage_interval, function()
            if self.stop_timer == true then
                return false
            end

			--print("regen minus ",self.regen_minus)

            self.dmgTable = {
                victim = self:GetParent(),
                attacker = self:GetCaster(),
                damage = self.regen_minus,
                damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self:GetAbility(),
            }

            ApplyDamage(self.dmgTable)

            return self.damage_interval
        end)
    end
end

function e_regen_aura_debuff:OnDestroy()
	if IsServer() then
		self.stop_timer = true
	end
end

-----------------------------------------------------------------------------
--[[
function e_regen_aura_debuff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-----------------------------------------------------------------------------

function e_regen_aura_debuff:GetModifierConstantHealthRegen( params )
	return -self.regen_minus
end]]

--------------------------------------------------------------------------------
