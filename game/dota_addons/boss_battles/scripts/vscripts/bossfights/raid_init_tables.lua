require('bossfights/beastmaster')

-- template
-- what else do we need to define for the boss fight?

tRAID_INIT_TABLE = {
	-- snowball_game = {
	-- 	name = "Snowball",
	-- 	description = "",
	-- 	hero = {
	-- 		heroName = "npc_dota_hero_tusk",
	-- 		health = 100,
	-- 		mana = 0,
	-- 		abilities = {
	-- 			"snowball_lua",
	-- 		},			
	-- 	},
	-- 	arena = "snow_medium",
	-- 	game = SnowballGame:new{duration=-1},
	-- },

	intermission = {
		name = "Intermission",
		description = "MANY ANIMALS",
		arena = "PlayerIntermissionSpawn",
		spawnLocation = "beastmaster_boss_spawn",
		bossNPC = "npc_beastmaster",
	},

	beastmaster = {
		name = "Beastmaster",
		description = "MANY ANIMALS",
		arena = "beastmasterspawn",
		spawnLocation = "beastmaster_boss_spawn",
		bossNPC = "npc_beastmaster",
	},

	timber = {
		name = "Timber",
		description = "MANY ANIMALS",
		arena = "timberPlayerSpawn",
		spawnLocation = "timberBossSpawn",
		bossNPC = "npc_viper",
	},

	captain = {
		name = "Captain",
		description = "MANY ANIMALS",
		arena = "captainspawn",
		spawnLocation = "beastmaster_boss_spawn",
		bossNPC = "npc_viper",
	},

	boss4 = {
		name = "Boss4",
		description = "MANY ANIMALS",
		arena = "boss4spawn",
		spawnLocation = "beastmaster_boss_spawn",
		bossNPC = "npc_viper",
	},

}

return tRAID_INIT_TABLE