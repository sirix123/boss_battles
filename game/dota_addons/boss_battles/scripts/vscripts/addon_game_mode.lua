-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  PrecacheResource("soundfile", "sounds/vo/beastmaster/beas_ability_summonsboar_05.vsnd", context)
  PrecacheResource("soundfile", "sounds/vo/beastmaster/beas_ability_summonsboar_05.vsnd", context)
  PrecacheResource("soundfile", "sounds/weapons/hero/crystal_maiden/frostbite.vsnd", context)
  
  -- test mrege

  
end

-- hello moomoo
-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()

  if IsInToolsMode() then
    Timers:CreateTimer(2, function()
      --Tutorial:AddBot("npc_dota_hero_sven", "", "", false)
    end)
  end
end