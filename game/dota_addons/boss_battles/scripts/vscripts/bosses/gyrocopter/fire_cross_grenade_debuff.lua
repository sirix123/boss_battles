fire_cross_grenade_debuff = class({})

function fire_cross_grenade_debuff:IsHidden()
	return false
end

function fire_cross_grenade_debuff:IsDebuff()
	return false
end

function fire_cross_grenade_debuff:IsPurgable()
	return false
end

function fire_cross_grenade_debuff:GetEffectName()
	return "particles/ranger/debuff_ranger_huskar_burning_spear_debuff.vpcf"
end

function fire_cross_grenade_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function fire_cross_grenade_debuff:GetTexture()
	return "huskar_inner_fire"
end

---------------------------------------------------------------------------

function fire_cross_grenade_debuff:OnCreated( kv )
    if IsServer() then

		self.max_shield = 300
		self.shield_remaining = self.max_shield

		local particle = "particles/econ/events/ti8/mjollnir_shield_ti8.vpcf"
		self.particle_index = ParticleManager:CreateParticle(particle, PATTACH_ROOTBONE_FOLLOW, self:GetParent())

	end
end
---------------------------------------------------------------------------

function fire_cross_grenade_debuff:OnDestroy( kv )
    if IsServer() then
		ParticleManager:DestroyParticle(self.particle_index,true)
	end
end
---------------------------------------------------------------------------

-- Effect
function fire_cross_grenade_debuff:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then

        self.shield_amount = self.shield_remaining

        self.shield_remaining = self.shield_remaining - kv.damage

        --print("self.shield_remaining ",self.shield_remaining)

        if self.shield_remaining <= 0 then
            self.shield_remaining = 0
        end

        -- block all damage if we ahve the shield for it
        if kv.damage <= self.shield_amount then
            return kv.damage

        -- reduce what we can and deal dmg to player
        else
            self:Destroy()
            return self.shield_amount
        end

    end
end

--------------------------------------------------------------------------------
function fire_cross_grenade_debuff:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end