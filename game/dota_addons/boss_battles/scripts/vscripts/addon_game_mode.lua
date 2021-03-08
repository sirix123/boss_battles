if BossBattles == nil then
	BossBattles = class({})
end

-- barebones/libs needs to be cleaned up
require('libraries/timers')
require('libraries/physics')
require('libraries/notifications')
require('libraries/playertables')
require('libraries/selection')
--require('libraries/ProgressBars')
require('libraries/projectiles')
require('libraries/animations')
require('utility_functions')
require('precache')

function Precache( context ) -- this needs to be in a seperate file
  -- gyro precache:
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_gyrocopter.vsndevts", context)


  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_beastmaster.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_beastmaster.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_lone_druid.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context)

  -- timber Precache
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_shredder.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_furion.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context)
  
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
  PrecacheUnitByNameSync("npc_timber", context)
  PrecacheUnitByNameSync("npc_mine_droid", context)
  PrecacheUnitByNameSync("npc_stun_droid", context)
  PrecacheUnitByNameSync("npc_smelter_droid", context)
  PrecacheUnitByNameSync("npc_techies", context)
  PrecacheUnitByNameSync("npc_guard", context)

  -- warlord preachce
  PrecacheUnitByNameSync("npc_ward", context)

  -- rogue preachce
  PrecacheUnitByNameSync("npc_shadow", context)

  -- ice mage prcache
  PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context)

  -- ranger precache
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_medusa.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_creeps.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_snapfire.vsndevts", context)

  -- clock preache
  PrecacheResource("particle",	"particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre.vpcf", context)
  PrecacheResource("particle",	"particles/clock/clock_hero_snapfire_ultimate_linger.vpcf", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_rattletrap.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context)

  -- techies prechace
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_techies.vsndevts", context)

  -- tinker
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_rubick.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_tinker.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_tusk.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_batrider.vsndevts", context)

  PrecacheUnitByNameSync("npc_crystal", context)
  PrecacheUnitByNameSync("npc_tinker", context)
  PrecacheUnitByNameSync("npc_ice_ele", context)
  PrecacheUnitByNameSync("npc_fire_ele", context)
  PrecacheUnitByNameSync("npc_elec_ele", context)

  local npcs = LoadKeyValues("scripts/npc/npc_units_custom.txt")

  for k, _ in pairs(npcs) do
    PrecacheUnitByNameSync(k, context)
  end

end

function Activate()

  if GetMapName() == "arena_6x6" then
    require('internal/util')
    require('gamemode')

    GameRules.GameMode = GameMode()
    GameRules.GameMode:_InitGameMode()

  end
  if GetMapName() == "main_map" then
    if BossBattles == nil then
      BossBattles = class({})
    end

    -- our stuff
    require('constants')
    require('client_handshake')
    require('core/npc_override')
    require('core/ability_override')
    require('internal/util')
    require('gamerules')
    require('commands')

    require('game_setup')
    require('intermission_manager')

    require('managers/game_manager')
    require('filters')
    require('managers/player_manager')

    require('heroselection')
    require('scoreboard')
    require('boss_frame_manager')
    require('player_frame_manager')
    require('mode_selector')
    require('player/generic/targeting_indicator')

    require('session_manager')
    require('webapi')

    GameRules.AddonTemplate = BossBattles()
    GameRules.AddonTemplate:InitGameMode()
  end
end

function BossBattles:InitGameMode()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	GameSetup:init()
end

-- Evaluate the state of the game
function BossBattles:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end