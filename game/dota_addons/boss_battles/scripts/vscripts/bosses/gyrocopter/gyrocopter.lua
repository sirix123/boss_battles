
gyrocopter = class({})
--ANIMATIONS/DEBUG DRAW Spells
--Global vars, but local to this file, to persist state 

local currentPhase = 1

local gyro_boss 

function Spawn( entityKeyValues )
	print("Spawn called")



	thisEntity.radar_scan = thisEntity:FindAbilityByName( "radar_scan" )
	thisEntity.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	thisEntity.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	thisEntity.rocket_barrage = thisEntity:FindAbilityByName( "rocket_barrage" )

	--TODO: if any of these are nill
	thisEntity:SetContextThink( "MainThinker", MainThinker, 1 )
end

local tickCount = 0
function MainThinker()
	tickCount = tickCount + 1

	print("MainThinker")
	
	-- Almost all code should not run when the game is paused. Keep this near the top so we return early.
	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity == nil then
		return
	end

	--TODO: test abilities:
	if tickCount == 3 then
		print("Calling CastRadarScan")
		CastRadarScan()
	end

	if tickCount == 10 then
		print("Calling CastHomingMissile")
		CastHomingMissile()
	end

	--flak_cannon
	if tickCount == 15 then
		print("Calling CastFlakCannon")
		CastFlakCannon()
	end

	--rocket_barrage
	if tickCount == 20 then
		print("Calling CastRocketBarrage")
		CastRocketBarrage()
	end

	--TODO: Phase check logic
		--Maybe HP based or time? Just implement one of them and can change it later

	--TODO: Phase init, once off, on phase change
		-- Set bool true on phase change, do these once off things and then set to false
	--TODO: Phase tick, every tick, e.g do these things if PHASE.ONE
	--TODO: Make ability queue structure? does lua have stack and queue?

	--PHASE 0 / INIT:
		-- Initial Radar Scan, then start timer for next.
		-- Initial homing rocket,then start timer for next.
		-- Target one of the players being targeted by a rocket.

	--PHASE 1:
		-- Upgrade spells lvl.
		-- Learn Flak Cannon

	-- PHASE 2:
		-- Upgrade spells lvl

	--	Think about this stuff later, for now just write code for basic functions

	return 1 
end



function CastRadarScan()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.radar_scan:entindex(),
		--Position = vTargetPos,
		Queue = true,
	})
end

--TODO: how does homingMissile get it's target?
	--Surely I determine that here and 
function CastHomingMissile(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.homing_missile:entindex(),
		Queue = true,
	})
end

function CastFlakCannon()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.flak_cannon:entindex(),
		Queue = true,
	})
end

function CastRocketBarrage()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.rocket_barrage:entindex(),
		Queue = true,
	})
end






--WROTE THIS FOR BM BUT USEFUL TEMPLATE FOR ANY PHASE CHANGE

-- function BeastmasterThink()
-- 	if not IsServer() then
-- 		return
-- 	end
-- 	if ( not thisEntity:IsAlive() ) then
-- 		return -1
-- 	end
-- 	-- Almost all code should not run when the game is paused. Keep this near the top so we return early.
-- 	if GameRules:IsGamePaused() == true then
-- 		return 0.5
-- 	end

-- 	doPhaseChange = CheckPhaseChange() --sets newPhase to a PHASE if we should phase change

-- 	-- Do any actions if flagged. The other of the below methods is important, that's the order they'll be queue up to do if there are multiple. 
-- 		-- Unless you execute a command that is not queued, Queued false will interupt everything and happen instantly:
-- 		--		ExecuteOrderFromTable({
-- 		--			AbilityIndex = thisEntity.beastmaster_net:entindex(),
-- 		--			Queue = false,
-- 		--		})

-- 	--Change between phases, happens once per phase
-- 	if doPhaseChange then
-- 		--Check what current phase we're in and do any wrap up / clean up before changing to new phase
-- 		if currentPhase == PHASE.ONE then
-- 			EndPhase1()
-- 		end
-- 		if currentPhase == PHASE.TWO then
-- 			EndPhase2()
-- 		end

-- 		--Check what phase to change into and 
-- 		if newPhase == PHASE.ONE then
-- 			StartPhase1()
			
-- 			-- finished changing phase. Set all vars that manage/track phaseChange state.
-- 			previousPhase = currentPhase
-- 			currentPhase = newPhase
-- 			newPhase = PHASE.NONE --do no phase change. can't set newPhase = nil because then it will crash on if checks
-- 		end
-- 		if newPhase == PHASE.TWO then
-- 			StartPhase2()

-- 			previousPhase = currentPhase
-- 			currentPhase = newPhase
-- 			newPhase = PHASE.NONE 
-- 		end
-- 		doPhaseChange = false;	-- set to false so this code doesn't run again unless flagged too
-- 	end




-- 	-- Do other actions that happen throughout each phase
-- 	if currentPhase == PHASE.ONE then
-- 		DoPhase1() -- Check conditions then execute any spells/events 
-- 	end
-- 	if currentPhase == PHASE.TWO then
-- 		DoPhase2() -- Check conditions then execute any spells/events 
-- 	end

-- end --end func

--TODO: Write funcs for my abilities
--Code it up first logically, then add the dota components in


-- Spawns in middle of arena, players scattered around. Does an inital radar pulse to detect player locations, foreach location shoots a missile at that location
--The next radar pulse detects players location and pulses again to detect changes, foreach player a homing missile is shot which slowly and poorly tracks the player

--The third radar pulse locks onto player location, no longer dmgs but shoots powerful homing missiles out.
--	Perhaps this isn't for every player? Nah, this phase is every player but the stun is big, dmg isn't huge, it's not flak cannon yet

--Gyro begins to equip/repair/construct his flak cannon

--From this point he selectively shoots powerful homing missiles, and will charge/swoop/dash towards players if they are hit by the missile, then active his flak cannon
--	This will normally kill the hit player, unless heals are well timed or others players come in to distribute the flak dmg between them

--Some time after this, Gyro activates his aoe attack ability, which players can avoid by getting to range

--He will largely alternate between shooting home rockets, then trying to flak cannon down someone.

--His ulti he will call down, giving players plenty of time to avoid, 

	--The location of this I dunno yet. Perhaps on a homing hit

	--Perhaps on himself,

	--Perhaps wherever maximally effective


--funcs needed:
	--Circle funcs for radar scan
	



--spells to impl

--Radar scan, various lvls, 
	--Each lvls ai is different. not simple dmg and speed
--Homing Rocket, various lvls
	--Each lvls ai is different. not simple dmg and speed

--Swoop/charge

--Flak cannon

--Ulti 
	--Targetting AI is important
	--The rest is pretty similiar to Dota. Maybe add a indicator using DebugDraw

