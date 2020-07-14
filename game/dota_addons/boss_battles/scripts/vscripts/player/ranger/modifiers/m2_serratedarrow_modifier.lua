m2_serratedarrow_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function m2_serratedarrow_modifier:IsHidden()
	return false
end

function m2_serratedarrow_modifier:IsDebuff()
	return true
end

function m2_serratedarrow_modifier:IsStunDebuff()
	return false
end

function m2_serratedarrow_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function m2_serratedarrow_modifier:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"--"particles/items4_fx/nullifier_mute_debuff.vpcf"--"particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function m2_serratedarrow_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function m2_serratedarrow_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- reference from kv
        self.damage_type = self:GetAbility():GetAbilityDamageType()

        -- damge loop start
        self.stopDamageLoop = false

        -- dmg interval
        self.damage_interval = 1

        -- sound
        --self:GetParent():EmitSound("Hero_Ancient_Apparition.ColdFeetCast")

        -- start damage timer
        self:StartApplyDamageLoop()

    end
end
----------------------------------------------------------------------------

function m2_serratedarrow_modifier:StartApplyDamageLoop()
    if IsServer() then

        Timers:CreateTimer(self.damage_interval, function()
            if self.stopDamageLoop == true then
                return false
            end

            -- dmg calcuation
            self.dmg = 10

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

function m2_serratedarrow_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function m2_serratedarrow_modifier:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true
    end
end
----------------------------------------------------------------------------