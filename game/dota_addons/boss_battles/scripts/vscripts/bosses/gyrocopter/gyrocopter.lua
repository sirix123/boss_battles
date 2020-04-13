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

	thisEntity.radar_scan = thisEntity:FindAbilityByName( "radar_scan" )
	thisEntity:SetContextThink( "Gyrocopter", GyrocopterThink, 1 )
end

function gyrocopter:GyrocopterThink()
	print("gyrocopter:GyrocopterThink")
end


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





