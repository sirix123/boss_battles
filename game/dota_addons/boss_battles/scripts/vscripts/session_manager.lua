if SessionManager == nil then
    SessionManager = class({})
end
----------------------------------------

-- create a table
function SessionManager:Init()

    self.attempt_tracker = 0
    self.session_data = {} -- made up of attempt data and...?
    self.boss_data = {} -- made up of boss attemps
    self.player_data = {} -- made up of players,

    -- insert some stuff into the session ata
    self.session_data["guid"] = GenerateGUID()
    self.session_data["releaseNumber"] = sRELEASE_NUMBER
    self.session_data["timeStampStart"] = GetSystemDate() .. " " .. GetSystemTime()
    self.session_data["mapName"] = GetMapName()
    if IsInToolsMode() == true then
        self.session_data["testingMode"] = true
    else
        self.session_data["testingMode"] = false
    end

    self.start_time = 0
    self.end_time = 0
end
----------------------------------------

-- start recording an attempt
function SessionManager:RecordAttempt()

    self.attempt_tracker = nATTEMPT_TRACKER
    --print("self.attempt_tracker ",self.attempt_tracker)
    self.start_time = GameRules:GetGameTime() -- start timer (attempt duration)

end
----------------------------------------

-- stop recording an attempt
function SessionManager:StopRecordingAttempt( bBossKilled )

    print("self.attempt_tracker ",self.attempt_tracker)

    -- stop timer, if boss killed add attemptID, bBossKilled, time, player 1-4 (steam IDs), whatever data we want here
    self.end_time = GameRules:GetGameTime()
    self.duration = self.end_time - self.start_time

    self.boss_attempt = {} -- made up of the boss, contains boss name, duration of attempt, if it was killed
    self.attempt_data = {} -- single attempe data snapshat for ingame scoreboard, collection of boss attemp and player data
    self.player_attempt_data = {} -- just the attempts player data

    -- individual player data
    for _, hero in pairs(HERO_LIST) do
        local player = {}
        player["playerId"] = tonumber(hero.playerId)
        player["steamId"] = tostring(hero.steamId)
        player["className"] = tostring(hero.class_name)
        player["playerName"] = hero.playerName
        player["playerLives"] = hero.playerLives
        player["playerDeaths"] = hero.playerDeaths
        player["heroName"] = hero.hero_name
        player["dmgDoneAttempt"] = hero.dmgDoneAttempt
        player["dmgTakenAttempt"] = hero.dmgTakenAttempt
        table.insert(self.player_attempt_data,player)
    end

    -- add all the boss data to the boss table
    self.boss_attempt["duration"] = self.duration
    self.boss_attempt["bossKilled"] = bBossKilled
    self.boss_attempt["bossName"] = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].name
    self.boss_attempt["attemptNumber"] = self.attempt_tracker
    self.boss_attempt["bossHpPercent"] = nBOSS_HP_ATTEMPT

    self.boss_attempt["damageDoneData"] = {}
    for _, hero in pairs(HERO_LIST) do
        local player = {}
        player["className"] = tostring(hero.class_name)
        player["dmgDetails"] = hero.dmgDetails

        table.insert(self.boss_attempt["damageDoneData"],player)
    end

    self.boss_attempt["damageTakenData"] = {}
    for _, hero in pairs(HERO_LIST) do
        local player = {}
        player["className"] = tostring(hero.class_name)
        player["dmgTakenDetails"] = hero.dmgTakenDetails

        table.insert(self.boss_attempt["damageTakenData"],player)
    end

    self.boss_attempt["deathsData"] = {}
    for _, hero in pairs(HERO_LIST) do
        local player = {}
        player["className"] = tostring(hero.class_name)
        player["deathsDetails"] = hero.deathsDetails

        table.insert(self.boss_attempt["deathsData"],player)
    end

    -- adds the boss attempt to the boss data collection
    table.insert(self.boss_data,self.boss_attempt)
    table.insert(self.boss_data,self.damageDoneData)
    table.insert(self.boss_data,self.damageTakenData)
    table.insert(self.boss_data,self.deathsData)

    -- adds boss data and player data to the session data collection
    self.session_data["boss_data"] = self.boss_data

    -- attempt data,used for the ingame scoreboard, snapshot of last attempt
    self.attempt_data["boss_data"] = self.boss_attempt
    self.attempt_data["player_data"] = self.player_attempt_data

