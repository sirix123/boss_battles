
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

	[1] = {
		name = "Intermission",
		description = "Heroes please, take a seat by the hearth and relax.",
		arena = "intermission_player_spawn",
		spawnLocation = "something_boss_spawn",
		boss = "npc_dota_creature_dummy_target_boss",
		bossKilled = true,
	},

	[2] = {
		name = "Gyrocopter",
		description = "gyrocopter boss description",
		arena = "gyro_player_spawn",
		spawnLocation = "gyro_boss_spawn",
		boss = "npc_gyrocopter",
		bossKilled = false,
	},

	[3] = {
		name = "Timbersaw",
		description = "MANY ANIMALS",
		arena = "timber_player_spawn",
		spawnLocation = "timber_boss_spawn",
		boss = "npc_timber",
		bossKilled = false,
	},

	[4] = {
		name = "Beastmaster",
		description = "MANY ANIMALS",
		arena = "beastmaster_playerspawn",
		spawnLocation = "beastmaster_bossspawn",
		boss ="npc_beastmaster",
		bossKilled = false,
	},

	[5] = {
		name = "Techies",
		description = "MANY ANIMALS",
		arena = "techies_player_spawn",
		spawnLocation = "techies_boss_spawn",
		boss = "npc_techies",
		bossKilled = false,
	},

	[6] = {
		name = "Clockwerk",
		description = "MANY ANIMALS",
		arena = "clock_player_spawn",
		spawnLocation = "clock_boss_spawn",
		boss = "npc_clock",
		bossKilled = false,
	},

	[7] = {
		name = "Tinker",
		description = "gyrocopter boss description",
		arena = "tinker_player_spawn",
		spawnLocation = "tinker_boss_spawn",
		boss = "npc_tinker",
		bossKilled = false,
	},

}

return tRAID_INIT_TABLE