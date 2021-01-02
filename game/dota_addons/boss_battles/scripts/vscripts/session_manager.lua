if SessionManager == nil then
    SessionManager = class({})
end
----------------------------------------

-- create a table
function SessionManager:Init()
    self.attempt_tracker = 0
    self.session_data = {} -- made up of attempt data and...?
    self.start_time = 0
    self.end_time = 0
end
----------------------------------------

-- start recording an attempt
function SessionManager:RecordAttempt()

    self.attempt_tracker = self.attempt_tracker + 1
    print("self.attempt_tracker ",self.attempt_tracker)
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
        self.player_data[hero.playerId] = hero
    end

    -- add all the boss data to the boss table
    self.boss_data["duration"] = self.duration
    self.boss_data["bossKilled"] = bBossKilled
    self.boss_data["bossName"] = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].name

    -- add all the data to the attempt table
    self.attempt_data["playerTable"] = self.player_data
    self.attempt_data["bossTable"] = self.boss_data

    -- add attempt data to the session data
    self.session_data[self.attempt_tracker] = self.attempt_data

    PrintTable(self.session_data)

end
----------------------------------------

-- send attempt data
function SessionManager:SendAttemptData()


end
----------------------------------------

-- send session data
function SessionManager:SendSessionData()


end
----------------------------------------