rage_stacks_warlord = class({})

function rage_stacks_warlord:IsHidden() 
    return false
end

function rage_stacks_warlord:IsDebuff() 
    return false
end

function rage_stacks_warlord:IsStunDebuff() 
    return false
end

function rage_stacks_warlord:IsPurgable() 
    return true
end

function rage_stacks_warlord:GetTexture()
	return "juggernaut_blade_dance"
end
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function rage_stacks_warlord:OnCreated(kv)
	if IsServer() then

		self:SetStackCount(1)
	end
end
---------------------------------------------------------------------------------------------------

function rage_stacks_warlord:OnRefresh(kv)
	local max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	if IsServer() then
		if self:GetStackCount() < max_stacks then
			self:IncrementStackCount()

			if self:GetStackCount() == max_stacks then
                -- should we have an effect?
			end
		end
	end
end
---------------------------------------------------------------------------------------------------

function rage_stacks_warlord:OnDestroy(kv)
	if IsServer() then

	end
end
---------------------------------------------------------------------------------------------------

