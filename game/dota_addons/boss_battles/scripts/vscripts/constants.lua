_G.BOSS_BATTLES_PLAYER_LIVES = 3

_G.BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION = Vector(-10757, -9796, 256)

_G.BOSS_BATTLES_ENCOUNTER_COUNTER = 2 -- inermission is encounter 1

_G.BOSS_BATTLES_RESPAWN_TIME = 5

_G.TotalDamageDone = {}
_G.DamageTable = {}

_G.nBOSSES_KILLED = 0

_G.PLAYERS_CLIENTS_READY = {}

_G.TRACK_DATA = false -- still lags the game even just tracking dmg done by heroes

-- any unit in this table will not be hit by projectiles (if using barebones proj lib)
_G.tUNIT_TABLE =
{
    "npc_dota_techies_land_mine",
    "npc_shadow",
    "npc_dota_gyrocopter_homing_missile",
    "npc_dota_thinker",
    "npc_rubick",
    "npc_lina_remant",
    --"npc_cleaning_bot",
    "npc_beastmaster_dino",
    "npc_rock_techies",
    "npc_flame_turret",
    "npc_cm_cosmetic_pet",
}

_G.UNQIUE_INT = 0

_G.PICKING_DONE = false
_G.PLAYERS_FIGHTING_BOSS = false

_G.HERO_LIST = {}

_G.EASY_MODE = true
_G.STORY_MODE = false
_G.NORMAL_MODE = false
_G.HARD_MODE = false
_G.DEBUG_MODE = false

-- set before a release
_G.sRELEASE_NUMBER = "0.0.1a"

_G.nATTEMPT_TRACKER = 0
_G.nBOSS_HP_ATTEMPT = 0
_G.bGAME_COMPLETE = false

_G.flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25
_G.flWHIRLING_WINDS_PROJ_SPEED_BONUS = 0.25

_G.HERO_NAME_LIST =
{
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_lina",
    "npc_dota_hero_omniknight",
    "npc_dota_hero_queenofpain",
    "npc_dota_hero_windrunner",
    --"npc_dota_hero_hoodwink",
    "npc_dota_hero_huskar",
    --"npc_dota_hero_pugna",
    "npc_dota_hero_oracle",
}

_G.tCORE_MODIFIERS =
{
    "movement_modifier_thinker",
    "remove_attack_modifier",
    "admin_god_mode",
    "modifier_grace_period",
    "modifier_hero_movement",
    "qop_passive_modifier",
    "blademaster_death_enable_spells",
    "modifier_arcana_cosmetics",
    "rat_passive_modifier",
    "templar_passive_modifier",
}

_G.PLAYERS_HANDSHAKE_READY = 0
