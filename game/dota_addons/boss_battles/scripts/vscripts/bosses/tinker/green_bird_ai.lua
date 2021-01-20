green_bird_ai = class({})

LinkLuaModifier("modifier_flying", "bosses/tinker/modifiers/modifier_flying", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "modifier_flying", { duration = -1 } )
    thisEntity:AddNewModifier( thisEntity, nil, "modifier_phased", { duration = -1 } )

    thisEntity.green_bird_explode = thisEntity:FindAbilityByName( "green_bird_explode" )

    thisEntity.PHASE = 1

    thisEntity.vPlayerLocation = nil

    --FindAPlayer()

    thisEntity:SetContextThink( "BirdGreenThinker", BirdGreenThinker, 0.1 )

end
--------------------------------------------------------------------------------

function BirdGreenThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    --print("thisEntity.PHASE ",thisEntity.PHASE)

    if thisEntity.PHASE == 1 then
        if thisEntity.vPlayerLocation ~= nil then
            return MoveToPos(thisEntity.vPlayerLocation)
        else
            FindAPlayer()
            thisEntity.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 0, thisEntity.vPlayerLocation )
            ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 1, Vector( 400, -400, -400 ) )
            ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 2, Vector( 999, 0, 0 ) );
            
            return 0.5
        end
    end

    if thisEntity.PHASE == 2 then
        --print("thisEntity.PHASE ",thisEntity.PHASE)
        thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)
        --thisEntity:RemoveModifierByName("modifier_invulnerable")
        thisEntity:RemoveModifierByName("modifier_flying")
        thisEntity.PHASE = 3

        -- falling to ground time buff
        return 1
    end

    if thisEntity.PHASE == 3 then

        if ( ( thisEntity:GetAbsOrigin() - thisEntity.vPlayerLocation ):Length2D() ) < 50 then

            if thisEntity.green_bird_explode ~= nil and thisEntity.green_bird_explode:IsFullyCastable() and thisEntity.green_bird_explode:IsCooldownReady() then
                CastExplode(  )
            end

            ParticleManager:DestroyParticle( thisEntity.nPreviewFXIndex, true )

        end

        return 0.5
    end

	return 0.5
end
--------------------------------------------------------------------------------

function FindAPlayer()

    local units = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),	-- int, your team number
        thisEntity:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        4000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    if units ~= nil and #units ~= 0 then
        thisEntity.vPlayerLocation = units[RandomInt(1,#units)]:GetAbsOrigin()
        --print("thisEntity.vPlayerLocation ",thisEntity.vPlayerLocation)
    end

end
--------------------------------------------------------------------------------

function MoveToPos( pos_to_move_to )

    thisEntity:MoveToPosition(pos_to_move_to)
    local distance = ( thisEntity:GetAbsOrigin() - pos_to_move_to ):Length2D()
    local velocity = thisEntity:GetBaseMoveSpeed()
    local time = distance / velocity

    thisEntity.PHASE = 2

    return time + 1
end

--------------------------------------------------------------------------------
function CastExplode(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.green_bird_explode:entindex(),
        Queue = false,
    })
end
--------------------------------------------------------------------------------

