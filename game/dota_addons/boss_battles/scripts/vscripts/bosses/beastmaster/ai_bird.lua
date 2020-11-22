bird_ai = class({})

LinkLuaModifier("bird_floor_nofly", "bosses/tinker/modifiers/bird_floor_nofly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flying", "bosses/tinker/modifiers/modifier_flying", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ground", "bosses/beastmaster/modifier_ground", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bird_death_modifier", "bosses/beastmaster/bird_death_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.grab_player = thisEntity:FindAbilityByName( "grab_player" )
    thisEntity.grab_player:StartCooldown(RandomInt(20,30))

    thisEntity:AddNewModifier( thisEntity, nil, "modifier_flying", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "modifier_phased", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "modifier_invulnerable", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "bird_death_modifier", { duration = -1 } )

    thisEntity.PHASE = 1

    thisEntity.circle_timer_running = false

    thisEntity:SetContextThink( "BirdThinker", BirdThinker, 0.1 )

end
--------------------------------------------------------------------------------

function CricleTimer()
    thisEntity.circle_timer_running = true
    local currentAngle = 0
    local angleIncrement = 15
    local length = 1000
    local tickInterval = 0.5

    Timers:CreateTimer(function()
        if thisEntity.PHASE ~= 1 then 
            thisEntity.circle_timer_running = false
            return false
        end

        -- calculate a position length units away, rotating by currentAngle
        currentAngle =  currentAngle + angleIncrement
        local radAngle = currentAngle * 0.0174532925 --angle in radians
        local point = Vector(length * math.cos(radAngle), length * math.sin(radAngle), 0)
        local endPoint = point + Vector(-1610.878662, -9771.228516, 261.128906)
        thisEntity:MoveToPosition(endPoint)
        return tickInterval
    end)
end

--------------------------------------------------------------------------------

function BirdThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    -- fly in a circle, slowly, shoot a random player (bloodlust affects this normal attack)
    -- setup a timer to change target every 15 seconds
    if thisEntity.PHASE == 1 then
        thisEntity.target = nil

        if thisEntity:HasModifier("modifier_invulnerable") == false then
            thisEntity:AddNewModifier( thisEntity, nil, "modifier_invulnerable", { duration = -1 } )
        end

        -- if we dont have the flying modifier add it, but first remove the ground modifier
        thisEntity:RemoveModifierByName("modifier_ground")
        if thisEntity:HasModifier("modifier_flying") == false then
            thisEntity:AddNewModifier( thisEntity, nil, "modifier_flying", { duration = -1 } )
        end

        -- fly in a circle
        if thisEntity.circle_timer_running == false then
            CricleTimer()
        end

        -- if spell ready set phase to phase 2
        if thisEntity.grab_player:IsCooldownReady() then
			thisEntity.PHASE = 2
		end

        return 0.5
    end

    -- find target, pass it to the grab player spell
    -- mark a target and fly towards it increase movespeed
    -- calculate how far away the player is from when we cast this, reutrn that value, set phase 3
    if thisEntity.PHASE == 2 then

        local units = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),	-- int, your team number
            thisEntity:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            FIND_ANY_ORDER,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return 0.5
        end

        thisEntity.target = units[RandomInt(1,#units)]
        thisEntity.vTarget = thisEntity.target:GetAbsOrigin()

        -- mark target (particle)
        local particle = "particles/timber/bird_overhead_icon.vpcf"
        thisEntity.head_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, thisEntity.target)
        ParticleManager:SetParticleControl(thisEntity.head_particle, 0, thisEntity.vTarget)

        thisEntity.PHASE = 3

        return 0.5
    end

    -- keep updating the pos of the player location and fly towards him
    if thisEntity.PHASE == 3 then
        local units = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),	-- int, your team number
            thisEntity:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            FIND_ANY_ORDER,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return 0.5
        end

        for _, unit in pairs(units) do
            if unit:GetUnitName() == thisEntity.target:GetUnitName() then
                thisEntity.vTarget = unit:GetAbsOrigin()
            end
        end

        if thisEntity.target == nil or thisEntity.target:IsAlive() == false then

            -- remove mark
            if thisEntity.head_particle ~= nil then
                ParticleManager:DestroyParticle(thisEntity.head_particle, true)
            end

            thisEntity.PHASE = 2
            return 0.5
        end
        
        thisEntity:MoveToPosition(thisEntity.vTarget)

        -- if we are close to the player target cast laso
        if ( thisEntity:GetAbsOrigin() - thisEntity.vTarget ):Length2D() < 250 then
            thisEntity.PHASE = 4

            -- stop flying go to ground level
            thisEntity:RemoveModifierByName("modifier_flying")

            -- add ground modifier
            thisEntity:AddNewModifier( thisEntity, nil, "modifier_ground", { duration = -1 } )

            -- init
            thisEntity.vWaterPos = nil

            -- remove mark
            if thisEntity.head_particle ~= nil then
                ParticleManager:DestroyParticle(thisEntity.head_particle, true)
            end

            -- cast grab
            return CastGrab( thisEntity.target )
        end

        return 0.5
    end

    -- bird has the player, pick 1 of 4 locations (could randomise one axis of each location )
    -- calc duration of mvoing to get to that location return by that value and chagne to phase 4
    -- remove invul, display the modifier that shows how much dmg to deal to get the bird to drop the player
    -- if the taken attk dmg modifier is removed during this phase then drop player where bird is and return to phase 1
    if thisEntity.PHASE == 4 then

        if thisEntity:HasModifier("modifier_invulnerable") then
            thisEntity:RemoveModifierByName("modifier_invulnerable")
        end

        if thisEntity.vWaterPos == nil then 
            local vPos = {
                Vector(-1789.364868, -11690.703125, 133.128906),
                Vector(-3550.518311, -9739.487305, 133.128906),
                Vector(-1465.154541, -7916.410156, 133.128906),
                Vector(191.335999, -10026.628906, 133.128906),
            }

            thisEntity.vWaterPos = vPos[RandomInt(1,#vPos)]
            thisEntity:MoveToPosition(thisEntity.vWaterPos)

        end

        --print( "distance ", ( thisEntity:GetAbsOrigin() - thisEntity.vWaterPos ):Length2D())
        if ( thisEntity:GetAbsOrigin() - thisEntity.vWaterPos ):Length2D() < 50 then
            -- drop the player
            if thisEntity.target:HasModifier("grab_player_modifier") == true then
                thisEntity.target:RemoveModifierByName("grab_player_modifier")
            end

            -- put the spell on CD
            thisEntity.grab_player:StartCooldown(RandomInt(25,35))

            -- return to phase 1
            thisEntity.PHASE = 1
        end

        return 0.5
    end

	return 0.5
end
--------------------------------------------------------------------------------

function CastGrab(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.grab_player:entindex(),
        Queue = false,
    })

    return 0.5
end
