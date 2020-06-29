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

  -- saw blades
  PrecacheResource("particle", "particles/units/heroes/hero_shredder/shredder_chakram.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_shredder/shredder_chakram_stay.vpcf", context)
  PrecacheResource("particle",	"particles/units/heroes/hero_shredder/shredder_chakram_return.vpcf", context)

  -- fireshell
  PrecacheResource("particle",	"particles/timber/napalm_wave_basedtidehuntergushupgrade.vpcf", context)

  -- droids
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
  PrecacheResource("particle",	"particles/units/heroes/hero_pugna/pugna_life_give.vpcf", context)
  PrecacheResource("particle",	"particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", context)
  PrecacheResource("particle",	"particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_tinker.vsndevts", context)

  -- droids unit precache
  --PrecacheUnitByNameSync(string string_1, handle handle_2, int int_3)
  PrecacheUnitByNameSync("npc_timber", context)
  PrecacheUnitByNameSync("npc_mine_droid", context)
  PrecacheUnitByNameSync("npc_stun_droid", context)
  PrecacheUnitByNameSync("npc_smelter_droid", context)

   -- ice mage prcache
  PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context)

end

-- hello moomoo
-- hello stefan

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