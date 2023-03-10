techies_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
    --thisEntity:AddNewModifier( nil, nil, "modifier_invisible", { duration = -1 } )
    thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

    CreateUnitByName( "npc_guard", Vector(10126,1776,0), true, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)

    -- spells
    thisEntity.cluster_mine_throw = thisEntity:FindAbilityByName( "cluster_mine_throw" )

    thisEntity.blast_off = thisEntity:FindAbilityByName( "blast_off" )
    thisEntity.blast_off:StartCooldown(20)

    thisEntity.explode_proxy_mines = thisEntity:FindAbilityByName( "explode_proxy_mines" )

    thisEntity.summon_electric_vortex_turret = thisEntity:FindAbilityByName( "summon_electric_vortex_turret" )
    thisEntity.summon_electric_vortex_turret:StartCooldown(60)

    thisEntity.choking_gas = thisEntity:FindAbilityByName( "choking_gas" )
    thisEntity.choking_gas:StartCooldown(30)

    thisEntity.sticky_bomb = thisEntity:FindAbilityByName( "sticky_bomb" )
    thisEntity.sticky_bomb:StartCooldown(30)

    thisEntity.phase = 1
    thisEntity.next_mine_location = true
    thisEntity.tCenterGrid = GridifyMap()

    thisEntity.guardIsDead = false

    thisEntity:SetHullRadius(80)

    thisEntity:SetContextThink( "TechiesThinker", TechiesThinker, 0.5 )

end
--------------------------------------------------------------------------------

function TechiesThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    -- reset grid / phase / prepare for another mine phase
    if #thisEntity.tCenterGrid == 0 then
        thisEntity.tCenterGrid = GridifyMap()
    end

    --phase state check (check guard is dead)
    if thisEntity:HasModifier("modifier_invulnerable") == false then
        boss_frame_manager:SendBossName( )
        boss_frame_manager:UpdateManaHealthFrame( thisEntity )
        boss_frame_manager:HideBossManaFrame()
        boss_frame_manager:ShowBossHpFrame()
        thisEntity.phase = 3
    end

    if thisEntity.phase == 1 then

        -- get a random grid location to mine
        if thisEntity.next_mine_location == true then
            thisEntity.randomIndex = RandomInt(1, #thisEntity.tCenterGrid)
            thisEntity.locationToMine = thisEntity.tCenterGrid[thisEntity.randomIndex]
            thisEntity.next_mine_location = false
        end

        -- mvoe to grid location
        thisEntity:MoveToPosition( thisEntity.locationToMine )

        -- cast one of the bombs every CD
        if thisEntity.sticky_bomb ~= nil and thisEntity.sticky_bomb:IsFullyCastable() and thisEntity.sticky_bomb:IsCooldownReady() then
            return CastBomb()
        end

        -- cast other spells while we move
        if thisEntity.blast_off ~= nil and thisEntity.blast_off:IsFullyCastable() and thisEntity.blast_off:IsCooldownReady() and thisEntity.blast_off:IsInAbilityPhase() == false then
            return CastBlastOff()
        end

        if thisEntity.summon_electric_vortex_turret ~= nil and thisEntity.summon_electric_vortex_turret:IsFullyCastable() and thisEntity.summon_electric_vortex_turret:IsCooldownReady() then
            return CastSummonElectricTurret()
        end

        -- if within 70 units of location, start laying mines
        local distance = ( thisEntity:GetAbsOrigin() - thisEntity.locationToMine ):Length2D()
        if distance < 70 then

            -- cast clsuter mines x number of times
            if thisEntity.cluster_mine_throw ~= nil and thisEntity.cluster_mine_throw:IsFullyCastable() and thisEntity.cluster_mine_throw:IsCooldownReady() and thisEntity.cluster_mine_throw:IsInAbilityPhase() == false then
                return CastClusterMines( thisEntity.locationToMine )
            end

            table.remove(thisEntity.tCenterGrid, randomIndex)
            thisEntity.next_mine_location = true

        end

    end

    if thisEntity.phase == 3 then
        --print("entering phase 3")

        thisEntity:SetBaseMoveSpeed(700)

        thisEntity.tCenterGrid = GridifyMap()

        local randomIndex = RandomInt(1, #thisEntity.tCenterGrid)

        thisEntity:MoveToPosition( thisEntity.tCenterGrid[randomIndex] )

        return 1

    end

	return 0.5
end
--------------------------------------------------------------------------------

function CastClusterMines( locationToMine )

    --thisEntity:RemoveModifierByName("modifier_invisible")
    --DebugDrawCircle(locationToMine,Vector(255,255,0),128,100,true,60)
    --print("location to mine: ",locationToMine)

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = thisEntity.cluster_mine_throw:entindex(),
        Position = locationToMine,
        Queue = false,
    })

    return 0.5
