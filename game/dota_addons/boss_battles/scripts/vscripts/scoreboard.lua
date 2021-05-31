if Scoreboard == nil then
    Scoreboard = class({})
end
----------------------------------------

--[[
--------------------------------------------------------------------------------

SCORE BOARD CORE

--------------------------------------------------------------------------------
]]

function Scoreboard:Init()
    
    -- NOT USED?
    --Listen for getScoreboardDataEvent from JS, then call WebApi:GetAndShowScoreboard()
    --[[CustomGameEventManager:RegisterListener('getScoreboardDataEvent', function(eventSourceIndex, args)
        print("getScoreboardDataEvent caught")
        local heroIndex = args.heroIndex 
        local playerId = args.playerId
        if _G.scoreboardData == nil then
            WebApi:GetScoreboardData(heroIndex) 
        end
    end)]]

    --Listen for showScoreboardUIEvent from JS, then send showScoreboardUIEvent event back to JS
    CustomGameEventManager:RegisterListener('showScoreboardUIEvent', function(eventSourceIndex, args)
        Scoreboard:DisplayScoreBoard( false, PlayerResource:GetPlayer(args.playerId) )

        ------------- OLD WAY ----------------
        --[[
        --BSB player rows:
        local bsbRows = {}
        local heroes = HERO_LIST
        local startTime = self:GetStartTime(_G.DamageTable)
        local endTime = self:GetEndTime(_G.DamageTable)

        for _, hero in pairs(heroes) do
            local unitName = EntIndexToHScript(hero:GetEntityIndex()):GetUnitName()
            local className = GetClassName(unitName)
            local playerName = PlayerResource:GetPlayerName(EntIndexToHScript(hero:GetEntityIndex()):GetPlayerOwnerID())
            local dmgTaken = self:GetDamageTaken(hero:GetEntityIndex())
            local dmgDone = self:GetDamageDone(hero:GetEntityIndex())
            local dps = self:Dps(_G.DamageTable, hero:GetEntityIndex(), startTime, endTime)
            --format to 2 decimals:
            dps = string.format("%.2f",dps)
            dmgDone = string.format("%.2f",dmgDone)
            dmgTaken = string.format("%.2f",dmgTaken)

            bsbRow = {}
            bsbRow.class_name = className
            bsbRow.class_icon = GetClassIcon(className)
            bsbRow.player_name = playerName
            bsbRow.dps = dps


            bsbRow.dmg_done = dmgDone
            bsbRow.dmg_taken = dmgTaken
            bsbRows[#bsbRows+1] = bsbRow
        end

        --BSB header. Boss info
        bsbRows.bossName = "bossName"
        bsbRows.bossDuration = "1:00"
        bsbRows.bossWinLose = "WIN"
            
        local luaPlayer = EntIndexToHScript(args.heroIndex):GetPlayerOwner()
        local convarClient = Convars:GetCommandClient()
        local player = PlayerResource:GetPlayer(args.playerId)

        --CustomGameEventManager:Send_ServerToPlayer( player, "showScoreboardUIEvent", bsbRows )
        --CustomGameEventManager:Send_ServerToPlayer( heroIndex, "showScoreboardUIEvent", bsbRows )
        --CustomGameEventManager:Send_ServerToPlayer( luaPlayer, "showScoreboardUIEvent", bsbRows )
        CustomGameEventManager:Send_ServerToPlayer( player, "showScoreboardUIEvent", bsbRows )
        --CustomGameEventManager:Send_ServerToPlayer( convarClient, "showScoreboardUIEvent", bsbRows )
        ]]
    end)

    --Listen for hideScoreboardUIEvent from JS, then send hideScoreboardUIEvent event back to JS
    CustomGameEventManager:RegisterListener('hideScoreboardUIEvent', function(eventSourceIndex, args)
        --local luaPlayer = EntIndexToHScript(args.heroIndex):GetPlayerOwner()
        --local convarClient = Convars:GetCommandClient()
        local player = PlayerResource:GetPlayer(args.playerId)

        --CustomGameEventManager:Send_ServerToPlayer( luaPlayer, "hideScoreboardUIEvent", {} )
        --CustomGameEventManager:Send_ServerToPlayer( convarClient, "hideScoreboardUIEvent", {} )
        CustomGameEventManager:Send_ServerToPlayer( player, "hideScoreboardUIEvent", {} )
    end)
end

--Expects: _G.DamageTable and playerEntity, startTime, endTime
    --startTime and endTime are used to calculate duration the dmg was done over, 
        --You could add timestamps into _G.DamageTable and remove these params. Would cost memory and cpu
function Scoreboard:Dps(damageTable, attackerEntity, startTime, endTime)
    local timeDuration = endTime - startTime
    local totalDmgDone = self:GetDamageDone(attackerEntity)
    return totalDmgDone / timeDuration
end

function Scoreboard:StoreDamageDone(keys)
    local data = {}

    --PrintTable(keys)
    -- ability["damage"] = ability["damage"] + keys.damage

    --print("EntIndexToHScript(keys.entindex_killed):GetUnitName(): ",EntIndexToHScript(keys.entindex_killed):GetUnitName())

    for _, hero in pairs(HERO_LIST) do
        -- dmg done
        if EntIndexToHScript(keys.entindex_attacker) == hero then
            -- dmg done for the scoreboard
            hero.dmgDoneAttempt = keys.damage + hero.dmgDoneAttempt

            -- dmg done for analytics
            if hero.dmgDetails == nil or #hero.dmgDetails == 0 then
                print("init - dmgDetails table does not contain anything")
                local targets = {}
                targets["target_name"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
                targets["abilities"] = {}

                local ability = {}
                ability["spell_name"] = ""
                ability["damage"] = 0

                ability["spell_name"] = EntIndexToHScript(keys.entindex_inflictor):GetName()
                ability["damage"] = ability["damage"] + keys.damage
                table.insert(targets["abilities"],ability)
                table.insert(hero.dmgDetails,targets)
                break
            else

                self.target_exists = false
                for _, targetData in pairs(hero.dmgDetails) do
                    if targetData.target_name == EntIndexToHScript(keys.entindex_killed):GetUnitName() == true then
                        self.target_exists = true
                    end
                end

                if self.target_exists == true then
                    for _, targetData in pairs(hero.dmgDetails) do
                        if targetData.target_name == EntIndexToHScript(keys.entindex_killed):GetUnitName() == true then

                            self.spell_exists = false
                            for _, abilityData in pairs(targetData.abilities) do
                                if abilityData.spell_name == EntIndexToHScript(keys.entindex_inflictor):GetName() == true then
                                    self.spell_exists = true
                                    abilityData.damage = abilityData.damage + keys.damage
                                end
                            end

                            if self.spell_exists == false then
                                local ability = {}
                                ability["spell_name"] = ""
                                ability["damage"] = 0
                                ability["spell_name"] = EntIndexToHScript(keys.entindex_inflictor):GetName()
                                ability["damage"] = ability["damage"] + keys.damage
                                table.insert(targetData.abilities,ability)
                            end
                            break
                        end
                    end
                end

                if self.target_exists == false then
                    local targets = {}
                    targets["target_name"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
                    targets["abilities"] = {}

                    local ability = {}
                    ability["spell_name"] = ""
                    ability["damage"] = 0

                    ability["spell_name"] = EntIndexToHScript(keys.entindex_inflictor):GetName()
                    ability["damage"] = ability["damage"] + keys.damage
                    table.insert(targets["abilities"],ability)
                    table.insert(hero.dmgDetails,targets)
                end
            end
        end

        -- dmg taken
        if EntIndexToHScript(keys.entindex_killed) == hero then
            -- dmg taken scoreboard
            hero.dmgTakenAttempt = keys.damage + hero.dmgTakenAttempt

            -- dmg taken analytics

            self.inflictor = ""
            if keys.entindex_inflictor == nil then
                self.inflictor = "unknown_ability"
            else
                self.inflictor = EntIndexToHScript(keys.entindex_inflictor):GetName()
            end

            if hero.dmgTakenDetails == nil or #hero.dmgTakenDetails == 0 then
                print("init - dmgTakenDetails table does not contain anything")
                local targets = {}
                targets["target_name"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
                targets["abilities"] = {}

                local ability = {}
                ability["spell_name"] = ""
                ability["damage"] = 0

                ability["spell_name"] = self.inflictor
                ability["damage"] = ability["damage"] + keys.damage
                table.insert(targets["abilities"],ability)
                table.insert(hero.dmgTakenDetails,targets)
                break
            else

                self.target_exists = false
                for _, targetData in pairs(hero.dmgTakenDetails) do
                    if targetData.target_name == EntIndexToHScript(keys.entindex_killed):GetUnitName() == true then
                        self.target_exists = true
                    end
                end

                if self.target_exists == true then
                    for _, targetData in pairs(hero.dmgTakenDetails) do
                        if targetData.target_name == EntIndexToHScript(keys.entindex_killed):GetUnitName() == true then

                            self.spell_exists = false
                            for _, abilityData in pairs(targetData.abilities) do
                                if abilityData.spell_name == self.inflictor == true then
                                    self.spell_exists = true
                                    abilityData.damage = abilityData.damage + keys.damage
                                end
                            end

                            if self.spell_exists == false then
                                local ability = {}
                                ability["spell_name"] = ""
                                ability["damage"] = 0
                                ability["spell_name"] = self.inflictor
                                ability["damage"] = ability["damage"] + keys.damage
                                table.insert(targetData.abilities,ability)
                            end
                            break
                        end
                    end
                end

                if self.target_exists == false then
                    local targets = {}
                    targets["target_name"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
                    targets["abilities"] = {}

                    local ability = {}
                    ability["spell_name"] = ""
                    ability["damage"] = 0

                    ability["spell_name"] = self.inflictor
                    ability["damage"] = ability["damage"] + keys.damage
                    table.insert(targets["abilities"],ability)
                    table.insert(hero.dmgTakenDetails,targets)
                end
            end
        end
    end

    data["victimEntity"] = keys.entindex_killed
    data["attackerEntity"] = keys.entindex_attacker
    data["victimName"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
    data["attackerName"] = EntIndexToHScript(keys.entindex_attacker):GetUnitName()
    data["inflictorName"] = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor):GetName()
    data["dmg"] = keys.damage
    data["dmgBits"] = keys.damagebits 
    data["timeOf"] = GameRules:GetGameTime()

    table.insert(_G.DamageTable, data)

    --NET TABLES EXAMPLE:
    --Stopped using net tables as I don't need to post this event each time the dmgDone is updated, just keep track of it
    --print("setting CustomNetTables dmg_done")
    --CustomNetTables:SetTableValue("dmg_done", tostring(entindex_attacker), _G.DamageTotalsTable)
end


function Scoreboard:GetDamageDone(attackerEntity)
    local sum = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.attackerEntity == attackerEntity then
            sum = sum + dmgEntry.dmg
        end 
    end
    return sum
end

function Scoreboard:GetDamageDoneByEntity(attackerEntity)
    return self:GetDamageDone(attackerEntity)
end


function Scoreboard:GetDamageTaken(victimEntity)
    local sum = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.victimEntity == victimEntity  then
            sum = sum + dmgEntry.dmg
        end 
    end
    return sum
end

function Scoreboard:GetDamageTakenByEntity(victimEntity)
    return self:GetDamageTaken(victimEntity)
end

function Scoreboard:DisplayScoreBoard( bDisplayForAllPlayers, player )

    -- get the attempt data from session manager
    local data = SessionManager:GetAttemptData()

    --local data = SessionManager:GetDummyAttemptData()

    if bDisplayForAllPlayers == true then
        CustomGameEventManager:Send_ServerToAllClients( "display_scoreboard", data )
    elseif bDisplayForAllPlayers == false then
        CustomGameEventManager:Send_ServerToPlayer( player, "display_scoreboard", data )
    end

end

--[[
--------------------------------------------------------------------------------

USEFUL FUNCTIONS FOR DPS METER

TODO MOVE DPS METER TOANOTHER FILE

--------------------------------------------------------------------------------
]]
--Loops over table to find the smallest/earliest timeOf entry
function Scoreboard:FindEarliestEntryInTable(tbl)
    --find earliest entry in table:    
    local earliestTime = tbl[1].timeOf
    for index, row in pairs(tbl) do
        if row[index].timeOf < earliestTime then
            earliestTime = row[index].timeOf
        end
    end
    return earliestTime
end

function Scoreboard:GetStartTime(damageTable)
    --This is safe to do because damageTable is filled up over time, the first entry is the earliest.
    if damageTable ~= nil and #damageTable > 0 then
        return damageTable[1].timeOf
    else 
        return GameRules:GetGameTime()
    end
end

function Scoreboard:GetEndTime(damageTable)
--This is safe to do because damageTable is filled up over time, the last entry is the latest. 
    if damageTable ~= nil and #damageTable > 0 then
        return damageTable[#damageTable].timeOf
    else 
        return GameRules:GetGameTime()
    end
end

function Scoreboard:UpdateDamageMeter()
    local startTime = self:GetStartTime(_G.DamageTable)
    local endTime = self:GetEndTime(_G.DamageTable)

    dpsTable = {}
    local heroes = HERO_LIST--HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        heroDps = {}
        heroDps.hero = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID())
        -- heroDps.dps = DpsInLastMinute(hero:GetEntityIndex()) -- todo: trim the float to 2 digits

        heroDps.dps = string.format("%.2f", self:Dps(_G.DamageTable, hero:GetEntityIndex(), startTime, endTime))
        dpsTable[#dpsTable+1] = heroDps
    end
    CustomNetTables:SetTableValue("dps_meter", "key", dpsTable)
end


--UNTESTED
function Scoreboard:GetDamageTableBetweenTime(startTime, endTime, damageTable)
    --loop over table, and build a new table between dmg rain
        local results = {}
        for i, dmgEntry in pairs(damageTable) do
            --TODO: figure out how to check if between time...
            if dmgEntry.timeOf > startTime and dmgEntry.timeOf < endTime then
                results[#results+1] = dmgEntry
            end
        end
        return results
    end
    
    --UNTESTED
    function Scoreboard:GetDamageDoneByInflictor(inflictorName)
        local sum = 0
        for i,dmgEntry in pairs(_G.DamageTable) do
            if dmgEntry.inflictorName == inflictorName then
                sum = sum + dmgEntry.dmg
            end 
        end
        return sum
    end
    
    --UNTESTED
    function Scoreboard:GetDamageDoneByInflictorToTarget(inflictorName, victimEntity)
        local sum = 0
        for i,dmgEntry in pairs(_G.DamageTable) do
            if dmgEntry.inflictorName == inflictorName and dmgEntry.victimEntity == victimEntity then
                sum = sum + dmgEntry.dmg
            end 
        end
        return sum
    end
    
    function Scoreboard:GetDamageDoneToTargetByInflictor(victimEntity, inflictorName)
        return self:GetDamageDoneByInflictorToTarget(inflictorName, victimEntity)
    end