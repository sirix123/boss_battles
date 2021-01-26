if SessionManager == nil then
    SessionManager = class({})
end
----------------------------------------

-- create a table
function SessionManager:Init()
    self.attempt_tracker = 0
    self.session_data = {} -- made up of attempt data and...?

    -- insert some stuff into the session ata
    self.session_data["releaseNumber"] = nRELEASE_NUMBER
    self.session_data["timeStamp"] = GetSystemDate() .. " " .. GetSystemTime()
    if IsInToolsMode() == true then
        self.session_data["testingMode"] = true
    else
        self.session_data["testingMode"] = bTESTING_MODE
    end

    if STORY_MODE == true then
        self.session_data["mode"] = "storyMode"
    elseif NORMAL_MODE == true then
        self.session_data["mode"] = "normalMode"
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

    self.player_data = {} -- made up of players,
    self.boss_data = {} -- made up of the boss, contains boss name, duration of attempt, if it was killed
    self.attempt_data = {} -- init an attempt table

    -- individual player data
    for _, hero in pairs(HERO_LIST) do
        --self.player_data[hero.playerId] = hero
        self.player_data[hero.playerId] = {}
        self.player_data[hero.playerId].playerId = tonumber(hero.playerId)
        self.player_data[hero.playerId].steamId = tostring(hero.steamId)
        self.player_data[hero.playerId].className = tostring(hero.class_name)
        self.player_data[hero.playerId].playerName = hero.playerName
        self.player_data[hero.playerId].playerLives = hero.playerLives
        self.player_data[hero.playerId].heroName = hero.hero_name
        self.player_data[hero.playerId].dmgDoneAttempt = hero.dmgDoneAttempt
    end

    -- add all the boss data to the boss table
    self.boss_data["duration"] = self.duration
    self.boss_data["bossKilled"] = bBossKilled
    self.boss_data["bossName"] = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].name
    self.boss_data["attemptNumber"] = self.attempt_tracker

    -- add all the data to the attempt table
    self.attempt_data["playerTable"] = self.player_data
    self.attempt_data["bossTable"] = self.boss_data

    -- add attempt data to the session data
    self.session_data[self.attempt_tracker] = self.attempt_data

    --PrintTable(self.session_data)
    --print(dump(self.session_data))

end
----------------------------------------

-- send attempt data (scoreboard)
function SessionManager:GetAttemptData()
    return self.attempt_data
end
----------------------------------------

-- send session data (leaderboard/databse)
function SessionManager:SendSessionData()
    print(dump(self.session_data))
    WebApi:SaveSessionData( self.session_data )
end
----------------------------------------