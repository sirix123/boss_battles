
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
		spawnLocation =
		{
			"beastmaster_boss_spawn",
		},
		bosses =
		{
			--"npc_dota_creature_dummy_target_minion",
			"npc_dota_creature_dummy_target_boss",
		},
	},

	beastmaster = {
		name = "Beastmaster",
		description = "MANY ANIMALS",
		arena = "beastmasterspawn",
		spawnLocation = 
		{
			"beastmaster_boss_spawn",
		},
		bosses =
		{
			"npc_beastmaster",
		},
	},

	timber = {
		name = "Timber",
		description = "MANY ANIMALS",
		arena = "timberPlayerSpawn",
		spawnLocation =
		{
			"timberBossSpawn",
		},
		bosses =
		{
			"npc_viper",
		},
	},

	captain = {
		name = "Captain",
		description = "MANY ANIMALS",
		arena = "captainspawn",
		spawnLocation =
		{
			"beastmaster_boss_spawn",
		},
		bosses =
		{
			"npc_dota_hero_riki",
		},
	},

	boss4 = {
		name = "Boss4",
		description = "MANY ANIMALS",
		arena = "boss4spawn",
		spawnLocation =
		{
			"beastmaster_boss_spawn",
		},
		bosses = 
		{
			"npc_viper",
		},
	},

	gyrocopter = {
		name = "Gyrocopter",
		description = "gyrocopter boss description",
		arena = "captainspawn",
		spawnLocation =
		{
			"captainspawn",
		},
		bosses =
		{
			"npc_gyrocopter",
		},
	},

}

return tRAID_INIT_TABLE