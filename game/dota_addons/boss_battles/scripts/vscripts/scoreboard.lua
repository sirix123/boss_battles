
-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Custom_Nettables

--Sets a the data for a custom nettable called dps_meter
function UpdateDamageMeter()
    dpsTable = {}
    local heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        heroDps = {}
        heroDps.hero = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID())
        -- heroDps.dps = DpsInLastMinute(hero:GetEntityIndex()) -- todo: trim the float to 2 digits
        heroDps.dps = string.format("%.2f", DpsInLastMinute(hero:GetEntityIndex()) )
        dpsTable[#dpsTable+1] = heroDps
    end
    --CustomNetTables:SetTableValue("dps_meter", "key", dpsTable)
end

function DpsInLastMinute(attackerEntity)
    local currentTime = GameRules:GetGameTime()

    local dmg = 0
    for i,dmgEntry in pairs(_G.DamageTable) do
        if dmgEntry.attackerEntity == attackerEntity then

            local dt = currentTime - dmgEntry.timeOf
            if ( dt < 60 ) then
                dmg = dmg + dmgEntry.dmg
            end
        end 
    end
    return dmg / 60
end

function StoreDamageDone(keys)
    local data = {}
    data["dmg"] = keys.damage
    data["dmgBits"] = keys.damagebits 
    data["victimEntity"] = keys.entindex_killed
    data["attackerEntity"] = keys.entindex_attacker
    data["victimName"] = EntIndexToHScript(keys.entindex_killed):GetUnitName()
    data["attackerName"] = EntIndexToHScript(keys.entindex_attacker):GetUnitName()
    data["timeOf"] = GameRules:GetGameTime()

    --TEST: Not sure this is correct...
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

--TODO: implement this elsewhere...
function GetClassName(unitName)
    --TODO: implement this the current classes...
    return "ice_mage"
end