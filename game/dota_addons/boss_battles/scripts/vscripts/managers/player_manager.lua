function GameMode:SetUpMovement()
    CustomGameEventManager:RegisterListener('MoveUnit', function(eventSourceIndex, args)
        local direction = args.direction
        local keyPressed = args.keyPressed
        local keyState = args.keyState

        local unit = EntIndexToHScript(args.entityIndex)
        if unit == nil then return end

        -- W key
        if keyPressed == "w" and keyState == "down" then
            unit.direction.y = unit.direction.y + 1
        end
        if keyPressed == "w" and keyState == "up" then
            unit.direction.y = unit.direction.y - 1
        end

        -- D key
        if keyPressed == "d" and keyState == "down" then
            unit.direction.x = unit.direction.x + 1
        end
        if keyPressed == "d" and keyState == "up" then
            unit.direction.x = unit.direction.x - 1
        end

        -- S key
        if keyPressed == "s" and keyState == "down" then
            unit.direction.y = unit.direction.y - 1
        end
        if keyPressed == "s" and keyState == "up" then
            unit.direction.y = unit.direction.y + 1
        end

        -- A key
        if keyPressed == "a" and keyState == "down" then
            unit.direction.x = unit.direction.x - 1
        end
        if keyPressed == "a" and keyState == "up" then
            unit.direction.x = unit.direction.x + 1
        end

    end) -- end of MoveUnit listener
end
---------------------------------------------------------------------------------------------------

function GameMode:SetUpMouseUpdater()
    CustomGameEventManager:RegisterListener('MousePosition', function(eventSourceIndex, args)
        self.mouse_positions = {}

        local mouse_position = Vector(args.x, args.y, args.z)

        self.mouse_positions[args.playerID] = mouse_position

    end) -- end of SetupMouseUpdater listener
end
