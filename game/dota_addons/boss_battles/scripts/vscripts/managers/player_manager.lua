if PlayerManager == nil then
    PlayerManager = class({})
end

LinkLuaModifier("casting_modifier_thinker", "player/generic/casting_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("turnrate_modifier_thinker", "player/generic/turnrate_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function PlayerManager:SetUpMovement()

    Timers:CreateTimer(3, function()

        for _, unit in pairs(HERO_LIST) do
            unit.playerLagging = false
        end

        return 3
    end)

    CustomGameEventManager:RegisterListener('MoveUnit', function(eventSourceIndex, args)
        --print("GameMode:SetUpMovement(): MoveUnit event caught")

        --[[print("args", args)
        print("args", args.command)
        print("args.heroEnt", args.heroEnt)
        print("args.type", args.type)
        print("hero", EntIndexToHScript(args.heroEnt):GetUnitName())
        print("player ",player)
        print("---------")]]

        if args.PlayerID == nil then return end
        local pID = args.PlayerID

        local hPlayer = PlayerResource:GetPlayer(pID)
        if hPlayer == nil then return end

        local hPlayerHero = hPlayer:GetAssignedHero()
        if hPlayerHero == nil then return end

        hPlayerHero.currentType = args.type
        hPlayerHero.currentCommand = args.command

        if hPlayerHero.playerLagging == true then
            hPlayerHero.direction.x = 0
            hPlayerHero.direction.y = 0
            return
        end

        if hPlayerHero.currentType == hPlayerHero.previousType and hPlayerHero.currentCommand == hPlayerHero.previousCommand then
            hPlayerHero.playerLagging = true
            print("network lag detected - movement controller")
            CustomGameEventManager:Send_ServerToPlayer( player, "display_lag_message", nil )
        elseif hPlayerHero.playerLagging == false then
            if args.command == "W" then
                if args.type == "+" then
                    hPlayerHero.direction.y = hPlayerHero.direction.y + 1
                elseif args.type == "-" then
                    hPlayerHero.direction.y = hPlayerHero.direction.y - 1
                end
            elseif args.command == "A" then
                if args.type == "+" then
                    hPlayerHero.direction.x = hPlayerHero.direction.x - 1
                elseif args.type == "-" then
                    hPlayerHero.direction.x = hPlayerHero.direction.x + 1
                end
            elseif args.command == "S"  then
                if args.type == "+" then
                    hPlayerHero.direction.y = hPlayerHero.direction.y - 1
                elseif args.type == "-" then
                    hPlayerHero.direction.y = hPlayerHero.direction.y + 1
                end
            elseif args.command == "D"  then
                if args.type == "+" then
                    hPlayerHero.direction.x = hPlayerHero.direction.x + 1
                elseif args.type == "-" then
                    hPlayerHero.direction.x = hPlayerHero.direction.x - 1
                end
            end

            hPlayerHero.previousType = hPlayerHero.currentType
            hPlayerHero.previousCommand = hPlayerHero.currentCommand
        end

    end) -- end of MoveUnit listener
end
---------------------------------------------------------------------------------------------------

function PlayerManager:SetUpMouseUpdater()

    -- get mouse postions constantly
    self.mouse_positions = {}
    CustomGameEventManager:RegisterListener('MousePosition', function(eventSourceIndex, args)
        if args.PlayerID == nil then return end

        local pID = args.PlayerID
        local hPlayer = PlayerResource:GetPlayer(pID)

        if hPlayer == nil then return end
        local hPlayerHero = hPlayer:GetAssignedHero()

        --print("MousePosition for playerID: ", args.playerID) -- test player ID
        local mouse_position = Vector(args.x, args.y, args.z)
        self.mouse_positions[pID] = mouse_position
        --print("MousePosition for playerID: ", mouse_position)

        if hPlayerHero == nil then return end
        if hPlayerHero.mouse == nil then return end

        -- testing new code
        hPlayerHero.mouse.x = args.x
        hPlayerHero.mouse.y = args.y
        hPlayerHero.mouse.z = args.z

    end) -- end of SetupMouseUpdater listener

    -- catch mouse release
    CustomGameEventManager:RegisterListener('left_mouse_release', function(eventSourceIndex, args)
        if args.PlayerID == nil then return end

        local pID = args.PlayerID
        local hPlayer = PlayerResource:GetPlayer(pID)

        if hPlayer == nil then return end
        local hPlayerHero = hPlayer:GetAssignedHero()

        --PrintTable(args)

        -- release/up = 1
        -- press/down = 0
        if hPlayerHero == nil then return end
        hPlayerHero.left_mouse_up_down = args.pos

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