Filters = Filters or class({})

function Filters:Activate(GameMode, this)
    function GameMode:ExecuteOrderFilter(filter_table)
        local order_type = filter_table["order_type"]

        --PrintTable(filter_table)

        -- need to validate the event coming in
        -- if the caster has that ability, if they have mana, if its off cooldown
        local caster = EntIndexToHScript(filter_table.units["0"])
        local ability = EntIndexToHScript(filter_table.entindex_ability)

        --print("caster:HasItemInInventory(ability:GetName()): ",caster:HasItemInInventory(ability:GetName()))
        --print("----------------------------------------")

        if caster:HasAbility(ability:GetName()) == false and caster:HasItemInInventory(ability:GetName()) == false then
            return false
        end

        if ability:IsFullyCastable() == false or ability:IsCooldownReady() == false or ability:GetLevel() < 1 then
            return false
        end

        --PrintTable(filter_table)
        --[[
            entindex_ability: 274
            entindex_target: 273
            issuer_player_id_const: 0
            order_type: 5
            position_x: -12310.60546875
            position_y: -10201.342773438
            position_z: 256.80773925781
            queue: 0
            sequence_number_const: 57
            shop_item_name:
            units:
                    0: 273

                techies rock
            entindex_ability: 182
            entindex_target: 0
            issuer_player_id_const: 0
            order_type: 5
            position_x: 10174.032226563
            position_y: 637.04125976563
            position_z: 130.12109375
            queue: 0
            sequence_number_const: 7
            shop_item_name: 
            units:
                    0: 281
        ]]

        -- if caster is dead dont do any of this

        if caster:IsAlive() == false or caster:IsStunned() == true then
            return false
        end

        --

        --print("direction casting ",filter_table.position_z)
        --print("caster z location ",caster:GetAbsOrigin().z)

        if order_type == DOTA_UNIT_ORDER_CAST_POSITION or order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET  then
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
        if order_type == DOTA_UNIT_ORDER_CAST_TARGET then
            local ability = EntIndexToHScript(filter_table.entindex_ability)
            --local caster = EntIndexToHScript(filter_table.units["0"])
            local target = EntIndexToHScript(filter_table.entindex_target)
            local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
            local max_range = ability:GetCastRange(Vector(0,0,0), nil)
            local current_range = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

            --[[for k, v in pairs(filter_table) do
                print("key = ",k,"value = ",v)
            end
            print("target = ",target:GetAbsOrigin())]]

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
                if ability:GetAbilityType() == 1 then
                    return false
                end
            end
        end

        --
        if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION then
            return false
        end

        return true
    end
end