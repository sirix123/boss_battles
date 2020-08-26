m2_combo_hit_3_bleed = class({})

-----------------------------------------------------------------------------
-- Classifications
function m2_combo_hit_3_bleed:IsHidden()
	return false
end

function m2_combo_hit_3_bleed:IsDebuff()
	return true
end

function m2_combo_hit_3_bleed:IsStunDebuff()
	return false
end

function m2_combo_hit_3_bleed:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function m2_combo_hit_3_bleed:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"--"particles/items4_fx/nullifier_mute_debuff.vpcf"--"particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function m2_combo_hit_3_bleed:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function m2_combo_hit_3_bleed:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- reference from kv
        self.damage_type = self:GetAbility():GetAbilityDamageType()
        self.base_dmg = self:GetAbility():GetSpecialValueFor("dmg_dot_base")
        self.bonus_bleed_percent = self:GetAbility():GetSpecialValueFor("bonus_bleed_percent")

        -- tick with base dmg until we get charges
        self.dmg = self.base_dmg

        -- damge loop start
        self.stopDamageLoop = false

        -- dmg interval
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "damage_interval")

        -- sound
        --self:GetParent():EmitSound("Hero_Ancient_Apparition.ColdFeetCast")

        -- start damage timer
        self:StartApplyDamageLoop()

    end
end
----------------------------------------------------------------------------

function m2_combo_hit_3_bleed:StartApplyDamageLoop()
    if IsServer() then

        Timers:CreateTimer(self.damage_interval, function()
            if self.stopDamageLoop == true then
                return false
            end

            if self.parent:HasModifier("e_swallow_potion_modifier_debuff") then
                self.dmg = self.base_dmg + ( self.base_dmg * self.bonus_bleed_percent )
            end

            self.dmgTable = {
                victim = self.parent,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = self.damage_type,
            }

            ApplyDamage(self.dmgTable)

            return self.damage_interval
        end)

    end
end
----------------------------------------------------------------------------

function m2_combo_hit_3_bleed:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function m2_combo_hit_3_bleed:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true
    end
end
----------------------------------------------------------------------------