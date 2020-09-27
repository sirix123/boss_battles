
furnace_droid_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end

    -- find furnaces on spawn
    thisEntity.step = 1
    thisEntity.radius = FIND_UNITS_EVERYWHERE

    thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

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

    --print("STEP ",thisEntity.step)
    -- if no electric turret, something deadly needs to happen to players

    local units = FindUnits()
    local electricTurrets = {}

    -- STEP 1 --
    if thisEntity.step == 1 then
        if #units ~= 0 and units ~= nil then
            for _, unit in pairs(units) do
                -- find the electric turrets
                if unit:GetUnitName() == "electric_turret" then
                    table.insert(electricTurrets, unit:GetAbsOrigin())
                    -- if we find electric turrets
                    if electricTurrets ~= nil and #electricTurrets ~= 0 then
                        thisEntity.step = 2
                        local randomTurretIndex = RandomInt(1,#electricTurrets)
                        thisEntity:MoveToPosition(electricTurrets[randomTurretIndex])
                        -- calc time to get pos and add little buffer
                        local distance = ( thisEntity:GetAbsOrigin() - electricTurrets[randomTurretIndex] ):Length2D()
                        local velocity = thisEntity:GetBaseMoveSpeed()
                        local time = distance / velocity
                        return time + 4
                    end
                end
            end
        end
    end

    -- STEP 2 --
    if thisEntity.step == 2 then
        local randomInt = RandomInt(1,2)
        if randomInt == 1 then
            if #units ~= 0 and units ~= nil then
                for _, unit in pairs(units) do
                    if unit:GetUnitName() == "npc_clock" then
                        thisEntity:MoveToPosition(unit:GetAbsOrigin()) -- external in electric modifier code, when droid gets close to boss it explodes
                        thisEntity.step = 3
                        --thisEntity.radius = 200 -- set find units radius to something smaller to find clock when close, then die
                        thisEntity.radius = FIND_UNITS_EVERYWHERE

                        -- calc time to get pos and add little buffer
                        local distance = ( thisEntity:GetAbsOrigin() - unit:GetAbsOrigin() ):Length2D()
                        local velocity = thisEntity:GetBaseMoveSpeed()
                        local time = distance / velocity

                        return time + 2
                    end
                end
            end
        elseif randomInt == 2 then
            if #units ~= 0 and units ~= nil then
                for _, unit in pairs(units) do
                    if unit:GetUnitName() == "furnace" then
                        thisEntity:MoveToPosition(unit:GetAbsOrigin()) -- in furnace AI we kill the droid
                        thisEntity.step = nil
                        return 0.5
                    end
                end
            end
        end
    end

    -- STEP 3 --
    if thisEntity.step == 3 then
        thisEntity.step = 1 -- after goign to clock they go get more mana and do more things
        --[[if #units ~= 0 and units ~= nil then
            for _, unit in pairs(units) do
                if unit:GetUnitName() == "npc_clock" then
                    PlayEffects()
                    thisEntity:ForceKill(false)
                    return 0.5
                end
            end
        end]]
    end

	return 0.5
end

--------------------------------------------------------------------------------

function FindUnits()
    local units = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),	-- int, your team number
        thisEntity:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        thisEntity.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
    )

    return units
end
--------------------------------------------------------------------------------

function PlayEffects()
    local particleName = "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient_fire_explode.vpcf"
    thisEntity.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
    ParticleManager:SetParticleControl( thisEntity.pfx, 0, Vector( 0, 0, 0 ))
end
--------------------------------------------------------------------------------
