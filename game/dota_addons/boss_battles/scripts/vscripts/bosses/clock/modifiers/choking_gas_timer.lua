choking_gas_timer = class({})

-----------------------------------------------------------------------------
-- Classifications
function choking_gas_timer:IsHidden()
	return false
end

function choking_gas_timer:IsDebuff()
	return true
end

function choking_gas_timer:IsStunDebuff()
	return false
end

function choking_gas_timer:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function choking_gas_timer:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_counter_debuff.vpcf"
end

function choking_gas_timer:GetStatusEffectName()
	return
end

function choking_gas_timer:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
-----------------------------------------------------------------------------

function choking_gas_timer:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- damge loop start
        self.stopDamageLoop = false

        -- reference
        self.cloud_spawn_interval = self:GetAbility():GetSpecialValueFor( "cloud_spawn_interval")
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "dmg_interval" )

        -- sound

        -- start timer
        self:StartLoop()

    end
end
----------------------------------------------------------------------------

function choking_gas_timer:StartLoop()
    if IsServer() then

        Timers:CreateTimer(function()
            if self.stopDamageLoop == true then
                return false
            end

            -- create a particle and a thinker at the location every interval
            self.modifier = CreateModifierThinker(
                self.caster,
                self,
                "choking_gas_thinker",
                {
                    duration = self:GetAbility():GetSpecialValueFor( "duration_cloud" ),
                    target_x = self:GetParent():GetAbsOrigin().x,
                    target_y = self:GetParent():GetAbsOrigin().y,
                    target_z = self:GetParent():GetAbsOrigin().z,
                    radius = self.radius,
                    dmg = self.dmg,
                    damage_interval =self.damage_interval,
                    dmgType = self:GetAbility():GetAbilityDamageType()
                },
                self.caster:GetAbsOrigin(),
                self.caster:GetTeam(),
                false
            )

            return self.cloud_spawn_interval
        end)

    end
end
----------------------------------------------------------------------------

function choking_gas_timer:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function choking_gas_timer:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true
    end
end
----------------------------------------------------------------------------