
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
	--self.bloodlust_status_res_per_stack = 2.5

	if IsServer() then
		--self.bloodlust_status_res_per_stack = 2.5
	end

	--print("self:GetStackCount() ",self:GetStackCount())
	--print("self.bloodlust_speed ",self.bloodlust_speed)
	--print("self.bloodlust_as_speed ",self.bloodlust_as_speed)
	--[[if self.effect ~= nil then
		ParticleManager:DestroyParticle(self.effect, true)
	end

	local stacks = self:GetStackCount()
	self.effect = ParticleManager:CreateParticle( "particles/beastmaster/beast_abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	if stacks >= 10 and stacks < 20 then
		digitX = 1
	elseif stacks >= 20 then
		digitX = 2
	else 
		digitX = 0
	end

	local digitY = stacks % 10
	--print("digitX: ",digitX,"digitY: ",digitY)
	ParticleManager:SetParticleControl(self.effect, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.effect, 1, Vector( digitX, digitY, 0 ))]]

end

function bear_bloodlust_modifier:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect, true)
    end
end

function bear_bloodlust_modifier:OnStackCountChanged( param )
    if IsServer() then

        if self.effect ~= nil and param < 20 then
            ParticleManager:DestroyParticle(self.effect, true)
        end

		if param < 10 then
			self.bloodlust_status_res_per_stack = 2.5
		elseif param > 10 then
			self.bloodlust_status_res_per_stack = 10
		end

		if param < 20 and param ~= nil then
			param = self:GetStackCount() + 1

			local stacks = self:GetStackCount()
			self.effect = ParticleManager:CreateParticle( "particles/beastmaster/beast_abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
			if stacks >= 10 and stacks < 20 then
				digitX = 1
			elseif stacks >= 20 then
				digitX = 2
			else 
				digitX = 0
			end
		
			local digitY = stacks % 10
			--print("digitX: ",digitX,"digitY: ",digitY)
			ParticleManager:SetParticleControl(self.effect, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.effect, 1, Vector( digitX, digitY, 0 ))
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
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
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

function bear_bloodlust_modifier:GetModifierModelScale()
	if self:GetStackCount() ~= nil then
		return 2.8 * self:GetStackCount()
	end
end

function bear_bloodlust_modifier:GetModifierStatusResistance()
	if ( self.bloodlust_status_res_per_stack * self:GetStackCount() ) ~= nil then
		print("self.bloodlust_status_res_per_stack * self:GetStackCount() ",self.bloodlust_status_res_per_stack * self:GetStackCount())
		return self.bloodlust_status_res_per_stack * self:GetStackCount()
	end
end
-----------------------------------------------------------------------------

