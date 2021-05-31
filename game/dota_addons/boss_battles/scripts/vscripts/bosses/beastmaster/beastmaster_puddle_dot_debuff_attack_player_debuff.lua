beastmaster_puddle_dot_debuff_attack_player_debuff = class({})

function beastmaster_puddle_dot_debuff_attack_player_debuff:IsHidden()
	return false
end

function beastmaster_puddle_dot_debuff_attack_player_debuff:IsDebuff()
	return true
end

function beastmaster_puddle_dot_debuff_attack_player_debuff:IsPurgable()
	return false
end

function beastmaster_puddle_dot_debuff_attack_player_debuff:GetEffectName()
	return "particles/beastmaster/beast_venomancer_gale_poison_debuff.vpcf"
end

function beastmaster_puddle_dot_debuff_attack_player_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function beastmaster_puddle_dot_debuff_attack_player_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function beastmaster_puddle_dot_debuff_attack_player_debuff:GetAbilityTextureName()
	return "venomancer_poison_sting"
end
---------------------------------------------------------------------------

function beastmaster_puddle_dot_debuff_attack_player_debuff:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.dmg = kv.dmg_per_tick
        self.stopDamageLoop = false
        self.damage_interval = 1
        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function beastmaster_puddle_dot_debuff_attack_player_debuff:StartApplyDamageLoop()

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


function beastmaster_puddle_dot_debuff_attack_player_debuff:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true

        if self.effect_cast ~= nil then
            ParticleManager:DestroyParticle(self.effect_cast,false)
        end
	end
end
---------------------------------------------------------------------------