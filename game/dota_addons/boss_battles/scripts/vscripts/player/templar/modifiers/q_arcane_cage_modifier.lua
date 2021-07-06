q_arcane_cage_modifier = class({})

function q_arcane_cage_modifier:IsHidden()
	return false
end

function q_arcane_cage_modifier:IsDebuff()
	return false
end

function q_arcane_cage_modifier:IsPurgable()
	return false
end

function q_arcane_cage_modifier:OnCreated()
    if IsServer() then
        local particle = "particles/units/heroes/hero_wisp/wisp_tether_agh.vpcf"
        self.pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

        self:StartIntervalThink(0.03)

    end
end

function q_arcane_cage_modifier:OnIntervalThink()
    if IsServer() then
        if (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin() ):Length2D() > self:GetAbility():GetCastRange(Vector(0,0,0), nil) then

            if self:GetCaster():HasModifier("q_arcane_cage_modifier_templar") then
                self:GetCaster():RemoveModifierByName("q_arcane_cage_modifier_templar")
            end

            self:Destroy()
        end
    end
end

function q_arcane_cage_modifier:OnDestroy()
    if IsServer() then
        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx,false)
        end
    end
end

function q_arcane_cage_modifier:GetStatusEffectName()
	return "particles/templar/templar_status_effect_arc_warden_tempest.vpcf"
end

function q_arcane_cage_modifier:GetEffectName()
	return "particles/templar/templar_arc_warden_tempest_buff.vpcf"
end

function q_arcane_cage_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function q_arcane_cage_modifier:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function q_arcane_cage_modifier:GetModifierTotal_ConstantBlock( params )
    if IsServer() then

        local incoming_damage = params.damage
        local caster = self:GetCaster()

        incoming_damage = incoming_damage - ( incoming_damage * ( self:GetAbility():GetSpecialValueFor( "damage_sent_to_templar" ) / 100))

        local dmgTable = {
            victim = caster,
            attacker = params.attacker,
            damage =  incoming_damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(),
        }

        ApplyDamage(dmgTable)

        return incoming_damage - ( incoming_damage * ( ( 100 - self:GetAbility():GetSpecialValueFor( "damage_sent_to_templar" ) ) / 100))

    end
end

function q_arcane_cage_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
	return funcs
end

function q_arcane_cage_modifier:GetModifierTotalDamageOutgoing_Percentage( params )
	return self:GetAbility():GetSpecialValueFor( "outgoing_damage_bonus" )
end

