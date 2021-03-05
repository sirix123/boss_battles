if PlayerManager == nil then
    PlayerManager = class({})
end

LinkLuaModifier("casting_modifier_thinker", "player/generic/casting_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("turnrate_modifier_thinker", "player/generic/turnrate_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function PlayerManager:SetUpMovement()

    self.previous_type = "0"
    self.previous_command = "0"

    CustomGameEventManager:RegisterListener('MoveUnit', function(eventSourceIndex, args)
        --print("GameMode:SetUpMovement(): MoveUnit event caught")

        if args == nil then return end
        if args.command == nil then return end
        if args.heroEnt == nil then return end
        if args.type == nil then return end

        local unit = EntIndexToHScript(args.heroEnt)
        if unit == nil then return end

        -- make sure direction has some value (NPC has initialised)
        if unit.direction == nil then return end

        local playerId = unit:GetPlayerID()
        local player = PlayerResource:GetPlayer(playerId)

        --print("args", args)
        --print("args.command", args.command)
        --print("args.heroEnt", args.heroEnt)
        --print("args.type", args.type)
        --print("unit ",unit)
        --print("---------")

        if self.previous_type ~= "0" and self.previous_command ~= "0" then
            if args.type == self.previous_type and args.command == self.previous_command then

                print("network lag detected - movement controller")

                -- set a flag in the session data so we can search through how many attempts / games have lag?

                -- send a message to the client of the lagger (used to display a network lag message)
                CustomGameEventManager:Send_ServerToPlayer( player, "display_lag_message", nil )

                --unit.direction.x = 0
                --unit.direction.y = 0
                return
            end
        end

        if args.command == "W" then
            if args.type == "+" then
                unit.direction.y = unit.direction.y + 1
            elseif args.type == "-" then
                unit.direction.y = unit.direction.y - 1
            end
        elseif args.command == "A" then
            if args.type == "+" then
                unit.direction.x = unit.direction.x - 1
            elseif args.type == "-" then
                unit.direction.x = unit.direction.x + 1
            end
        elseif args.command == "S"  then
            if args.type == "+" then
                unit.direction.y = unit.direction.y - 1
            elseif args.type == "-" then
                unit.direction.y = unit.direction.y + 1
            end
        elseif args.command == "D"  then
            if args.type == "+" then
                unit.direction.x = unit.direction.x + 1
            elseif args.type == "-" then
                unit.direction.x = unit.direction.x - 1
            end
        end


        self.previous_type = args.type
        self.previous_command = args.command

    end) -- end of MoveUnit listener
end
---------------------------------------------------------------------------------------------------

function PlayerManager:SetUpMouseUpdater()

    -- get mouse postions constantly
    self.mouse_positions = {}
    CustomGameEventManager:RegisterListener('MousePosition', function(eventSourceIndex, args)
        local unit = EntIndexToHScript(args.entityIndex)
        if unit == nil then return end

        --print("MousePosition for playerID: ", args.playerID) -- test player ID
        local mouse_position = Vector(args.x, args.y, args.z)
        self.mouse_positions[args.playerID] = mouse_position
        --print("MousePosition for playerID: ", mouse_position)

        -- testing new code
        unit.mouse.x = args.x
        unit.mouse.y = args.y
        unit.mouse.z = args.z

    end) -- end of SetupMouseUpdater listener

    -- catch mouse release
    CustomGameEventManager:RegisterListener('left_mouse_release', function(eventSourceIndex, args)
        local unit = EntIndexToHScript(args.heroIndex)
        if unit == nil then return end

        -- release/up = 1
        -- press/down = 0
        unit.left_mouse_up_down = args.pos

    end)
end
---------------------------------------------------------------------------------------------------

function PlayerManager:CameraControl( playerID, nCamera )
    --print("PlayerManager:CameraControl, playerid ",playerID)

    local player = PlayerResource:GetPlayer(playerID)
    CustomGameEventManager:Send_ServerToPlayer( player, "camera_control", { nCamera = nCamera, } )
end
---------------------------------------------------------------------------------------------------

--local pressDuration = 0 -- number of ticks key was held for
--local isTimerRunning 
--local timerInterval = 0.1

   -- TODO: Move this code elsewhere. Shouldn't be doing this here.. maybe GameMode:SetUpCastBars()
    -- Catch an event at serverside and then send to client side JS.
    --CustomGameEventManager:RegisterListener('customEvent_abilityCast', function(eventSourceIndex, args)
        --print("GameMode:SetUpMovement() customEvent_abilityCast event")

--Using Almouse ProgressBars Library: https://gitlab.com/ZSmith/dota2-modding-libraries/-/tree/master/ProgressBars
------------------------------------------------------------------------------------------------------------------

        --[[local config = {
            progressBarType = "duration",
            reversedProgress = false, --figure out which way true/false go.

            --style = "EnrageStacks", --style by almouse
            style = "CastBar", --style by almouse
            --style = "castBar" --style by mitch. NOT YET IMPLEMENTED!

            --TODO: Find out where to update this text
            text = "1.0",
            textSuffix = "s"

            --for combo points or stacking de/buff 
            --stacks = 0,
            --maxStacks = 100,
        }
        local heroEntity = EntIndexToHScript(args.heroEntity)
        -- via lua:
        ProgressBars:AddProgressBar(heroEntity, "casting_modifier_thinker", config)]]
        
        -- OR via js, doesn't work atm : 
        --CustomGameEventManager:Send_ServerToAllClients("progress_bar", config)


-- Sending an event to JS. castbar.js has subscribed listener on customEvent_abilityCast
----------------------------------------------------------------------------------------
        --WIP: My attempt at ProgressBar animation. 

        -- local playerEntity = args.playerEntity
        -- local heroEntity = EntIndexToHScript(args.heroEntity)
        -- local heroEntityOrig = args.heroEntity

        -- -- TODO: Send the event to the player casting it. 
        -- --I can't get any of the three parameters to work.
        -- local data_toPlayer = {}
        -- data_toPlayer.method = "Send_ServerToPlayer"
        -- --CustomGameEventManager:Send_ServerToPlayer( playerEntity, "customEvent_abilityCast", data_toPlayer )
        -- --CustomGameEventManager:Send_ServerToPlayer( heroEntity, "customEvent_abilityCast", data_toPlayer )
        -- --CustomGameEventManager:Send_ServerToPlayer( heroEntityOrig, "customEvent_abilityCast", data_toPlayer )

        -- -- HACK-WorkAround: Send the event to all clients, for testing purposes this is okay
        -- local data_toAllClients = {}
        -- data_toAllClients.method = "Send_ServerToPlayer"
        -- CustomGameEventManager:Send_ServerToAllClients("customEvent_abilityCast", data_toAllClients)
    --end)