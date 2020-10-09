assistant_ai = class({})
LinkLuaModifier( "oil_leak_modifier", "bosses/techies/modifiers/oil_leak_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "guard_death_modifier", "bosses/techies/modifiers/guard_death_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	--thisEntity:AddNewModifier( nil, nil, "oil_leak_modifier", { duration = -1 })
	thisEntity:AddNewModifier( nil, nil, "guard_death_modifier", { duration = -1 })

	thisEntity.stomp_push = thisEntity:FindAbilityByName( "stomp_push" )
	thisEntity.stomp_push:SetLevel(1)
	thisEntity.stomp_push:StartCooldown(5)

	--CreateUnitByName( "npc_techies", Vector(10126,1776,0), true, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)

	thisEntity:SetHullRadius(80)

    thisEntity:SetContextThink( "AssistantThink", AssistantThink, 0.5 )

end
--------------------------------------------------------------------------------

function AssistantThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--[[if thisEntity:GetAttackTarget() == nil then
		print("attakcing player")
		return AttackClosestPlayer()
	end]]

	--print("thisEntity.stomp_push ", thisEntity.stomp_push)
	--print("thisEntity.stomp_push:IsFullyCastable() ", thisEntity.stomp_push:IsFullyCastable())
	--print("thisEntity.stomp_push:IsCooldownReady() ", thisEntity.stomp_push:IsCooldownReady())

	if thisEntity.stomp_push ~= nil and thisEntity.stomp_push:IsFullyCastable() and thisEntity.stomp_push:IsCooldownReady() then
		--print("stomp push")
		return CastStompPush()
	end

	return 0.5
end

--------------------------------------------------------------------------------

function AttackClosestPlayer()
	-- find closet player
    local enemies = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetAbsOrigin(),
        nil,
        2500,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

	if #enemies == 0 then
		return 0.5
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		TargetIndex = enemies[1]:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------

function CastStompPush(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.stomp_push:entindex(),
        Queue = false,
    })

    return thisEntity.stomp_push:GetCastPoint() + 1
end
