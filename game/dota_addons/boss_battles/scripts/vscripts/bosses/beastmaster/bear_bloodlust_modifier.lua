
bear_bloodlust_modifier = class({})

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_e.vpcf"
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:GetStatusEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_e.vpcf"
end
-----------------------------------------------------------------------------

function bear_bloodlust_modifier:OnCreated( kv )

	--print("unit bloodlust on ", self:GetParent():GetUnitName())
	--print("stacks ", self:GetStackCount())
	--print("------------------------------")
	self.bloodlust_speed = kv.ms_bonus
	self.bloodlust_as_speed = kv.as_bonus
	self.bloodlust_damage_bonus = kv.damage_bonus

	--print("self:GetStackCount() ",self:GetStackCount())
	--print("self.bloodlust_speed ",self.bloodlust_speed)
	--print("self.bloodlust_as_speed ",self.bloodlust_as_speed)

	self.effect = ParticleManager:CreateParticle( "particles/clock/beast_abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.effect, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.effect, 1, Vector(1, self:GetStackCount(), 0) )
	ParticleManager:SetParticleControl( self.effect, 3, self:GetParent():GetAbsOrigin() )

end

function bear_bloodlust_modifier:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect, true)
    end
end

function bear_bloodlust_modifier:OnStackCountChanged( param )
    if IsServer() then

        if self.effect ~= nil then
            ParticleManager:DestroyParticle(self.effect, true)
        end

        if param ~= nil then
            param = self:GetStackCount() + 1
        end

		if param ~= 9 then
			--print("prevstackcount ",param)
			--print("self:GetStackCount() ",self:GetStackCount())
			--print("self.bloodlust_speed ",self.bloodlust_speed)
			--print("self.bloodlust_as_speed ",self.bloodlust_as_speed)
			--print("total as ",self:GetParent():GetAttackSpeed())
			--print("total ms ",self:GetParent():GetMoveSpeedModifier(200,true))
			--print("total base dmg ",self:GetParent():GetBaseDamageMax())
			--print("--------------------------------------")

			self.effect = ParticleManager:CreateParticle( "particles/beastmaster/beast_abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( self.effect, 0, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl( self.effect, 1, Vector(1, param - 1, 0) )
			ParticleManager:SetParticleControl( self.effect, 3, self:GetParent():GetAbsOrigin() )
		end

        if self:GetStackCount() == 0 then
            self:Destroy()
        end

	end
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function bear_bloodlust_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	if ( self.bloodlust_speed * self:GetStackCount() ) ~= nil then
		return self.bloodlust_speed * self:GetStackCount()
	end
end

--------------------------------------------------------------------------------

function bear_bloodlust_modifier:GetModifierAttackSpeedBonus_Constant( params )
	if ( self.bloodlust_as_speed * self:GetStackCount() ) ~= nil then
		return self.bloodlust_as_speed * self:GetStackCount()
	end
end

function bear_bloodlust_modifier:GetModifierBaseDamageOutgoing_Percentage( params )
	if ( self.bloodlust_damage_bonus * self:GetStackCount() ) ~= nil then
		return self.bloodlust_damage_bonus * self:GetStackCount()
	end
end

