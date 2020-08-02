
furnace_driod_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end

    -- find furnaces on spawn
    FindFurnaces()

    thisEntity:SetContextThink( "FurnaceDroidThink", FurnaceDroidThink, 0.5 )
end
--------------------------------------------------------------------------------

function FurnaceDroidThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end


    -- if no electric turret, something deadly needs to happen to players

    local units = FindUnits()
    local electricTurrets = {}
    local step = 0

    -- if electric turret on the map find one
    -- run towards electric turret (sit there until you get the buff)
    -- once droid has buff rolls a dice and run towards boss or furnace

    -- STEP 1 --
    -- code below handles droid moving to electric turret
    -- if units table is not empty
    if step ~= 1 then
        step = 1
        if #units ~= 0 and units ~= nil then
            for _, unit in pairs(units) do
                -- find the electric turrets
                if unit:GetUnitName() == "electric_turret" then
                    table.insert(electricTurrets, unit:GetAbsOrigin())
                    -- if we find electric turrets
                    if electricTurrets ~= nil and #electricTurrets ~= 0 then
                        print('doi we really run this alot?')
                        thisEntity:MoveToPosition(electricTurrets[RandomInt(1,#electricTurrets)])
                    end
                end
            end
        end
    end

    -- STEP 2 --
    -- get buff from electric turret

    -- STEP 3 --
    -- roll dice go to furnace or boss
    -- boss and furnace code handle killing furnace droid

	return 0.5
end

--------------------------------------------------------------------------------

function FindUnits()
    local units = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),	-- int, your team number
        thisEntity:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        FIND_CLOSEST,	-- int, order filter
        false	-- bool, can grow cache
    )

    return units
end
--------------------------------------------------------------------------------

function FindFurnaces()
    -- find all 4 furances
    local furances = 4
    local tFurnaceLocations = {}
    for i = 1, furances, 1 do
        local vFurnaceLoc = Entities:FindByName(nil, "furnace_" .. i):GetAbsOrigin()
        table.insert(tFurnaceLocations, vFurnaceLoc )
    end

    return tFurnaceLocations
end
--------------------------------------------------------------------------------
