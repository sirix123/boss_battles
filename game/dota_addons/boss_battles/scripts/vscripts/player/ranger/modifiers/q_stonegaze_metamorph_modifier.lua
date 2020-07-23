q_stonegaze_metamorph_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function q_stonegaze_metamorph_modifier:IsHidden()
	return false
end

function q_stonegaze_metamorph_modifier:IsDebuff()
	return false
end

function q_stonegaze_metamorph_modifier:IsStunDebuff()
	return false
end

function q_stonegaze_metamorph_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function q_stonegaze_metamorph_modifier:GetEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"--"particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function q_stonegaze_metamorph_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function q_stonegaze_metamorph_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.interval = 0.03
        self.stopLoop = false

        self.manaRegen = self:GetAbility():GetSpecialValueFor("mana_regen")

        self.parent:SetMoveCapability(0)

        -- start damage timer
        --self:StartLoop()

        local particle = "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(self.effect_cast, 1, self.parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(self.effect_cast)

        -- sound
        EmitSoundOn("Hero_Medusa.StoneGaze.Cast", self.caster)


    end
end
----------------------------------------------------------------------------

function q_stonegaze_metamorph_modifier:StartLoop()
    if IsServer() then

        Timers:CreateTimer(self.interval, function()
            if self.stopLoop == true then
                return false
            end

            return self.self.interval
        end)

    end
end
----------------------------------------------------------------------------

function q_stonegaze_metamorph_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function q_stonegaze_metamorph_modifier:OnDestroy()
    if IsServer() then
        -- stop timer
        StopSoundOn("Hero_Medusa.StoneGaze.Cast", self.caster)
        ParticleManager:DestroyParticle(self.effect_cast, true)
        self.stopLoop = true
        self.parent:SetMoveCapability(1)
    end
end
----------------------------------------------------------------------------

function q_stonegaze_metamorph_modifier:GetModifierConstantManaRegen()
    return self.manaRegen
end

function q_stonegaze_metamorph_modifier:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end