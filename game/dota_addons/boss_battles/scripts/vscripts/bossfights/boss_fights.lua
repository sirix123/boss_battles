
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
    local bossSpawnLocation = Entities:FindByName(nil, location):GetAbsOrigin()

    CreateUnitByName(boss, bossSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
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

-- need a 'raid handler' reads a table defined in a file that determines the bossfights that 
-- make up a raid. Raid 'table' needs to have a spawner for each raid and a boss it spawns.
-- this also needs to call the move to intermission between each boss and the 'startbossfight'
-- function. 
function GameMode:StartRaid()
    -- flow..
    -- check if players are ready to start raid
    -- look at table and find the first bossfight
    -- pull data from the first bossifght 
    -- boss npc to spawn, arena, etc
    -- move players to boss arena
    -- listen event somewheer else... (if players dead do x, if boss dead do y)
    -- move to intermission
    -- find next boss in table and repeat

    -- move to intermission arena
    --GameMode:MoveHeroesToArea(raid_tables.intermission.arena)
    -- wait until players are ready to leave
    GameMode:IntermissionHandler()

    -- move players to boss 1 arena
    GameMode:MoveHeroesToArea(raid_tables.beastmaster.arena)
    -- freezer players
    -- FUNCTION
    -- spawn boss
    GameMode:SpawnBoss(raid_tables.beastmaster.bossNPC, raid_tables.beastmaster.spawnLocation)
    -- freeze boss
    -- FUNCTION
    -- display countodwn notificaiton etc...
    -- FUNCTION
    -- when notification ends unfreeeze boss and players

    -- listeners will exist to constantly check if something happens but here we explicting
    -- FUNCTION ARE PLAYERS ALIVE OR BOSS DEAD? 
    -- i think we need to go into a thinker function here.... FightThinker?
end
