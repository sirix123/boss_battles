e_qop_shield_modifier_enemy = class({})

function e_qop_shield_modifier_enemy:RemoveOnDeath()
    return true
end

function e_qop_shield_modifier_enemy:IsHidden()
	return false
end

function e_qop_shield_modifier_enemy:IsDebuff()
	return true
end

function e_qop_shield_modifier_enemy:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function e_qop_shield_modifier_enemy:GetEffectName()
	return "particles/items2_fx/orchid.vpcf"
end

function e_qop_shield_modifier_enemy:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
-----------------------------------------------------------------------------


function e_qop_shield_modifier_enemy:OnCreated( kv )
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()

        self.damage_factor = self:GetAbility():GetSpecialValueFor( "dmg_multiplier" )

        local modifier = "m2_qop_stacks"
        local stacks = 0
        if self.caster:HasModifier(modifier) then
            stacks = self.caster:GetModifierStackCount(modifier, self.caster)
            self.caster:RemoveModifierByName(modifier)
        end

        if stacks == 2 then
            self.damage_factor = self.damage_factor / 0.75
        elseif stacks == 3 then
            self.damage_factor = self.damage_factor / 0.5
        end

        self.damage_taken_during_debuff = 0
        

        --self.particle_index = ParticleManager:CreateParticle("particles/qop/qop_bloodseeker_bloodrage_ground_eztzhok.vpcf", PATTACH_ROOTBONE_FOLLOW, self.parent)

    end
end


function e_qop_shield_modifier_enemy:OnDestroy()
	if IsServer() then
        --ParticleManager:DestroyParticle(self.particle_index,false)

        if self.damage_taken_during_debuff > 0 then

			-- Calculate and deal damage
			local damage = self.damage_taken_during_debuff * self.damage_factor --* 0.01

			ApplyDamage({
                attacker = self.caster,
                victim = self.parent,
                ability = self:GetAbility(),
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL
            })

			-- Fire damage particle
			local orchid_end_pfx = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
			ParticleManager:SetParticleControl(orchid_end_pfx, 0, self.parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(orchid_end_pfx, 1, Vector(100, 0, 0))
			ParticleManager:ReleaseParticleIndex(orchid_end_pfx)
		end

		self.damage_taken_during_debuff = 0

	end
end
----------------------------------------------------------------------------

function e_qop_shield_modifier_enemy:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function e_qop_shield_modifier_enemy:OnTakeDamage(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.unit

		-- If this unit is the one suffering damage, store it
		if owner == target then
			self.damage_taken_during_debuff = self.damage_taken_during_debuff + keys.damage
		end
	end
end
----------------------------------------------------------------------------