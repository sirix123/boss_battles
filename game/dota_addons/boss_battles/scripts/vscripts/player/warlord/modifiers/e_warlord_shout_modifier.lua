e_warlord_shout_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function e_warlord_shout_modifier:IsHidden()
	return false
end

function e_warlord_shout_modifier:IsDebuff()
	return false
end

function e_warlord_shout_modifier:IsPurgable()
	return false
end

function e_warlord_shout_modifier:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function e_warlord_shout_modifier:OnCreated( kv )
    if IsServer() then

        self.parent = self:GetParent()
        self.parent_origin = self.parent:GetAbsOrigin()

        self.max_shield = self:GetAbility():GetSpecialValueFor( "bubble_amount" )
        self.shield_remaining = self.max_shield

        local particle_shield_size = self.parent:GetModelRadius() * 1.2

        -- bubble effect
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		local common_vector = Vector(particle_shield_size,0,particle_shield_size)
		ParticleManager:SetParticleControl(self.particle, 1, common_vector)
		ParticleManager:SetParticleControl(self.particle, 2, common_vector)
		ParticleManager:SetParticleControl(self.particle, 4, common_vector)
		ParticleManager:SetParticleControl(self.particle, 5, Vector(particle_shield_size,0,0))

		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent_origin, true)
		self:AddParticle(self.particle, false, false, -1, false, false)

    end
end

function e_warlord_shout_modifier:OnRefresh( kv )
    if IsServer() then

    end
end

function e_warlord_shout_modifier:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle, true)

        -- blow up particle / pop
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)

        -- sound
        self:GetParent():EmitSound("Hero_Abaddon.AphoticShield.Destroy")
    end
end

--------------------------------------------------------------------------------
-- Effect
function e_warlord_shout_modifier:GetModifierTotal_ConstantBlock(kv)
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
function e_warlord_shout_modifier:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end