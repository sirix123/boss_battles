Filters = Filters or class({})

function Filters:Activate(GameMode, this)
    function GameMode:ExecuteOrderFilter(filter_table)
        local order_type = filter_table["order_type"]

        local caster = EntIndexToHScript(filter_table.units["0"])

        if caster.spell_interupt == true then
            if order_type ~= DOTA_UNIT_ORDER_STOP and order_type ~= DOTA_UNIT_ORDER_HOLD_POSITION then
                if caster:GetCurrentActiveAbility() ~= nil then -- if we are currently casting something
                    if filter_table.entindex_ability ~= nil then -- and we are trying to cast an ability
                        if EntIndexToHScript(filter_table.entindex_ability) then
                            if  ( EntIndexToHScript(filter_table.entindex_ability):GetAbilityIndex() ~= 0 ) and -- if the new ability isn't a basic attack m0
                                ( EntIndexToHScript(filter_table.entindex_ability):GetAbilityIndex() ~= caster:GetCurrentActiveAbility():GetAbilityIndex() ) -- and its not the ability we are currently casting
                                then

                                --print("interrupt")

                                caster:Interrupt()
                            end
                        end
                    end
                end
                --print("casting... ",EntIndexToHScript(filter_table.entindex_ability):GetAbilityName())
            end
        end

        if caster:IsAlive() == false or caster:IsStunned() == true then
            return false
        end

        if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
            local ability = EntIndexToHScript(filter_table.entindex_ability)
            local caster = EntIndexToHScript(filter_table.units["0"])
            local point = Vector(
                filter_table.position_x,
                filter_table.position_y,
                filter_table.position_z
           )
            local current_range = (point - caster:GetAbsOrigin()):Length2D()
            local direction = (point - caster:GetAbsOrigin()):Normalized()
            local max_range = ability:GetCastRange(Vector(0,0,0), nil)

            if ability:GetBehavior() ~= DOTA_ABILITY_BEHAVIOR_IMMEDIATE then
                caster:FaceTowards(direction)
                caster:SetForwardVector(direction)
            end

            if current_range > max_range then
                local new_point = caster:GetAbsOrigin() + direction * (max_range - 10)

                filter_table.position_x = new_point.x
                filter_table.position_y = new_point.y
            end

            --print("returning true.....")
            --print("-------------------------")

            return true
        end

        --
        if order_type == DOTA_UNIT_ORDER_CAST_TARGET then
            local ability = EntIndexToHScript(filter_table.entindex_ability)
            --local caster = EntIndexToHScript(filter_table.units["0"])
            local target = EntIndexToHScript(filter_table.entindex_target)
            local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
            local max_range = ability:GetCastRange(Vector(0,0,0), nil)
            local current_range = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

            if ability:GetBehavior() ~= DOTA_ABILITY_BEHAVIOR_IMMEDIATE then
                caster:FaceTowards(direction)
                caster:SetForwardVector(direction)
            end

            if current_range > max_range then
                return false
            end

            return true
        end

        --
        if order_type == DOTA_UNIT_ORDER_STOP or order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
            local caster = EntIndexToHScript(filter_table.units["0"])
            local ability = caster:GetCurrentActiveAbility()
            if ability then
                caster:Interrupt()
                return false
            end
        end

        --
        if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION then
            caster:Interrupt()
            return false
        end

        return true
    end
end