fire_ele_melt_debuff = class({})

function fire_ele_melt_debuff:IsHidden()
	return false
end

function fire_ele_melt_debuff:IsDebuff()
	return true
end

function fire_ele_melt_debuff:OnCreated( kv )
    --if IsServer() then
        --self:IncrementStackCount()
        self.bonus_armor = 1
        --print("self:GetStackCount() ",self:GetStackCount())
    --end
end

function fire_ele_melt_debuff:OnRefresh(table)
    --if IsServer() then
        --self:IncrementStackCount()
        print("self:GetStackCount() ",self:GetStackCount())
    --end
end

--------------------------------------------------------------------------------

function fire_ele_melt_debuff:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

--------------------------------------------------------------------------------


function fire_ele_melt_debuff:GetModifierPhysicalArmorBonus( params )
	return -self.bonus_armor * self:GetStackCount()
end