charge_bot_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.quick_strike = thisEntity:FindAbilityByName( "quick_strike" )
    thisEntity.mana_drain = thisEntity:FindAbilityByName( "mana_drain" )

    thisEntity:SetHullRadius(100)

    thisEntity:SetMana(0)

    thisEntity.PHASE = 1

    thisEntity:AddNewModifier( nil, nil, "turn_rate_modifier", { duration = -1 })

    thisEntity.particle_created = false

    -- new target timer
    NewQuickStrikeTarget()

    thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

    thisEntity:SetContextThink( "ChargeThinker", ChargeThinker, 0.1 )

end
--------------------------------------------------------------------------------

function ChargeThinker()
	if not IsServer() then return end

    if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    -- phase 1 find the crystal and move towards it
    if thisEntity.PHASE == 1 then
        -- find the prism
        local friends = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),
            thisEntity:GetAbsOrigin(),
            nil,
            4000,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false
        )

        -- prism found, move towards it
        if thisEntity.vPrismPos == nil then
            for _, prism in pairs(friends) do
                if prism:GetUnitName() == "npc_crystal" then
                    thisEntity.vPrismPos = prism:GetAbsOrigin()
                    thisEntity.hPrism = prism
                    MoveToPos( thisEntity.vPrismPos )
                end
            end
        end

        -- when close to it change to phase 2
        if ( thisEntity:GetAbsOrigin() - thisEntity.vPrismPos ):Length2D() < 700 then
            thisEntity.PHASE = 2
        end

        --print("distance ",( thisEntity:GetAbsOrigin() - thisEntity.vPrismPos ):Length2D())

        return 0.5
    end

    -- if not at full mana, start mana draining it
    if thisEntity.PHASE == 2 then

        if thisEntity.mana_drain ~= nil and thisEntity.mana_drain:IsFullyCastable() and thisEntity.mana_drain:IsCooldownReady() and thisEntity.mana_drain:IsInAbilityPhase() == false and thisEntity.mana_drain:IsChanneling() == false then
            CastManaDrain( thisEntity.hPrism )
        end

        -- when full mana enter phase 3
        if thisEntity:GetManaPercent() > 95 then
            thisEntity.PHASE = 3
        end

        --print("mana? ",thisEntity:GetManaPercent())

        return 0.5
    end

    -- at full mana, start blasting a target, start chasing a target, switch targets every 30seconds (used a timer to change the target)
    if thisEntity.PHASE == 3 then

        if thisEntity.particle_created == false then
            --print("creating particle")
            local particle = "particles/tinker/tinker_charge_rubick_supernova_egg.vpcf"
            thisEntity.effect = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, thisEntity )
            ParticleManager:SetParticleControl( thisEntity.effect, 0, thisEntity:GetAbsOrigin() )
            ParticleManager:SetParticleControl( thisEntity.effect, 1, thisEntity:GetAbsOrigin() )
            thisEntity.particle_created = true
        end

        if thisEntity.quick_strike ~= nil and thisEntity.quick_strike:IsFullyCastable() and thisEntity.quick_strike:IsCooldownReady() and thisEntity.quick_strike:IsInAbilityPhase() == false then
            CastQuickStrike( thisEntity.target )
        end

        -- go back to phase 1 if at < 10 mana
        if thisEntity:GetManaPercent() < 5 then
            --print("mana? ",thisEntity:GetManaPercent())
            if thisEntity.effect ~= nil then
                ParticleManager:DestroyParticle(thisEntity.effect,true)
            end
            thisEntity.particle_created = false
            thisEntity.PHASE = 1
        end

        return 0.3
    end

	return 0.5
end
--------------------------------------------------------------------------------

function CastManaDrain( prism )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        TargetIndex = prism:entindex(),
        AbilityIndex = thisEntity.mana_drain:entindex(),
        Queue = false,
    })

end
--------------------------------------------------------------------------------

function CastQuickStrike( enemy )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = enemy:GetAbsOrigin(),
        AbilityIndex = thisEntity.quick_strike:entindex(),
        Queue = false,
    })
end
--------------------------------------------------------------------------------

function NewQuickStrikeTarget()

    Timers:CreateTimer(function()
        if IsValidEntity(thisEntity) == false then return false end

        local enemies = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),
            thisEntity:GetAbsOrigin(),
            nil,
            6000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false
        )


        if enemies ~= nil and #enemies ~= 0 then
            thisEntity.target = enemies[RandomInt(1,#enemies)]
        end

        return 30
    end)
end
--------------------------------------------------------------------------------

function MoveToPos( pos_to_move_to )

    thisEntity:MoveToPosition(pos_to_move_to)
    local distance = ( thisEntity:GetAbsOrigin() - pos_to_move_to ):Length2D() - 600
    local velocity = thisEntity:GetBaseMoveSpeed()
    local time = distance / velocity

    return time
end