end
----------------------------------------

-- send attempt data (scoreboard)
function SessionManager:GetAttemptData()
    return self.attempt_data
end
----------------------------------------

function SessionManager:GetGameID()
    return self.session_data["guid"]
end
----------------------------------------

-- send session data (leaderboard/databse)
function SessionManager:SendSessionData()

    if SOLO_MODE == true then
        self.session_data["mode"] = "soloMode"
    elseif NORMAL_MODE == true then
        self.session_data["mode"] = "normalMode"
    elseif HARD_MODE == true then
        self.session_data["mode"] = "hardMode"
    end

    -- when we send the session data, happens once...
    -- individual player data
    for _, hero in pairs(HERO_LIST) do
        local player = {}
        player["playerId"] = tonumber(hero.playerId)
        player["steamId"] = tostring(hero.steamId)
        player["className"] = tostring(hero.class_name)
        player["playerName"] = hero.playerName
        player["playerLives"] = hero.playerLives
        player["playerDeaths"] = hero.playerDeaths
        player["heroName"] = hero.hero_name
        table.insert(self.player_data,player)
    end

    self.session_data["player_data"] = self.player_data
    self.session_data["timeStampEnd"] = GetSystemDate() .. " " .. GetSystemTime()

    if bGAME_COMPLETE == false and BOSS_BATTLES_ENCOUNTER_COUNTER ~= 8 then
        self.session_data["sentFrom"] = "gameIncomplete"
    else
        self.session_data["sentFrom"] = "gameComplete"
    end

    --print("sending session data")
    print(dump(json.encode(self.session_data)))

    WebApi:SaveSessionData( self.session_data )
end
----------------------------------------

function SessionManager:GetDummyAttemptData() -- used for scoreboard bug testing

    self.session_data = {}
    self.boss_data = {}
    self.player_data = {}

    self.attempt_data = {}

    self.boss_attempt = {}
    self.attempt_data = {}

    self.player_attempt_data = {}

    local player = {}
    player["playerId"] = "dummyhero1"
    player["steamId"] = "23423412"
    player["className"] = "iceice"
    player["playerName"] = "stefan"
    player["playerLives"] = 3
    player["playerDeaths"] = 1
    player["heroName"] = "stefan iceice"
    player["dmgDoneAttempt"] = 10000
    table.insert(self.player_data,player)
    table.insert(self.player_attempt_data,player)

    player = {}
    player["playerId"] = "dummyhero2"
    player["steamId"] = "23423412"
    player["className"] = "iceice"
    player["playerName"] = "stefan"
    player["playerLives"] = 3
    player["playerDeaths"] = 1
    player["heroName"] = "stefan iceice"
    player["dmgDoneAttempt"] = 154000
    table.insert(self.player_data,player)
    table.insert(self.player_attempt_data,player)

    player = {}
    player["playerId"] = "dummyhero3"
    player["steamId"] = "23423412"
    player["className"] = "iceice"
    player["playerName"] = "stefan"
    player["playerLives"] = 3
    player["playerDeaths"] = 1
    player["heroName"] = "stefan iceice"
    player["dmgDoneAttempt"] = 15400000.4534534
    table.insert(self.player_data,player)
    table.insert(self.player_attempt_data,player)

    player = {}
    player["playerId"] = "dummyhero4"
    player["steamId"] = "23423412"
    player["className"] = "iceice"
    player["playerName"] = "stefan"
    player["playerLives"] = 3
    player["playerDeaths"] = 1
    player["heroName"] = "stefan iceice"
    player["dmgDoneAttempt"] = 1000.4534534
    table.insert(self.player_data,player)
    table.insert(self.player_attempt_data,player)

    -- add all the boss data to the boss table
    self.boss_attempt["duration"] = 10.3
    self.boss_attempt["bossKilled"] = true
    self.boss_attempt["bossName"] = "BEEEEEEAST"
    self.boss_attempt["attemptNumber"] = 3

    -- adds the boss attempt to the boss data collection
    table.insert(self.boss_data,self.boss_attempt)

    -- adds boss data and player data to the session data collection
    self.session_data["boss_data"] = self.boss_data
    self.session_data["player_data"] = self.player_data

    -- attempt data,used for the ingame scoreboard, snapshot of last attempt
    self.attempt_data["boss_data"] = self.boss_attempt
    self.attempt_data["player_data"] = self.player_attempt_data


    return self.attempt_data
end