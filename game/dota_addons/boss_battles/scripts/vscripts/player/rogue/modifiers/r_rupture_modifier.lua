r_rupture_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function r_rupture_modifier:IsHidden()
	return false
end

function r_rupture_modifier:IsDebuff()
	return true
end

function r_rupture_modifier:IsStunDebuff()
	return false
end

function r_rupture_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function r_rupture_modifier:GetEffectName()
	return "particles/units/heroes/hero_grimstroke/grimstroke_phantom_marker.vpcf"--"particles/items4_fx/nullifier_mute_debuff.vpcf"--"particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function r_rupture_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function r_rupture_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function r_rupture_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- reference from kv
        self.damage_type = self:GetAbility():GetAbilityDamageType()
        self.base_dmg = self:GetAbility():GetSpecialValueFor("dmg_dot_base")
        self.bonus_bleed_percent = self:GetAbility():GetSpecialValueFor("bonus_bleed_percent") / 100 -- make the tooltip look better (display %)

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

function r_rupture_modifier:StartApplyDamageLoop()
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
                ability = self:GetAbility(),
            }

            ApplyDamage(self.dmgTable)

            return self.damage_interval
        end)

    end
end
----------------------------------------------------------------------------

function r_rupture_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function r_rupture_modifier:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true
    end
end
----------------------------------------------------------------------------