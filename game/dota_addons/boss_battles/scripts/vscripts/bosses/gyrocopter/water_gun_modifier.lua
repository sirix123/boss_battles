
water_gun_modifier = class({})

-----------------------------------------------------------------------------

function water_gun_modifier:IsHidden()
	return true
end

function water_gun_modifier:GetTexture()
	return "morphling_adaptive_strike_agi"
end

-----------------------------------------------------------------------------

function water_gun_modifier:OnCreated(  )
    if IsServer() then

        print("water gun modifier")

        Timers:CreateTimer(self:GetAbility():GetSpecialValueFor("replen_time"), function()
            if IsValidEntity(self:GetCaster()) == false then
                print("water gun modifier ending 2")
                return false
            end

            for i = 0, 5 do
                local item = self:GetParent():GetItemInSlot(i)
                if item then
                    if item:GetName() == "item_water_gun" then
                        local current_charges = item:GetCurrentCharges()
                        -- charge logic

                        if current_charges < self:GetAbility():GetSpecialValueFor("max_charges") then
                            print("water gun modifier charges increaseing")
                            self:GetAbility():SetCurrentCharges( self:GetAbility():GetCurrentCharges() + 1 )
                        end
                    end
                end
            end

            return self:GetAbility():GetSpecialValueFor("replen_time")
        end)
    end
end

function water_gun_modifier:OnRefresh(  )
    if IsServer() then
    end
end

function water_gun_modifier:OnDestroy()
    if IsServer() then
    end
end

