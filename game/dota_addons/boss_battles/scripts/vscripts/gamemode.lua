-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- Progress bars
require('libraries/ProgressBars')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

require('libraries/projectiles') -- This library allow for easily delayed/timed actions
require('libraries/animations') -- This library allows starting customized animations on units from lua

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
require('utility_functions')


-- game handler
require('managers/game_manager')
require('filters')

-- core functions
require('core/npc_override')

require('player/generic/targeting_indicator')

-- player handler / core player scripts
require('managers/player_manager')
LinkLuaModifier( "movement_modifier_thinker", "player/generic/movement_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "remove_attack_modifier", "player/generic/remove_attack_modifier", LUA_MODIFIER_MOTION_NONE )





-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

--require("examples/worldpanelsExample")

-- functions here are called in the main game cycle below
function GameMode:SetupFilters()
  Filters:Activate(GameMode, self)

  local mode = GameRules:GetGameModeEntity()
  mode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "ExecuteOrderFilter" ), GameMode)
end

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
  PlayerManager:SetUpMovement()
  PlayerManager:SetUpMouseUpdater()
end


function GameMode:OnGameEnd()
  print("GameMode:OnGameEnd()")
  
  --TODO!
  --Send game stats to firebase 
  
end


--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")

  --To end the game: 
  --GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)

  --Start a timer that waits for the end of the game (DOTA_GAMERULES_STATE_POST_GAME) then calls OnGameEnd
  Timers:CreateTimer(function()
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_POST_GAME then
      return 1
    else
      GameMode:OnGameEnd()
      return
    end
  end)  

  Timers:CreateTimer(function()
    -- data = {}... your code here
    return 0.1;
  end)


  -- We have a check delay, because the bot is actually added after OnAllPlayersLoaded
  local checkDelay = 0
  if IsInToolsMode() then
    checkDelay = 3
  end

  Timers:CreateTimer(checkDelay, function()
    for i=0, DOTA_MAX_TEAM_PLAYERS do
      if PlayerResource:GetConnectionState(i) ~= 0 then
        GameRules.num_players = GameRules.num_players + 1
      end
    end
  end)

  Timers:CreateTimer(checkDelay, function()
    local heroCount = TableCount(HeroList:GetAllHeroes())
    if heroCount ~= GameRules.num_players then
      return 1
    end

    -- Wait just a bit more, just to be sure
    local safteyDelay = 10
    if IsInToolsMode() then
      safteyDelay = 1
    end
    Timers:CreateTimer(safteyDelay, function()
      -- Add all the players and start the game
      for _,hero in pairs(HeroList:GetAllHeroes()) do
        local team = hero:GetTeam()
        GameRules.teams[team] = true
        GameRules.teamToPlayer[team] = hero:GetPlayerID()
        GameRules.score[team] = 0
      end

      GameMode.heroList = HeroList:GetAllHeroes()

      if not IsInToolsMode() then
        -- call a function that handles the 'raid'
        -- GameMode:StartRandomGame()
      else
        -- this should be used for a playground (generic boss arena for testing)
        
      end
    end)

    return
  end)
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.


  The hero parameter is the hero entity that just spawned in
]]

function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  --TEST: FIREBASE web api testing, just wanted to trigger it when the game strarts
  --WebApi:DemoForStefan()
  --WebApi:DemoForStefan()
  --WebApi:PostScoreboardDummyData()
  --WebApi:SavePlayHistory(hero)

  -- hero:AddNewModifier( hero,  nil, "movement_modifier_thinker", { } )
  -- hero:AddNewModifier( hero,  nil, "remove_attack_modifier", { } )

  -- level up abilities for all heroes to level 1
  if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" or hero:GetUnitName() == "npc_dota_hero_windrunner" then
    local index = 0
    while (hero:GetAbilityByIndex(index) ~= nil) do
      hero:GetAbilityByIndex(index):SetLevel(1)
      index = index +1
    end
  end

  Timers:CreateTimer(.03, function()
    for i=0,8 do
      local item = hero:GetItemInSlot(i)
      if item ~= nil and item:GetAbilityName() == "item_tpscroll" then
        --hero:RemoveItem(item)
        item:RemoveSelf()
      end
    end
  end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  if GetMapName() == "arena_6x6" then
    GameManager:StartRaid()
  elseif GetMapName() == "arena_6x6" then
    -- setup custom game arena
  end

  --TODO: WebApi: ...

end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')


  --TODO: WebApi:GetLeaderboard?

  self:SetupFilters()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand( "moredots_start_game_by_name", function(name, gameName)
      GameMode:StartGameByName(gameName)
    end, "End the current bossfight and start the one with this name.", FCVAR_CHEAT )
  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  GameRules:SetCustomGameAllowHeroPickMusic( false )
  GameRules:SetCustomGameAllowBattleMusic( false )
  GameRules:SetCustomGameAllowMusicAtGameStart( true )

  GameRules.teams = {}
  GameRules.teamToPlayer = {}
  GameRules.score = {}
  GameRules.round = 0
  GameRules.num_players = 0
  GameRules.MAX_ROUNDS = 10

  if GetMapName() == "arena_test" then
    SKIP_TEAM_SETUP = false
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 1)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 2)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 2)

  end
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  GameMode:StartGameByName(gameName)
  -- if cmdPlayer then
  --   local playerID = cmdPlayer:GetPlayerID()
  --   if playerID ~= nil and playerID ~= -1 then
  --     -- Do something here for the player who called this command
  --   end
  -- end

  print( '*********************************************' )
end

function GameMode:CustomGameSetup()

  return
end




