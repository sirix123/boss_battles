
water_gun_dmg_buff = class({})

-----------------------------------------------------------------------------

function water_gun_dmg_buff:IsHidden()
	return false
end

function water_gun_dmg_buff:GetTexture()
	return "morphling_adaptive_strike_agi"
end

-----------------------------------------------------------------------------

function water_gun_dmg_buff:OnCreated(  )
    if IsServer() then
        self.max_dmg_bonus = 20
        self.dmg_bonus = 0

        if self:GetStackCount() == 0 then
            self:IncrementStackCount()
        end
    end

    if self:GetStackCount() == 1 then
        self.dmg_bonus = 5
    elseif self:GetStackCount() == 2 then
        self.dmg_bonus = 8
    elseif self:GetStackCount() == 3 then
        self.dmg_bonus = 10
    end

end

function water_gun_dmg_buff:OnRefresh(  )
    if IsServer() then
        if self:GetStackCount() < 3 then
            self:IncrementStackCount()
        end

        --print("self:GetStackCount() ",self:GetStackCount())

        if self:GetStackCount() == 1 then
            self.dmg_bonus = 5
        elseif self:GetStackCount() == 2 then
            self.dmg_bonus = 8
        elseif self:GetStackCount() == 3 then
            self.dmg_bonus = 10
        end

    end

    if self:GetStackCount() == 1 then
        self.dmg_bonus = 5
    elseif self:GetStackCount() == 2 then
        self.dmg_bonus = 8
    elseif self:GetStackCount() == 3 then
        self.dmg_bonus = 10
    end

end

--[[
function water_gun_dmg_buff:OnStackCountChanged( param )
    if IsServer() then

        if param ~= nil then
            param = self:GetStackCount() + 1
        end

        if self:GetStackCount() == 0 then
            self:Destroy()
        end
	end
end]]

function water_gun_dmg_buff:OnRemoved()
    if IsServer() then
        if self:GetStackCount() > 1 then
            local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), nil, "water_gun_dmg_buff", { duration = 10 } )
            modifier:SetStackCount( self:GetStackCount() - 1 )
        end
    end
end

function water_gun_dmg_buff:OnDestroy()
    if IsServer() then
    end
end

-----------------------------------------------------------------------------

function water_gun_dmg_buff:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function water_gun_dmg_buff:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.dmg_bonus
end

--------------------------------------------------------------------------------

