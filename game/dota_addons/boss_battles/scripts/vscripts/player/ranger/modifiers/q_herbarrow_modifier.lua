q_herbarrow_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function q_herbarrow_modifier:IsHidden()
	return false
end

function q_herbarrow_modifier:IsDebuff()
	return false
end

function q_herbarrow_modifier:IsStunDebuff()
	return false
end

function q_herbarrow_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function q_herbarrow_modifier:GetEffectName()
	return "particles/items4_fx/nullifier_mute_debuff.vpcf"
end

function q_herbarrow_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function q_herbarrow_modifier:OnCreated( kv )
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
        --self:StartApplyDamageLoop()

    end
end
----------------------------------------------------------------------------

function q_herbarrow_modifier:StartApplyDamageLoop()
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

function q_herbarrow_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function q_herbarrow_modifier:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true
    end
end
----------------------------------------------------------------------------