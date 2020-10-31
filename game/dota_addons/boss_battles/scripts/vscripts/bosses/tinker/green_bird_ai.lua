green_bird_ai = class({})

LinkLuaModifier("modifier_flying", "bosses/tinker/modifiers/modifier_flying", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "modifier_flying", { duration = -1 } )

    -- fire particle effect, sit on bird to make it look firey

    thisEntity:SetContextThink( "BirdGreenThinker", BirdGreenThinker, 0.1 )

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

	return 0.5
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

