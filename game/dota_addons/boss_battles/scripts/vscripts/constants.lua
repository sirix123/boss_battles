


_G.BOSS_BATTLES_PLAYER_LIVES = 3

_G.BOSS_BATTLES_INTERMISSION_SPAWN_LOCATION = Vector(-10757, -9796, 256)

_G.BOSS_BATTLES_ENCOUNTER_COUNTER = 2 -- inermission is encounter 1

_G.BOSS_BATTLES_RESPAWN_TIME = 5

_G.TotalDamageDone = {}
_G.DamageTable = {}

-- any unit in this table will not be hit by projectiles (if using barebones proj lib)
_G.tUNIT_TABLE =
{
    "npc_dota_techies_land_mine",
    "npc_shadow",
    "npc_dota_gyrocopter_homing_missile",
}

_G.UNQIUE_INT = 0

_G.PICKING_DONE = false

_G.HERO_LIST = {}

_G.STORY_MODE = true
_G.NORMAL_MODE = false
_G.HARD_MODE = false
_G.DEBUG_MODE = false

-- set before a release
_G.bTESTING_MODE = true
_G.nRELEASE_NUMBER = 0
