bird_ai = class({})

LinkLuaModifier("bird_floor_nofly", "bosses/tinker/modifiers/bird_floor_nofly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flying", "bosses/tinker/modifiers/modifier_flying", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bird_puddle_thinker", "bosses/tinker/modifiers/bird_puddle_thinker", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.bird_aoe_spell = thisEntity:FindAbilityByName( "bird_aoe_spell" )
    thisEntity.summon_green_bird = thisEntity:FindAbilityByName( "summon_green_bird" )

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "modifier_flying", { duration = -1 } )

    -- fire particle effect, sit on bird to make it look firey


    thisEntity.PHASE = 1
    thisEntity.tMovePos = {}
    CalcMovePositions()

    thisEntity:SetContextThink( "BirdThinker", BirdThinker, 0.1 )

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

    --print(" bird thisEntity.PHASE ",thisEntity.PHASE)

    -- move to random pos around the arena until table is 0 then go to phase 2 (pos calc in spawn function)
    if thisEntity.PHASE == 1 then
        --print("thisEntity.PHASE ",thisEntity.PHASE)
        if thisEntity.tMovePos ~= nil and #thisEntity.tMovePos ~= 0 then
            local randomIndex = RandomInt(1,#thisEntity.tMovePos)
            local pos_to_move_to = thisEntity.tMovePos[randomIndex]
            table.remove(thisEntity.tMovePos, randomIndex)
            return MoveToPos(pos_to_move_to)
        else
            thisEntity.PHASE = 2
            return 1
        end
    end

    -- play landing animation and transform into a different model?, return fixed value for buffer then goto phase 3
    if thisEntity.PHASE == 2 then
        --print("thisEntity.PHASE ",thisEntity.PHASE)
        thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)
        thisEntity:RemoveModifierByName("modifier_invulnerable")
        thisEntity:RemoveModifierByName("modifier_flying")
        thisEntity.PHASE = 3

        -- falling to ground time buff
        return 1
    end

    -- start casting bird aoe spell, return the time to finish spell
    if thisEntity.PHASE == 3 then
        --print("thisEntity.PHASE ",thisEntity.PHASE)
        if thisEntity.bird_aoe_spell ~= nil and thisEntity.bird_aoe_spell:IsFullyCastable() and thisEntity.bird_aoe_spell:IsCooldownReady() then
            CastAoeSpell()
        end

        thisEntity.PHASE = 4

        -- this return int is the animation duration
        return 12
    end

    -- fly again, invul again, find the crystal and fly towards it
    -- just before flying up, place a lava puddle on the ground
    if thisEntity.PHASE == 4 then
        --print("thisEntity.PHASE ",thisEntity.PHASE)

        -- create a thinker where the puddle is
        thisEntity.fire_puddle_thinker = CreateModifierThinker(
            thisEntity,
            thisEntity,
            "bird_puddle_thinker",
            {
                duration = -1,
                target_x = thisEntity:GetAbsOrigin().x,
                target_y = thisEntity:GetAbsOrigin().y,
                target_z = thisEntity:GetAbsOrigin().z,
            },
            thisEntity:GetAbsOrigin(),
            thisEntity:GetTeamNumber(),
            false
        )

        thisEntity:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
        thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
        thisEntity:AddNewModifier( thisEntity, nil, "modifier_flying", { duration = -1 } )

        -- find the crystal
        local distance = ( thisEntity:GetAbsOrigin() - FindCrystal():GetAbsOrigin() ):Length2D()
        local velocity = thisEntity:GetBaseMoveSpeed()
        local time = distance / velocity

        -- fly towards it
        MoveToPos(FindCrystal():GetAbsOrigin())

        thisEntity.PHASE = 5

        return time + 2
    end

    if thisEntity.PHASE == 5 then

        if thisEntity.summon_green_bird ~= nil and thisEntity.summon_green_bird:IsFullyCastable() and thisEntity.summon_green_bird:IsCooldownReady() then
            CastSummonGreenBird(  )
        end

        thisEntity.PHASE = 6

        return 0.5
    end

    if thisEntity.PHASE == 6 then
        thisEntity:ForceKill(false)

        -- give tinker mana
        FindCrystal():GiveMana(10)

        -- green destroy effect or something
    end

	return 0.5
end
--------------------------------------------------------------------------------
function CalcMovePositions()

    local centre_point = Vector(-10633,11918,130.33)
    local radius = 1250

    -- random x y for max pos
    local max_moves = 5

    for i = 1, max_moves, 1 do
        local x = RandomInt(centre_point.x - radius, centre_point.x + radius)
        local y = RandomInt(centre_point.y - radius, centre_point.y + radius)
        local move_pos = Vector(x,y,0)
        --print("move_pos ", move_pos)
        table.insert(thisEntity.tMovePos, move_pos)
    end
end
--------------------------------------------------------------------------------

function FindCrystal()

    local units = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),	-- int, your team number
        thisEntity:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_crystal" then
            return unit
        end
    end
end
--------------------------------------------------------------------------------

function MoveToPos( pos_to_move_to )

    thisEntity:MoveToPosition(pos_to_move_to)
    local distance = ( thisEntity:GetAbsOrigin() - pos_to_move_to ):Length2D()
    local velocity = thisEntity:GetBaseMoveSpeed()
    local time = distance / velocity

    return time + 1
end

--------------------------------------------------------------------------------
function CastAoeSpell(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.bird_aoe_spell:entindex(),
        Queue = false,
    })
end
--------------------------------------------------------------------------------

function CastSummonGreenBird(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_green_bird:entindex(),
        Queue = false,
    })
end
--------------------------------------------------------------------------------

