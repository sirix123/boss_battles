require('webapi')

if PlayerManager == nil then
    PlayerManager = class({})
end

LinkLuaModifier("casting_modifier_thinker", "player/generic/casting_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

local pressDuration = 0 -- number of ticks key was held for
local isTimerRunning 
local timerInterval = 0.1


--TODO implement. 
function GetClassIcon(className)
    --TODO: for each class get the icon file/location
    return "file://{images}/class_icons/icon_person.png"
end

function PlayerManager:SetUpMovement()
    --TODO: move this code elsewhere. Basically RegisterListener at the start of game

    --The following listeners are waiting for Javascript to call them via:
    --GameEvents.SendCustomGameEventToServer("showScoreboardEvent", {});

    -- local value = {}
    -- CustomNetTables:SetTableValue("score_board", "key", value)

    --Listen for getScoreboardDataEvent from JS, then call WebApi:GetAndShowScoreboard()
    CustomGameEventManager:RegisterListener('getScoreboardDataEvent', function(eventSourceIndex, args)
        print("getScoreboardDataEvent caught")
        local heroIndex = args.heroIndex 
        local playerId = args.playerId
        if _G.scoreboardData == nil then
            WebApi:GetScoreboardData(heroIndex) 
        end
    end)

    --Listen for showScoreboardUIEvent from JS, then send showScoreboardUIEvent event back to JS
    CustomGameEventManager:RegisterListener('showScoreboardUIEvent', function(eventSourceIndex, args)
        -- print("showScoreboardUIEvent caught")
        -- print("getting boss scoreboard data for " ..#HeroList:GetAllHeroes().." heroes")                
        local bsbRows = {}
        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs(heroes) do
            local unitName = EntIndexToHScript(hero:GetEntityIndex()):GetUnitName()
            local className = GetClassName(unitName)
            local playerName = PlayerResource:GetPlayerName(EntIndexToHScript(hero:GetEntityIndex()):GetPlayerOwnerID())
            local dmgTaken = GetDamageTaken(hero:GetEntityIndex())
            local dmgDone = GetDamageDone(hero:GetEntityIndex())

            bsbRow = {}
            bsbRow.class_name = className
            bsbRow.class_icon = GetClassIcon(className)
            bsbRow.player_name = playerName
            bsbRow.dmg_done = dmgDone
            bsbRow.dmg_taken = dmgTaken

            bsbRows[#bsbRows+1] = bsbRow
        end
        print( args.playerId.." requested to see the scoreboard. Showing data: " ..dump(bsbRows))
        print(" HeroList:GetAllHeroes() contains ".. #HeroList:GetAllHeroes() .. " heroes")

        local luaPlayer = EntIndexToHScript(args.heroIndex):GetPlayerOwner()
        local convarClient = Convars:GetCommandClient()
        local player = PlayerResource:GetPlayer(args.playerId)
        

        --CustomGameEventManager:Send_ServerToPlayer( player, "showScoreboardUIEvent", bsbRows )
        --CustomGameEventManager:Send_ServerToPlayer( heroIndex, "showScoreboardUIEvent", bsbRows )
        CustomGameEventManager:Send_ServerToPlayer( luaPlayer, "showScoreboardUIEvent", bsbRows )
        CustomGameEventManager:Send_ServerToPlayer( player, "showScoreboardUIEvent", bsbRows )
        CustomGameEventManager:Send_ServerToPlayer( convarClient, "showScoreboardUIEvent", bsbRows )
    end)

    --Listen for hideScoreboardUIEvent from JS, then send hideScoreboardUIEvent event back to JS
    CustomGameEventManager:RegisterListener('hideScoreboardUIEvent', function(eventSourceIndex, args)
        local luaPlayer = EntIndexToHScript(args.heroIndex):GetPlayerOwner()
        local convarClient = Convars:GetCommandClient()
        local player = PlayerResource:GetPlayer(args.playerId)

        CustomGameEventManager:Send_ServerToPlayer( luaPlayer, "hideScoreboardUIEvent", {} )
        CustomGameEventManager:Send_ServerToPlayer( convarClient, "hideScoreboardUIEvent", {} )
        CustomGameEventManager:Send_ServerToPlayer( player, "hideScoreboardUIEvent", {} )
    end)















    -- TODO: Move this code elsewhere. Shouldn't be doing this here.. maybe GameMode:SetUpCastBars()
    -- Catch an event at serverside and then send to client side JS.
    CustomGameEventManager:RegisterListener('customEvent_abilityCast', function(eventSourceIndex, args)
        --print("GameMode:SetUpMovement() customEvent_abilityCast event")

--Using Almouse ProgressBars Library: https://gitlab.com/ZSmith/dota2-modding-libraries/-/tree/master/ProgressBars
------------------------------------------------------------------------------------------------------------------

        local config = {
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
        ProgressBars:AddProgressBar(heroEntity, "casting_modifier_thinker", config)
        
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
    end)


    CustomGameEventManager:RegisterListener('MoveUnit', function(eventSourceIndex, args)
        --print("GameMode:SetUpMovement(): MoveUnit event caught")
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

function PlayerManager:SetUpMouseUpdater()
    self.mouse_positions = {}
    CustomGameEventManager:RegisterListener('MousePosition', function(eventSourceIndex, args)
        local unit = EntIndexToHScript(args.entityIndex)
        if unit == nil then return end

        --print("MousePosition for playerID: ", args.playerID) -- test player ID
        --local mouse_position = Vector(args.x, args.y, args.z)
        --self.mouse_positions[args.playerID] = mouse_position

        -- testing new code
        unit.mouse.x = args.x
        unit.mouse.y = args.y
        unit.mouse.z = args.z

    end) -- end of SetupMouseUpdater listener
end
---------------------------------------------------------------------------------------------------

-- indicators
-- cast bar 
-- 