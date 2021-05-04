e_qop_shield_modifier = class({})

function e_qop_shield_modifier:RemoveOnDeath()
    return true
end

function e_qop_shield_modifier:IsHidden()
	return false
end

function e_qop_shield_modifier:IsDebuff()
	return false
end

function e_qop_shield_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function e_qop_shield_modifier:OnCreated( kv )
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()

		self.max_shield = self:GetAbility():GetSpecialValueFor( "base_bubble" )

        local modifier = "m2_qop_stacks"
        local stacks = 0
        if self.caster:HasModifier(modifier) then
            stacks = self.caster:GetModifierStackCount(modifier, self.caster)
            self.caster:RemoveModifierByName(modifier)
        end

        if stacks == 2 then
            self.max_shield = self.max_shield * 4
        elseif stacks == 3 then
            self.max_shield = self.max_shield * 8
        end

        self.shield_remaining = self.max_shield

        self.particle_index = ParticleManager:CreateParticle("particles/qop/qop_bloodseeker_bloodrage_ground_eztzhok.vpcf", PATTACH_ROOTBONE_FOLLOW, self.parent)

    end
end


----------------------------------------------------------------------------

function e_qop_shield_modifier:OnDestroy()
	if IsServer() then
        ParticleManager:DestroyParticle(self.particle_index,false)
	end
end
----------------------------------------------------------------------------

-- Effect
function e_qop_shield_modifier:GetModifierTotal_ConstantBlock(kv)
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
function e_qop_shield_modifier:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end