end
--------------------------------------------------------------------------------

function CastBlastOff(  )

    --thisEntity:RemoveModifierByName("modifier_invisible")

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.blast_off:entindex(),
        Queue = false,
    })

    return 3
end
--------------------------------------------------------------------------------

function CastBomb(  )

    --thisEntity:RemoveModifierByName("modifier_invisible")

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.sticky_bomb:entindex(),
        Queue = false,
    })

    return 0.5
end
--------------------------------------------------------------------------------

function CastSummonElectricTurret(  )

    --thisEntity:RemoveModifierByName("modifier_invisible")

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_electric_vortex_turret:entindex(),
        Queue = false,
    })

    return 0.5
end
--------------------------------------------------------------------------------

function GridifyMap()
    if not IsServer() then return end

    -- point 1 top left, point 2 top right, point 3 bot left, point 4 bot right
    --[[local point_1 = Vector(-3710,3060,0)
    local point_2 = Vector(-839,3050,0)       OLD ARENA
    local point_3 = Vector(-3643,348,0)
    local point_4 = Vector(-770,197,0)]]

    local point_1 = Vector(8693,3237,130)
    local point_2 = Vector(11561,3237,130)
    local point_3 = Vector(8693,408,130)
    local point_4 = Vector(11561,408,130)

    --DebugDrawCircle(point_1,Vector(255,255,0),128,100,true,60)
    --DebugDrawCircle(point_2,Vector(255,0,255),128,100,true,60)
    --DebugDrawCircle(point_3,Vector(0,255,255),128,100,true,60)
    --DebugDrawCircle(point_4,Vector(0,255,0),128,100,true,60)

    local grid_size_x = 980
    local grid_size_y = 950

    local length =          math.abs( point_2.y - point_4.y )
    local width =           math.abs( point_3.x - point_4.x )
    local grid_size =       Vector(grid_size_x,grid_size_y, 130 ) --163

    local nColumns =        math.floor( width / grid_size.x )
    local nRows =           math.floor( length / grid_size.y )

    -- create a table full of positions according for row|column
    local tGrid = {}
    local x_start = point_3.x
    local y_start = point_3.y
    local vGridLocation = Vector(0, 0, 0)
    local vPrevCalcPos = Vector(0, 0, 0)
    for i = 0, nColumns, 1 do
        for j = 0, nRows, 1 do

        vPrevCalcPos = Vector(x_start + grid_size.x * i, y_start + grid_size.y * j, grid_size.z)

        vGridLocation = Vector(vPrevCalcPos.x, vPrevCalcPos.y, grid_size.z)

        -- calc center of each grid location
        local vCenterLocation = Vector(vGridLocation.x + ( grid_size_x / 2), vGridLocation.y + ( grid_size_y / 2), grid_size.z)
        --DebugDrawCircle(vCenterLocation,Vector(255,0,0),128,50,true,60)
        --DebugDrawCircle(vGridLocation,Vector(0,255,0),128,100,true,60)

        table.insert(tGrid, vCenterLocation)
        end
    end

    return tGrid
end
--------------------------------------------------------------------------------