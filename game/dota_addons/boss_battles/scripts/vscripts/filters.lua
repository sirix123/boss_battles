Filters = Filters or class({})

function Filters:Activate(GameMode, this)
    function GameMode:ExecuteOrderFilter(filter_table)
        local order_type = filter_table["order_type"]

        --
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

            --
            if ability:GetBehavior() ~= DOTA_ABILITY_BEHAVIOR_IMMEDIATE then
                caster:FaceTowards(direction)
                caster:SetForwardVector(direction)
            end

            if current_range > max_range then
                local new_point = caster:GetAbsOrigin() + direction * (max_range - 10)

                filter_table.position_x = new_point.x
                filter_table.position_y = new_point.y
            end

            return true
        end

        --
        if order_type == DOTA_UNIT_ORDER_STOP or order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
            local caster = EntIndexToHScript(filter_table.units["0"])
            local ability = caster:GetCurrentActiveAbility()
            if ability then
                if ability:GetAbilityType() == 1 then
                    return false
                end
            end
        end

        --
        if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
            return false
        end

        return true
    end
end