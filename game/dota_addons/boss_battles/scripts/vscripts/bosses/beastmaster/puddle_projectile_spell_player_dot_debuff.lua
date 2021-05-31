puddle_projectile_spell_player_dot_debuff = class({})

function puddle_projectile_spell_player_dot_debuff:IsHidden()
	return false
end

function puddle_projectile_spell_player_dot_debuff:IsDebuff()
	return true
end

function puddle_projectile_spell_player_dot_debuff:IsPurgable()
	return false
end

function puddle_projectile_spell_player_dot_debuff:GetEffectName()
	return "particles/beastmaster/beast_venomancer_gale_poison_debuff.vpcf"
end

function puddle_projectile_spell_player_dot_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function puddle_projectile_spell_player_dot_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function puddle_projectile_spell_player_dot_debuff:GetAbilityTextureName()
	return "venomancer_poison_sting"
end
---------------------------------------------------------------------------

function puddle_projectile_spell_player_dot_debuff:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.dmg = self:GetAbility():GetSpecialValueFor( "puddle_proj_dot_dmg" ) --30
        self.stopDamageLoop = false
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "puddle_proj_dot_interval" ) --1
        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function puddle_projectile_spell_player_dot_debuff:StartApplyDamageLoop()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local dmgTable = {
            victim = self.parent,
            attacker = self:GetCaster(),
            damage = self.dmg,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(),
        }

        ApplyDamage(dmgTable)

		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------


function puddle_projectile_spell_player_dot_debuff:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true

        if self.effect_cast ~= nil then
            ParticleManager:DestroyParticle(self.effect_cast,false)
        end
	end
end
---------------------------------------------------------------------------