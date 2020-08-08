
-- handles all boss fights here and intermission

-- go get the raid table file
raid_tables = require('managers/raid_init_tables')

-- find all heroes, move them to an area
function GameMode:MoveHeroesToArea(arena)
    
    DebugPrint("moving players to ", arena)

    local spawners = Entities:FindByName(nil, arena):GetAbsOrigin()
    local heroes = HeroList:GetAllHeroes()

    for _,hero in pairs(heroes) do
        hero:SetMana(0) ---- STEFANNNNNNN
        FindClearSpaceForUnit(hero, spawners, true)
        hero:SetAngles(0, RandomFloat(0,359), 0)
        hero.spawners = spawners
        Timers:CreateTimer(0.2, function()
        	GameMode:CenterCameraOnHero(hero)
        end)
    end

end

-- move camera over player hero
function GameMode:CenterCameraOnHero(hero)
	local playerID = hero:GetPlayerID()
    PlayerResource:SetCameraTarget(playerID, hero)

	Timers:CreateTimer(0.1, function()
		PlayerResource:SetCameraTarget(playerID, nil)
	end)
end

-- handles spawning the boss, pass boss from table and a location
function GameMode:SpawnBoss(tBoss, tLocation)
    --print("GameMode: SpawnBoss")
    local vEntityLocation = ""

    --CreateUnitByName("npc_gyrocopter", "captainspawn", true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_gyrocopter",  Vector(14007,14445,0), true, nil, nil, DOTA_TEAM_BADGUYS)

    for _, boss in pairs(tBoss) do
        for _, location in pairs(tLocation) do

            if location == "beastmaster_boss_spawn" and boss == "npc_dota_creature_dummy_target_boss" then

                --vEntityLocation = Entities:FindByName(nil, location):GetAbsOrigin()
                --CreateUnitByName(boss, vEntityLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    
            end

            if location == "clock_spawn" and boss == "npc_clock" then

                vEntityLocation = Entities:FindByName(nil, location):GetAbsOrigin()
                CreateUnitByName(boss, vEntityLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                CreateUnitByName("furnace", Vector(7414,7809,256), true, nil, nil, DOTA_TEAM_BADGUYS)
                CreateUnitByName("furnace", Vector(9013,7809,256), true, nil, nil, DOTA_TEAM_BADGUYS)
                CreateUnitByName("furnace", Vector(9013,6455,256), true, nil, nil, DOTA_TEAM_BADGUYS)
                CreateUnitByName("furnace", Vector(7414,6455,256), true, nil, nil, DOTA_TEAM_BADGUYS)
                --CreateUnitByName("npc_assistant", vEntityLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                --CreateUnitByName("npc_dota_hero_rubick", Vector(8112,6733,256), true, nil, nil, DOTA_TEAM_GOODGUYS)
                --CreateUnitByName("electric_turret", Vector(8593,7352,256), true, nil, nil, DOTA_TEAM_GOODGUYS)
                --CreateUnitByName("npc_dota_creature_gnoll_assassin", Vector(7605,7305,256), true, nil, nil, DOTA_TEAM_GOODGUYS)

            end

            --if location == "LOCATION_1" then

                --vEntityLocation = Entities:FindByName(nil, location):GetAbsOrigin()
                --CreateUnitByName(boss, vEntityLocation, true, nil, nil, DOTA_TEAM_BADGUYS)

            --end

            --vEntityLocation = Entities:FindByName(nil, location):GetAbsOrigin()
            --CreateUnitByName(boss, vEntityLocation, true, nil, nil, DOTA_TEAM_BADGUYS)

        end
    end

    -- 3 minions
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(13665,15213,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(13665,15213,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(13665,15213,0), true, nil, nil, DOTA_TEAM_GOODGUYS)

    -- 1 min 1 boss
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(14394,14884,0), true, nil, nil, DOTA_TEAM_BADGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(14394,14884,0), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- 1 boss
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(13411,14682,0), true, nil, nil, DOTA_TEAM_GOODGUYS)


    --CreateUnitByName(boss, bossSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_dota_hero_rubick", bossSpawnLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    --CreateUnitByName("npc_dota_hero_viper", Vector(9821,14288,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    CreateUnitByName("npc_dota_creature_gnoll_assassin", Vector(14007,14445,0), true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_dota_creature_gnoll_assassin", testspawn, true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_stun_droid", testspawn, true, nil, nil, DOTA_TEAM_BADGUYS)
end

-- Intermission handler 
function GameMode:IntermissionHandler()
    -- stay in intermission arena until players are ready
        -- checks if players have touched the ready button (could be UI or on the floor of the game)
        -- function here
            -- if theyre ready send to next boss
end

function GameMode:StartRaid()
    print("GameMode: StartRaid()")

    -- initalise heroes

    --[[
            Intermission area ADMIN area for NOW

    ]]--
    --GameMode:MoveHeroesToArea(raid_tables.beastmaster.arena)
    --GameMode:SpawnBoss(raid_tables.intermission.bosses, raid_tables.beastmaster.spawnLocation)

    --[[
            Clock

    ]]--
    GameMode:MoveHeroesToArea(raid_tables.clock.arena)
    GameMode:SpawnBoss(raid_tables.clock.bosses, raid_tables.clock.spawnLocation)

    --[[
            Timber

    ]]--
    --GameMode:MoveHeroesToArea(raid_tables.timber.arena)
    --GameMode:SpawnBoss(raid_tables.timber.bosses, raid_tables.timber.spawnLocation)

    --[[
            Gyro
    ]]--
    --GameMode:MoveHeroesToArea(raid_tables.gyrocopter.arena)
    --GameMode:SpawnBoss(raid_tables.gyrocopter.bosses, raid_tables.gyrocopter.spawnLocation)

    --[[
            Tinker

    ]]--

end
