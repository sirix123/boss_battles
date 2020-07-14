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
	return "particles/items2_fx/tranquil_boots_healing_core.vpcf"
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
        self.heal_amount = self:GetAbility():GetSpecialValueFor( "heal_amount")
        self.tick_rate = self:GetAbility():GetSpecialValueFor( "tick_rate")

        -- damge loop start
        self.stopHealLoop = false

        -- sound
        --local sound_cast = "Hero_Enchantress.NaturesAttendantsCast"
        --EmitSoundOn( sound_cast, self.parent )

        -- start damage timer
        self:StartApplyHealLoop()

    end
end
----------------------------------------------------------------------------

function q_herbarrow_modifier:StartApplyHealLoop()
    if IsServer() then

        Timers:CreateTimer(self.tick_rate, function()
            if self.stopHealLoop == true then
                return false
            end

            self.parent:Heal(self.heal_amount, self.caster)

            return self.tick_rate
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
        self.stopHealLoop = true
    end
end
----------------------------------------------------------------------------