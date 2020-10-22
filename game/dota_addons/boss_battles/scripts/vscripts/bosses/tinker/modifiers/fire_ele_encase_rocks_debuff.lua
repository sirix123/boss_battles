fire_ele_encase_rocks_debuff = class({})

function fire_ele_encase_rocks_debuff:IsHidden()
	return false
end

function fire_ele_encase_rocks_debuff:IsDebuff()
	return true
end

function fire_ele_encase_rocks_debuff:OnCreated( kv )
    --if IsServer() then
        --self:IncrementStackCount()
        --print("self:GetStackCount() ",self:GetStackCount())
    --end
end

function fire_ele_encase_rocks_debuff:OnRefresh(table)
    --if IsServer() then
        --self:IncrementStackCount()
        --print("self:GetStackCount() ",self:GetStackCount())
    --end
end

--------------------------------------------------------------------------------