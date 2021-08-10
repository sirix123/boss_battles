priest_holy_fire_modifier_dot = class({})

-----------------------------------------------------------------------------
-- Classifications
function priest_holy_fire_modifier_dot:IsHidden()
	return false
end

function priest_holy_fire_modifier_dot:IsDebuff()
	return true
end

function priest_holy_fire_modifier_dot:IsStunDebuff()
	return false
end

function priest_holy_fire_modifier_dot:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function priest_holy_fire_modifier_dot:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- reference from kv
        self.damage_type = DAMAGE_TYPE_PHYSICAL
        self.base_dmg = self:GetAbility():GetSpecialValueFor("dmg_dot")

        self.particle_fx = ParticleManager:CreateParticleForPlayer("particles/fire_mage/fire_magemeteor_hammer_spell_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControlEnt(self.particle_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

        -- damge loop start
        self.stopDamageLoop = false

        -- dmg interval
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "dmg_dot_interval")

        -- start damage timer
        self:StartApplyDamageLoop()

    end
end
----------------------------------------------------------------------------

function priest_holy_fire_modifier_dot:StartApplyDamageLoop()
    if IsServer() then

        Timers:CreateTimer(self.damage_interval, function()
            if self.stopDamageLoop == true then
                return false
            end

            self.dmgTable = {
                victim = self.parent,
                attacker = self.caster,
                damage = self.base_dmg,
                damage_type = self.damage_type,
                ability = self:GetAbility(),
            }

            ApplyDamage(self.dmgTable)

            return self.damage_interval
        end)

    end
end
----------------------------------------------------------------------------

function priest_holy_fire_modifier_dot:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function priest_holy_fire_modifier_dot:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true

        ParticleManager:DestroyParticle(self.particle_fx,true)
    end
end
----------------------------------------------------------------------------