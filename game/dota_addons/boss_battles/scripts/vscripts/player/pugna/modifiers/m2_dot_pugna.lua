m2_dot_pugna = class({})

function m2_dot_pugna:IsHidden()
	return false
end

function m2_dot_pugna:IsDebuff()
	return true
end

function m2_dot_pugna:IsPurgable()
	return false
end

function m2_dot_pugna:GetStatusEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end
---------------------------------------------------------------------------

function m2_dot_pugna:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.dmg = self:GetAbility():GetSpecialValueFor( "dot_dmg" )
        self.thinker_tick_rate = self:GetAbility():GetSpecialValueFor( "thinker_tick_rate" )
        self.stopDamageLoop = false

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function m2_dot_pugna:StartApplyDamageLoop()

    Timers:CreateTimer(function()
	    if self.stopDamageLoop == true then
		    return false
        end

        self.dmgTable = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.dmg,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(),
        }

        ApplyDamage(self.dmgTable)

		return self.thinker_tick_rate
	end)
end
--------------------------------------------------------------------------------

function m2_dot_pugna:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true
	end
end
---------------------------------------------------------------------------