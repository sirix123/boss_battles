gyrocopter = class({})

--ANIMATIONS/DEBUG DRAW Spells

function gyrocopter:Spawn( entityKeyValues )
	print("Gyrocopter Spawn called")



	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	self.radar_scan = thisEntity:FindAbilityByName( "radar_scan" )
	self.homing_missile = thisEntity:FindAbilityByName( "homing_missile" )
	self.flak_cannon = thisEntity:FindAbilityByName( "flak_cannon" )
	self.rocket_barrage = thisEntity:FindAbilityByName( "rocket_barrage" )


	thisEntity:SetContextThink( "Gyrocopter", GyrocopterThink, 1 )
	thisEntity:SetContextThink( "TestThinker", TestThinkerThink, 1 )




end

function gyrocopter:GyrocopterThink()
	print("gyrocopter:GyrocopterThink")
	return 1 --time between next tick?

end

function gyrocopter:TestThinkerThink()
	print("gyrocopter:TestThinkerThink")
	return 1
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
-- 		--
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






