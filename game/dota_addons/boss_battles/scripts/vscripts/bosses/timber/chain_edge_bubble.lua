chain_edge_bubble = class({})

function chain_edge_bubble:RemoveOnDeath()
    return true
end

function chain_edge_bubble:IsHidden()
	return false
end

function chain_edge_bubble:IsDebuff()
	return false
end

function chain_edge_bubble:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

--[[function chain_edge_bubble:GetEffectName()
    return "particles/econ/items/ember_spirit/ember_ti9/ember_ti9_flameguard.vpcf"
end

function chain_edge_bubble:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end]]
-----------------------------------------------------------------------------

function chain_edge_bubble:OnCreated( kv )
	if IsServer() then

		self.max_shield = 2000
        self.shield_remaining = self.max_shield

		self.caster = self:GetCaster()
		self.parent = self:GetParent()

        self.particle_bubble = ParticleManager:CreateParticle("particles/timber/timber_abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        local common_vector = Vector(250,0,250)
        ParticleManager:SetParticleControl(self.particle_bubble , 1, common_vector)
        ParticleManager:SetParticleControl(self.particle_bubble , 5, Vector(250,0,0))
        ParticleManager:SetParticleControlEnt(self.particle_bubble , 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)

    end
end

----------------------------------------------------------------------------

function chain_edge_bubble:OnDestroy()
	if IsServer() then
        ParticleManager:DestroyParticle(self.particle_bubble,true)
	end
end
----------------------------------------------------------------------------

-- Effect
function chain_edge_bubble:GetModifierTotal_ConstantBlock(kv)
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
function chain_edge_bubble:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end