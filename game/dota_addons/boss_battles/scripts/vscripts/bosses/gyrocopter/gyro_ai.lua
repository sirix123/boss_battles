gyro_ai = class({})
LinkLuaModifier( "oil_ignite_fire_puddle_thinker", "bosses/gyrocopter/oil_ignite_fire_puddle_thinker", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	_G.Oil_Puddles = {}
	_G.Fire_Puddles = {}

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

	-- spawn water gun on the ground left between players and gyro
	local newItem = CreateItem("item_water_gun", nil, nil)
	local obj = CreateItemOnPositionForLaunch( Vector(-13051,1045,131), newItem )
	obj:SetModelScale(1.3)

	local particle = "particles/techies/etherial_targetglow_repeat.vpcf"
	local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, obj)
	ParticleManager:SetParticleControl(nfx, 1, obj:GetAbsOrigin())
	obj:SetForwardVector( Vector( RandomFloat(-1, 1) , RandomFloat(-1, 1), RandomFloat(-1, 1) ) )

	-- spell init
	thisEntity.swoop = thisEntity:FindAbilityByName( "swoop_v2" )
	thisEntity.swoop_speed = thisEntity.swoop:GetLevelSpecialValueFor("charge_speed", thisEntity.swoop:GetLevel())
	thisEntity.barrage_duration = thisEntity.swoop:GetLevelSpecialValueFor("barrage_duration", thisEntity.swoop:GetLevel())

	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.flak_cannon_duration = thisEntity.flak_cannon:GetLevelSpecialValueFor("duration", thisEntity.flak_cannon:GetLevel())

	thisEntity.cannon_ball = thisEntity:FindAbilityByName( "cannon_ball" )

	thisEntity.flee = thisEntity:FindAbilityByName( "flee_v2" )
	thisEntity.flee_speed = thisEntity.flee:GetLevelSpecialValueFor("speed", thisEntity.flee:GetLevel())

	-- flee point calculations
	local ArenaTop = 3025
	local ArenaBot = 425
	local ArenaLeft = -13600
	local ArenaRight = -11000
	local AreanMiddle = Vector((ArenaLeft/2)+(ArenaRight/2), (ArenaTop/2) + (ArenaBot/2), 132) --MID POINT FORMULA: -- (ArenaTop / 2 ) + (ArenaBot / 2)
	thisEntity.GyroArenaLocations = {
		Vector(AreanMiddle.x,ArenaTop,132),
		Vector(ArenaRight,ArenaTop,132),
		Vector(ArenaRight,AreanMiddle.y,132),
		Vector(ArenaRight,ArenaBot,132),
		Vector(AreanMiddle.x,ArenaBot,132),
		Vector(ArenaLeft,ArenaBot,132),
		Vector(ArenaLeft,AreanMiddle.y,132),
		Vector(ArenaLeft,ArenaTop,132),
		Vector(ArenaLeft,ArenaTop,132),
		AreanMiddle,
	}

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
			--return CastSwoop( FindFurthestPlayer() )
		end

		if thisEntity.flee:IsFullyCastable() and thisEntity.flee:IsCooldownReady() and thisEntity.flee:IsInAbilityPhase() == false then
			--return CastFlee( thisEntity.GyroArenaLocations[RandomInt(1,#thisEntity.GyroArenaLocations)])
		end

		if thisEntity.cannon_ball:IsFullyCastable() and thisEntity.cannon_ball:IsCooldownReady() and thisEntity.cannon_ball:IsInAbilityPhase() == false then
			return CastCannonBall( FindRandomPlayer():GetAbsOrigin() )
		end

		if thisEntity.flak_cannon:IsFullyCastable() and thisEntity.flak_cannon:IsCooldownReady() and thisEntity.flak_cannon:IsInAbilityPhase() == false then
			return CastFlakCannon()
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

function CastFlee( vLocation )

	if vLocation == nil then
		return 0.1
	end

	local distance = ( thisEntity:GetAbsOrigin() - vLocation ):Length2D()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.flee:entindex(),
		Position = vLocation,
		Queue = false,
	})

	local velocity = thisEntity.flee_speed
    local time = ( distance / velocity )

	return time
end
--------------------------------------------------------------------------------

function CastCannonBall( vLocation )

	if vLocation == nil then
		return 0.1
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.cannon_ball:entindex(),
		Position = vLocation,
		Queue = false,
	})

	return 0.1
end
--------------------------------------------------------------------------------

function CastFlakCannon()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.flak_cannon:entindex(),
		Queue = false,
	})

	return thisEntity.flak_cannon_duration
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

function FindRandomPlayer()

	-- find random player
	local enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		2000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #enemies ~= 0 and enemies ~= nil then
		return enemies[RandomInt(1,#enemies)]
	else
		return nil
	end
end
--------------------------------------------------------------------------------

function IgniteOil()

	for _, oilThinker in ipairs(_G.Oil_Puddles) do
		if oilThinker and not oilThinker:IsNull() then

			local fire_puddle = CreateModifierThinker(
				thisEntity,
					self,
					"oil_ignite_fire_puddle_thinker",
					{
						target_x = oilThinker:GetAbsOrigin().x,
						target_y = oilThinker:GetAbsOrigin().y,
						target_z = oilThinker:GetAbsOrigin().z,
					},
					oilThinker:GetAbsOrigin(),
					thisEntity:GetTeamNumber(),
					false
				)

				table.insert(_G.Fire_Puddles, fire_puddle)

			oilThinker:RemoveSelf()
		end
	end

	_G.Oil_Puddles = {}

end
--------------------------------------------------------------------------------
