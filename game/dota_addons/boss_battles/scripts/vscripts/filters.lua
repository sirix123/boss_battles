if Filters == nil then
    Filters = class({})
end

LinkLuaModifier( "casting_modifier_thinker", "player/generic/casting_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function Filters:Activate(GameMode, this)
    function GameMode:ExecuteOrderFilter(filter_table)
        local order_type = filter_table["order_type"]

        local caster = EntIndexToHScript(filter_table.units["0"])

        --[[

            Boss battles casting system...

            ability index 0 is always the players basic attack and bound to mouse button 1 (m1), meaning you can hold down m1 and every 0.1s it tries to cast the abilty bound to m1

            if a player is holding down m1 or spam pressing m1 and presses another ability the new ability should be cast (override the m1)
                    (M1 shouldn't interupt spells)

                while the castpoint of the new ability is running the player should ignore orders to cast m1
                if the player tries to cast another abiltiy during the cast point of the previous non m1 ability the new ability should override

            holding or pressing m1 during another ability should never stop the new ability being cast

            if spam pressing a new ability it should never interupt itself

            abilities shouldn't queue up either...

            loose logic...

            if player is casting and the ability being cast is ability index 0..
                continue and cast ability
            if player is casting and the ability being cast isn't ability 0..
                interupt current cast if its not the new ability and its not ability index 0, cast the ability

            if we somehow get any move orders don't do them at all

        ]]

        --print("order_type ",order_type)
        --PrintTable(filter_table)

        -- if we get any move orders don't do shit
        if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION then
            --caster:Interrupt()
            return false
        end

        if order_type ~= DOTA_UNIT_ORDER_STOP and order_type ~= DOTA_UNIT_ORDER_HOLD_POSITION then
            if caster:GetCurrentActiveAbility() ~= nil then -- if we are currently casting something
                if filter_table.entindex_ability ~= nil then -- and we are trying to cast an ability

                    if EntIndexToHScript(filter_table.entindex_ability):GetAbilityIndex() == 0 then
                        return false
                    end

                    if EntIndexToHScript(filter_table.entindex_ability) then

                        --print("casting ability... ",caster:GetCurrentActiveAbility():GetAbilityIndex(), " trying to cast this... ", EntIndexToHScript(filter_table.entindex_ability):GetAbilityIndex())

                        if  ( EntIndexToHScript(filter_table.entindex_ability):GetAbilityIndex() ~= 0 ) and -- if the new ability isn't a basic attack m0
                            ( EntIndexToHScript(filter_table.entindex_ability):GetAbilityIndex() ~= caster:GetCurrentActiveAbility():GetAbilityIndex() ) -- and its not the ability we are currently casting
                            then

                            caster:Interrupt()

                            -- the REAL 100% issue here for future stefan...!
                            -- i cast icelance during the cp i cast frostblink if im moving the opposite direction to the m2 cast location i getr the forced moevment bug
                            -- because i am looking away from the cast pos i cant cast my spell, 
                            -- because i cant start casting my spell i dont get the casting thinker and therefore the movement thinker faces me towads where i am moving
                            -- if i do this and im facing where i am casting its ok...
                            -- SOLUTION somehow for this case only? force the char to look where they need to cast


                            -- DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            -- ADD TO ALL SPELLLLLLLLLLLLLLS!

                            print("[filters] interrupting current ability to cast another ability (non m1)")

                            --return false --this fixes the forced movement...
                        end
                    end
                end
            end
            --print("casting... ",EntIndexToHScript(filter_table.entindex_ability):GetAbilityName())
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

            if current_range > max_range then --or caster.skip == false
                --print("current range greater then max range...")
                local new_point = caster:GetAbsOrigin() + direction * (max_range - 10) --10

                filter_table.position_x = new_point.x
                filter_table.position_y = new_point.y

                --DebugDrawCircle(new_point,Vector(255,0,0),128,100,true,60)
            end

            --DebugDrawCircle(point,Vector(255,0,0),128,100,true,60)
            --DebugDrawCircle(caster:GetAbsOrigin(),Vector(255,0,0),128,100,true,60)

            -- modifier this... to ignore the mouse pos from client and cast at new cusor location based on whats stored on the player? if sdkip is false?

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

        return true
    end
end