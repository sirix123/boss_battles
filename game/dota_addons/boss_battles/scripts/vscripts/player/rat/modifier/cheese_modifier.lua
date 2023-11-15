cheese_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function cheese_modifier:IsHidden()
	return false
end

function cheese_modifier:IsDebuff()
	return false
end

function cheese_modifier:IsStunDebuff()
	return false
end

function cheese_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function cheese_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- play particle eeffect
        local particle_cast = "particles/econ/events/ti8/mekanism_ti8.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        -- reference from kv
        self.heal_amount = self:GetAbility():GetSpecialValueFor( "heal")

        if self:GetStackCount() < self:GetAbility():GetSpecialValueFor( "max_stacks" ) then
            self:IncrementStackCount()
        end

        self:GetCaster():Heal(self.heal_amount * self:GetStackCount(), self:GetCaster())

        self:StartIntervalThink(1)

    end
end
----------------------------------------------------------------------------

function cheese_modifier:OnIntervalThink()
    if not IsServer() then return end

    -- heal
    self:GetCaster():Heal(self.heal_amount * self:GetStackCount(), self:GetCaster())

end

----------------------------------------------------------------------------
function cheese_modifier:OnRefresh( kv )
	if IsServer() then
        self:OnCreated()
    end
end
----------------------------------------------------------------------------

function cheese_modifier:OnDestroy()
    if IsServer() then

        if self:GetStackCount() > 1 then
            local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "cheese_modifier", { duration = self:GetAbility():GetSpecialValueFor( "duration" ) } )
            if modifier then
                modifier:SetStackCount( self:GetStackCount() - 1 )
            end
        end

    end
end
----------------------------------------------------------------------------