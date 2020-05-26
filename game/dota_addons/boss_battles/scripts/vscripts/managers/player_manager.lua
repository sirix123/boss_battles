function GameMode:SetUpMovement()
    CustomGameEventManager:RegisterListener('MoveUnit', function(eventSourceIndex, args)
        local direction = args.direction
        local keyPressed = args.keyPressed
        local keyState = args.keyState
        --DEBUG: print all args passed in
        --for k, v in pairs(args) do
            --print("k = ",k,"v = ",v)
        --end

        local unit = EntIndexToHScript(args.entityIndex)
        if unit == nil then return end
        --if unit.direction == nil then return end

        -- W key
        if keyPressed == "w" and keyState == "down" then
            unit.direction.y = 1
        end
        if keyPressed == "w" and keyState == "up" then
            unit.direction.y = 0
        end

        -- D key
        if keyPressed == "d" and keyState == "down" then
            unit.direction.x = 1
        end
        if keyPressed == "d" and keyState == "up" then
            unit.direction.x = 0
        end

        -- S key
        if keyPressed == "s" and keyState == "down" then
            unit.direction.y = -1
        end
        if keyPressed == "s" and keyState == "up" then
            unit.direction.y = 0
        end

        -- A key
        if keyPressed == "a" and keyState == "down" then
            unit.direction.x = -1
        end
        if keyPressed == "a" and keyState == "up" then
            unit.direction.x = 0
        end


        if args.direction == "up" then
            --local currentLocation = unit:GetAbsOrigin()
            --local futureLocation = currentLocation + unit:GetForwardVector():Normalized() * 100

            --print(currentLocation)
            --print(futureLocation)
            --StartAnimation(unit, {duration = 100, activity = ACT_DOTA_RUN, rate = 1.0, base = 1})
            --unit:SetAbsOrigin(futureLocation)

            --print("Moving hero forward")
            --print("before movement command Unit.direction.y = ", unit.direction.y)
           
            --unit.direction.y = unit.direction.y + 1
            --unit.direction.y = 1
            --print("after movement command Unit.direction.y = ", unit.direction.y)
        end
    end) -- end of MoveUnit listener

end