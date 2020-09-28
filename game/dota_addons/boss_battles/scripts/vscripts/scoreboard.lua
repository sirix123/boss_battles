
--Loops over table to find the smallest/earliest timeOf entry
function FindEarliestEntryInTable(tbl)
    --find earliest entry in table:    
    local earliestTime = tbl[1].timeOf
    for index, row in pairs(tbl) do
        if row[index].timeOf < earliestTime then
            earliestTime = row[index].timeOf
        end
    end
    return earliestTime
end

function GetStartTime(damageTable)
    --This is safe to do because damageTable is filled up over time, the first entry is the earliest.
    return damageTable[1].timeOf
end

function GetEndTime(damageTable)
--This is safe to do because damageTable is filled up over time, the last entry is the latest. 
    return damageTable[#damageTable].timeOf
end

function UpdateDamageMeter()
    local startTime = GetStartTime(_G.DamageTable)
    local endTime = GetEndTime(_G.DamageTable)

    dpsTable = {}
    local heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        heroDps = {}
        heroDps.hero = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID())
        -- heroDps.dps = DpsInLastMinute(hero:GetEntityIndex()) -- todo: trim the float to 2 digits

        heroDps.dps = string.format("%.2f", Dps(_G.DamageTable, hero:GetEntityIndex(), startTime, endTime))
        dpsTable[#dpsTable+1] = heroDps
    end
    CustomNetTables:SetTableValue("dps_meter", "key", dpsTable)
end

--Expects: _G.DamageTable and playerEntity, startTime, endTime
    --startTime and endTime are used to calculate duration the dmg was done over, 
        --You could add timestamps into _G.DamageTable and remove these params. Would cost memory and cpu 
function Dps(damageTable, attackerEntity, startTime, endTime)
    local timeDuration = endTime - startTime
    local totalDmgDone = GetDamageDone(attackerEntity)
    return totalDmgDone / timeDuration
end

function StoreDamageDone(keys)
    local data = {}
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

function GetDamageDone(attackerEntity)
    local sum = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.attackerEntity == attackerEntity then
            sum = sum + dmgEntry.dmg
        end 
    end
    return sum
end

function GetDamageTaken(victimEntity)
    local sum = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.victimEntity == victimEntity  then
            sum = sum + dmgEntry.dmg
        end 
    end
    return sum
end

