assistant_ai = class({})
LinkLuaModifier( "oil_leak_modifier", "bosses/techies/modifiers/oil_leak_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "guard_death_modifier", "bosses/techies/modifiers/guard_death_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "turn_rate_modifier", "bosses/techies/modifiers/turn_rate_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
	if thisEntity == nil then return end

	local boss_name = "Rister Fange"
	boss_frame_manager:SendBossName( boss_name )
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:HideBossManaFrame()
	boss_frame_manager:ShowBossHpFrame()

	--thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	--thisEntity:AddNewModifier( nil, nil, "oil_leak_modifier", { duration = -1 })
	thisEntity:AddNewModifier( nil, nil, "guard_death_modifier", { duration = -1 })
	thisEntity:AddNewModifier( nil, nil, "turn_rate_modifier", { duration = -1 })

	thisEntity.assistant_sweep = thisEntity:FindAbilityByName( "assistant_sweep" )
	thisEntity.assistant_sweep:SetLevel(1)
	thisEntity.assistant_sweep:StartCooldown(1)

	thisEntity.stomp_push = thisEntity:FindAbilityByName( "stomp_push" )
	thisEntity.stomp_push:SetLevel(1)
	thisEntity.stomp_push:StartCooldown(15)

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

	-- find all units to find the cloest target
	local targets = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetOrigin(),
		nil,
		3000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #targets > 0 then
		thisEntity:SetAggroTarget(targets[1])
		thisEntity:MoveToTargetToAttack(targets[1])
	end

	-- find units in a line for sweep
	local length = 600
	thisEntity.vTargetPos = thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * length

	local units = FindUnitsInLine(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * 200,
		thisEntity.vTargetPos,
		nil,
		50,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

	if #units > 0 and thisEntity.assistant_sweep ~= nil and thisEntity.assistant_sweep:IsFullyCastable() and thisEntity.assistant_sweep:IsCooldownReady() and thisEntity.assistant_sweep:IsInAbilityPhase() == false then
		return CastSweep( thisEntity.vTargetPos )
	end

	if thisEntity.stomp_push ~= nil and thisEntity.stomp_push:IsFullyCastable() and thisEntity.stomp_push:IsCooldownReady() then
		--print("stomp push")
		return CastStompPush()
	end

	return 0.03
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

function CastSweep( vTargetPos )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = vTargetPos,
		AbilityIndex = thisEntity.assistant_sweep:entindex(),
        Queue = false,
	})

	return thisEntity.assistant_sweep:GetCastPoint() + 0.3
end