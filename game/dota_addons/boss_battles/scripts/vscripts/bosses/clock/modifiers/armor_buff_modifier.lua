
armor_buff_modifier = class({})

-----------------------------------------------------------------------------

function armor_buff_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function armor_buff_modifier:OnCreated(  )
    if IsServer() then

        -- armor buff
        self.bonus_armor = 10
        --self:SetStackCount(3)

        print("self:GetStackCount() ",self:GetStackCount())

        self.effect = ParticleManager:CreateParticle( "particles/clock/clock_abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( self.effect, 0, self:GetParent():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.effect, 1, Vector(1, self:GetStackCount(), 0) )
        ParticleManager:SetParticleControl( self.effect, 3, self:GetParent():GetAbsOrigin() )

    end
end

function armor_buff_modifier:OnStackCountChanged( param )
    if IsServer() then

        if self.effect ~= nil then
            ParticleManager:DestroyParticle(self.effect, true)
        end

        if param ~= nil then
            param = self:GetStackCount() + 1
        end

        --print("para ",param)

        self.effect = ParticleManager:CreateParticle( "particles/clock/clock_abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( self.effect, 0, self:GetParent():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.effect, 1, Vector(1, param - 1, 0) )
        ParticleManager:SetParticleControl( self.effect, 3, self:GetParent():GetAbsOrigin() )

        if self:GetStackCount() == 0 then
            self:Destroy()
        end

	end
end

function armor_buff_modifier:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect, true)
    end
end

-----------------------------------------------------------------------------

function armor_buff_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

-----------------------------------------------------------------------------

function armor_buff_modifier:GetModifierPhysicalArmorBonus( params )
	return self.bonus_armor * self:GetStackCount()
end

--------------------------------------------------------------------------------

