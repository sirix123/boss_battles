gyro_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	_G.Oil_Puddles = {}

	-- general boss init
	boss_frame_manager:SendBossName()
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:ShowBossManaFrame()
	boss_frame_manager:ShowBossHpFrame()
	thisEntity:SetMana(0)
	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_generic_everything_phasing", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:SetHullRadius(60)

	-- spell init
	thisEntity.swoop = thisEntity:FindAbilityByName( "swoop_v2" )
	thisEntity.swoop_speed = thisEntity.swoop:GetLevelSpecialValueFor("charge_speed", thisEntity.swoop:GetLevel())
	thisEntity.barrage_duration = thisEntity.swoop:GetLevelSpecialValueFor("barrage_duration", thisEntity.swoop:GetLevel())


	-- phase init
	thisEntity.PHASE = 1

	thisEntity:SetContextThink( "GyroThink", GyroThink, 0.1 )
end

function GyroThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--[[

	STATES HANDLERS

	if thisEntity.PHASE == 1 and every 10% hp then
		thisEntity.PHASE = 2
	end

	if thisEntity.PHASE == 2 and whirlwind over then
		thisEntity.PHASE = 1
	end

	]]

	--[[

	STATES

	]]

	if thisEntity.PHASE == 1 then
		if thisEntity.swoop:IsFullyCastable() and thisEntity.swoop:IsCooldownReady() and thisEntity.swoop:IsInAbilityPhase() == false then
			return CastSwoop( FindFurthestPlayer() )
		end
	end

	if thisEntity.PHASE == 2 then
		-- cast whirlwind
	end

	return 0.1
end
--------------------------------------------------------------------------------

function CastSwoop( hTarget )

	if hTarget == nil then
		return 0.1
	end

	local distance = ( thisEntity:GetAbsOrigin() - hTarget:GetAbsOrigin() ):Length2D()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.swoop:entindex(),
		Queue = false,
	})

    local velocity = thisEntity.swoop_speed
    local time = ( distance / velocity ) + thisEntity.barrage_duration

	return time
end
--------------------------------------------------------------------------------

function FindFurthestPlayer()

	-- find random player
	local enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #enemies ~= 0 and enemies ~= nil then
		return enemies[#enemies]
	else
		return nil
	end
end
--------------------------------------------------------------------------------
