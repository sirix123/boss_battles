LinkLuaModifier("casting_modifier_thinker", "player/generic/casting_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

local pressDuration = 0 -- number of ticks key was held for
local isTimerRunning 
local timerInterval = 0.1

function GameMode:SetUpMovement()

    CustomGameEventManager:RegisterListener('grenade', function(eventSourceIndex, args)
    print("myFunction called!")
        --DEBUG: print all args passed in
        for k, v in pairs(args) do
            print("k = ",k,"v = ",v)
        end


        local keyState = args.keyState
        local unit = EntIndexToHScript(args.entityIndex)
        if unit == nil then return end


        local unitAbilityBeingCast = unit:GetCurrentActiveAbility()
        print("unitAbilityBeingCast = ", unitAbilityBeingCast)


        local abilityBeingCast = self:GetCurrentActiveAbility()
        print("abilityBeingCast = ", abilityBeingCast)

        local abCursor = abilityBeingCast:GetCursorPosition()
        print("abCursor = ", abCursor)


        
        local origin = unit:GetAbsOrigin()
        local cursor = Vector(args.cursor[0], args.cursor[1],0)
        print("cursor = ", cursor)

        local shouldStopTimer = false
        if  keyState == "up" then
            shouldStopTimer = true
        end

        if  keyState == "down" then
            Timers:CreateTimer(function()
                if shouldStopTimer then
                    print("shouldStopTimer = true, stopping the timer")
                    print("TODO Cast grenade spell")
                    return 
                end

                pressDuration = pressDuration + 1

                local vec_distance = cursor - origin
                print("vec_distance = ", vec_distance)
                local direction = (vec_distance):Length2D():Normalized()

                print("direction = ", direction)
                --now unNormalize for the line
                local vecPowerShot = Vector(direction.x * pressDuration, direction.y * pressDuration, 0)

                DebugDrawLine(origin, vecPowerShot, 255,0,0, true, timerInterval)
                --Draw the current state/progress
                --just draw a line... a box is hard because of rotation?
            
            end) -- end of timer
        end

    
    end) --end grenade listener




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
---------------------------------------------------------------------------------------------------

-- indicators
-- cast bar 
-- 