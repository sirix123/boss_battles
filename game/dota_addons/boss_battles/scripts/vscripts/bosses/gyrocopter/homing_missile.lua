homing_missile = class({})


local tracking_interval = 0.1
function homing_missile:OnSpellStart()
	print("homing_missile:OnSpellStart()")
	
    local caster = self:GetCaster()
	-- gets target for ability
	local target = self:GetCursorTarget()

	if target == nil then
		return
	end

    --Calculate direction of the rocket, using target position and caster position. 
    local vec_distance = target:GetAbsOrigin() - caster:GetAbsOrigin()
    local distance = (vec_distance):Length2D()
    local direction = (vec_distance):Normalized()

	-- make a copy of the targets location coords, when the targets moves these coords remain the same
	targetLocationCopy = shallowcopy(target:GetAbsOrigin())	
    local rocket = {
    	speed = 25,
    	location = self:GetCaster():GetAbsOrigin(),
    	target = target,
    	target_lastKnownLocation = targetLocationCopy,
    	direction = direction,
    }

	local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", caster:GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

    local tickCount = 0
    local collisionDistance = 100
    Timers:CreateTimer(function()     		
    		tickCount = tickCount +1
			--need to delay 3 seconds for the 'prepare' animation the missile does
			local waitAmount = 3.2 / tracking_interval  
			if tickCount < waitAmount then
				return tracking_interval;  --do nothing until the missile animation is ready to be moved.
			end				

			--update rocket's location
			rocket.location = rocket.location + rocket.direction * rocket.speed
			missile:SetAbsOrigin(rocket.location)			
			missile:SetForwardVector(rocket.direction)
    		
    		--Missile detonating at target, destroy missile, check if enemy near to apply damage.

    		-- check for collision with target. Deal damage and destroy missile
    		distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()

    		if distance < collisionDistance * 1.5 then
    			--just used any sound for now. 
    			--TODO: find the techies mine nearby sound
				EmitSoundOn( "techies_tech_mineblowsup_01", self:GetCaster() )
			end

    		if ( distance < collisionDistance  ) then
    			_G.HOMING_MISSILE_HIT_TARGET = rocket.target_lastKnownLocation
				local damageInfo = 
				{
					victim = rocket.target,
					attacker = self:GetCaster(),
					damage = 100, --TODO: calculate the dmg properly based on duration/distance.
					damage_type = 1, --DAMAGE_TYPE_PHYSICAL = 1, DAMAGE_TYPE_MAGICAL = 2
					ability = self,
				}
				ApplyDamage(damageInfo)
    			
    			local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, rocket.target )
				UTIL_Remove(missile)
    			return 
    		end

			-- DEBUG: display rocket's target. blue circle 
			DebugDrawCircle(rocket.target_lastKnownLocation, Vector(0,0,255), 128, 20, true, tracking_interval)

			--only update the rocket if an enemy has been scanned, otherwise continue on current course/direction
			if #_G.ScannedEnemyLocations > 0 then
				--update the rockets target if there is a 'new' scan of this particular enemy
				for i = 1, #_G.ScannedEnemyLocations, 1 do
					if _G.ScannedEnemyLocations[i].Enemy == rocket.target then
						if _G.ScannedEnemyLocations[i].Location == rocket.target_lastKnownLocation then --do nothing if the location is the same as last time
						else 
							-- New RadarScan occured and has updated this targets location, update the rockets target and direction
							rocket.target_lastKnownLocation = shallowcopy(_G.ScannedEnemyLocations[i].Location)
							vec_distance = rocket.target_lastKnownLocation - rocket.location
				    		distance = (vec_distance):Length2D()
				    		rocket.direction = (vec_distance):Normalized()
						end
					end
				end
			end
    		return tracking_interval;
		end) --end of timer
end -- end of homing_missile:OnSpellStart()


--TODO: easy, just FindEnemiesInRadius, sort by nearest
function homing_missile:FindNearestEnemy()
	--something like:
		local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )
end



--lvl 1:
	--Get the players location and moves toward it, exploding upon impact
	--Hits to destroy: 3
	--Same ms as player
function homing_missile:LevelOne()

end

--lvl 2:
	--Gets the players location every 2-3 seconds and moves toward it, exploding upon impact
	--Hits to destroy: 5
	--Slightly faster ms than player
function homing_missile:LevelTwo()

end

--lvl 3:
	--Gets the players location rapidly and moves toward it, exploding upon impact 
	--Hits to destroy: 5
	--Slightly faster ms than player	
function homing_missile:LevelThree()

end
--lvl 4:
	--Gets the players location and moves toward it. Checks if any other players are closer, if so it will change targets.
	--Hits to destroy: 5
	--Slightly faster ms than player	
function homing_missile:LevelFour()

end









-- some function I found on stackoverflow to:
-- pass in a table (orig) and it copys the table by value instead of by reference and returns the copied table
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
