
-- handles all boss fights here and intermission

-- go get the raid table file
raid_tables = require('bossfights/raid_init_tables')

-- find all heroes, move them to an area
function GameMode:MoveHeroesToArea(arena)
    
    DebugPrint("moving players to ", arena)

    local spawners = Entities:FindByName(nil, arena):GetAbsOrigin()
    local heroes = HeroList:GetAllHeroes()

    for _,hero in pairs(heroes) do
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
function GameMode:SpawnBoss(boss, location)
    print("GameMode: SpawnBoss")
    local bossSpawnLocation = Entities:FindByName(nil, location):GetAbsOrigin()

    CreateUnitByName("npc_dota_hero_shredder", bossSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --CreateUnitByName("npc_dota_hero_rubick", Vector(200, 300, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    --CreateUnitByName("npc_dota_hero_viper", Vector(600, 300, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    --CreateUnitByName("npc_dota_hero_riki", Vector(800, 300, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    --CreateUnitByName("npc_dota_hero_rubick", bossSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    

end

-- Intermission handler 
function GameMode:IntermissionHandler()
    -- stay in intermission arena until players are ready
        -- checks if players have touched the ready button (could be UI or on the floor of the game)
        -- function here
            -- if theyre ready send to next boss
end

function GameMode:StartRaid()

    --[[
            Intermission area  

    ]]--


    --[[
            Beastmaster  

    ]]--
    --print("GameMode: StartRaid")
    --GameMode:MoveHeroesToArea(raid_tables.gyrocopter.arena)
    --GameMode:SpawnBoss(raid_tables.gyrocopter.bossNPC, raid_tables.beastmaster.spawnLocation)

    --GameMode:MoveHeroesToArea(raid_tables.beastmaster.arena)
    --GameMode:SpawnBoss(raid_tables.beastmaster.bossNPC, raid_tables.beastmaster.spawnLocation)

    --[[
            Timber  

    ]]--

    GameMode:MoveHeroesToArea(raid_tables.timber.arena)
    GameMode:SpawnBoss(raid_tables.timber.bossNPC, raid_tables.timber.spawnLocation)

    --[[
            Clock  

    ]]--


    --[[
            Gyro  
        GameMode:MoveHeroesToArea(raid_tables.beastmaster.arena)
        GameMode:SpawnBoss(raid_tables.beastmaster.bossNPC, raid_tables.beastmaster.spawnLocation)
    ]]--

    --[[
            Tinker  

    ]]--

end
