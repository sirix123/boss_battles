e_immolate_metamorph_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function e_immolate_metamorph_modifier:IsHidden()
	return false
end

function e_immolate_metamorph_modifier:IsDebuff()
	return false
end

function e_immolate_metamorph_modifier:IsStunDebuff()
	return false
end

function e_immolate_metamorph_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function e_immolate_metamorph_modifier:GetEffectName()
    return "particles/ranger/immolate_medusa_daughters_mana_shield.vpcf"
end

function e_immolate_metamorph_modifier:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
----------------------------------------------------------------------------

function e_immolate_metamorph_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.interval = 0.03
        self.stopLoop = false

        self.healthDegen = self:GetAbility():GetSpecialValueFor("health_degen")

        -- start damage timer
        self:StartLoop()

        -- effect


    end
end
----------------------------------------------------------------------------

function e_immolate_metamorph_modifier:StartLoop()
    if IsServer() then

        Timers:CreateTimer(self.interval, function()
            if self.stopLoop == true then
                return false
            end

            if self.parent:HasModifier("r_metamorph_modifier") == false then
                self:Destroy()
            end

            return self.interval
        end)

    end
end
----------------------------------------------------------------------------

function e_immolate_metamorph_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function e_immolate_metamorph_modifier:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopLoop = true
    end
end
----------------------------------------------------------------------------

function e_immolate_metamorph_modifier:GetModifierConstantHealthRegen()
    return -5.5
end

function e_immolate_metamorph_modifier:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end