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
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)

  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_beastmaster.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_beastmaster.vsndevts", context)

  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_lone_druid.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context)

  -- timber Precache
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_shredder.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
  PrecacheResource("particle", "particles/units/heroes/hero_shredder/shredder_chakram.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_shredder/shredder_chakram_stay.vpcf", context)
  PrecacheResource("particle",	"particles/units/heroes/hero_shredder/shredder_chakram_return.vpcf", context) 
  

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