function GameMode:SetUpMovement()
    CustomGameEventManager:RegisterListener('MoveUnit', function(eventSourceIndex, args)
        --local direction = args.direction

        --for k, v in pairs(args) do
            --print("k = ",k,"v = ",v)
        --end

        local unit = EntIndexToHScript(args.entityIndex)

        if unit == nil then return end
        if unit.direction == nil then return end--then
            --unit.direction = {
             --   y = 0,
             --   x = 0
            --}
      --  end

        --print(unit:GetUnitName())
        --print(unit.direction.y)

        if args.direction == "up" then
            --local currentLocation = unit:GetAbsOrigin()
            --local futureLocation = currentLocation + unit:GetForwardVector():Normalized() * 100

            --print(currentLocation)
            --print(futureLocation)
            --StartAnimation(unit, {duration = 100, activity = ACT_DOTA_RUN, rate = 1.0, base = 1})
            --unit:SetAbsOrigin(futureLocation)

            --print("Moving hero forward")
            --print("before movement command Unit.direction.y = ", unit.direction.y)
           
            unit.direction.y = unit.direction.y + 1
            --print("after movement command Unit.direction.y = ", unit.direction.y)
        end

    end)

    CustomGameEventManager:RegisterListener('StopUnit', function(eventSourceIndex, args)

        local unit = EntIndexToHScript(args.entityIndex)

        if unit == nil then return end
        if unit.direction == nil then return end

        if args.direction == "down" then
            unit.direction.y = unit.direction.y - 1
        end

    end)


end