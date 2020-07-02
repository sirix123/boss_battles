
-- handles all boss fights here and intermission

-- go get the raid table file
raid_tables = require('managers/raid_init_tables')

-- find all heroes, move them to an area
function GameMode:MoveHeroesToArea(arena)
    
    DebugPrint("moving players to ", arena)

    local spawners = Entities:FindByName(nil, arena):GetAbsOrigin()
    local heroes = HeroList:GetAllHeroes()

    for _,hero in pairs(heroes) do
        FindClearSpaceForUnit(hero, spawners, true)
        --FindClearSpaceForUnit(hero, Vector(13889, 14328, 0), true)
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
function GameMode:SpawnBoss(tBoss, location)
    print("GameMode: SpawnBoss")
    local bossSpawnLocation = Entities:FindByName(nil, location):GetAbsOrigin()
    local testspawn = Entities:FindByName(nil, raid_tables.beastmaster.spawnLocation):GetAbsOrigin()

    --for _, boss in pairs(tBoss) do
        --CreateUnitByName(boss, bossSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --end

    -- 3 minions
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(13665,15213,0), true, nil, nil, DOTA_TEAM_BADGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(13665,15213,0), true, nil, nil, DOTA_TEAM_BADGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(13665,15213,0), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- 1 min 1 boss
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(14394,14884,0), true, nil, nil, DOTA_TEAM_BADGUYS)
    CreateUnitByName("npc_dota_creature_dummy_target_minion", Vector(14394,14884,0), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- 1 boss
    CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(13411,14682,0), true, nil, nil, DOTA_TEAM_BADGUYS)


    --CreateUnitByName(boss, bossSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_dota_hero_rubick", bossSpawnLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    --CreateUnitByName("npc_dota_hero_viper", Vector(9821,14288,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    CreateUnitByName("npc_dota_hero_riki", Vector(14007,14445,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
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

    --[[
            Intermission area ADMIN area for NOW

    ]]--
    GameMode:MoveHeroesToArea(raid_tables.beastmaster.arena)
    GameMode:SpawnBoss(raid_tables.intermission.bosses, raid_tables.beastmaster.spawnLocation) -- hardcoded target dummy spawning !!!

    --[[
            Beastmaster

    ]]--
    --GameMode:MoveHeroesToArea(raid_tables.beastmaster.arena)
    --GameMode:SpawnBoss(raid_tables.beastmaster.bossNPC, raid_tables.beastmaster.spawnLocation)

    --[[
            Timber

    ]]--
    --GameMode:MoveHeroesToArea(raid_tables.timber.arena)
    --GameMode:SpawnBoss(raid_tables.timber.bossNPC, raid_tables.timber.spawnLocation)

    --[[
            Clock

    ]]--


    --GameMode:MoveHeroesToArea(raid_tables.gyrocopter.arena)
    --GameMode:SpawnBoss(raid_tables.gyrocopter.bossNPC, raid_tables.gyrocopter.spawnLocation)

    --[[
            Tinker

    ]]--

end
