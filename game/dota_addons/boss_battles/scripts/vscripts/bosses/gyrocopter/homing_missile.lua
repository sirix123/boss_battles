homing_missile = class({})

LinkLuaModifier( "missile_thinker", "bosses/gyrocopter/missile_thinker", LUA_MODIFIER_MOTION_NONE )
--Logic based on level:

--lvl 1:
	--Get the players location and moves toward it, exploding upon impact
	--Hits to destroy: 3
	--Same ms as player

--lvl 2:
	--Gets the players location every 2-3 seconds and moves toward it, exploding upon impact
	--Hits to destroy: 5
	--Slightly faster ms than player

--lvl 3:
	--Gets the players location rapidly and moves toward it, exploding upon impact 
	--Hits to destroy: 5
	--Slightly faster ms than player	

--lvl 4:
	--Gets the players location and moves toward it. Checks if any other players are closer, if so it will change targets.
	--Hits to destroy: 5
	--Slightly faster ms than player	


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
    	speed = 5,
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
			--print("Timer tick ", tickCount)

			--update rocket's location
			rocket.location = rocket.location + rocket.direction * rocket.speed
			--print("missile:SetAbsOrigin(rocket.location)")
			missile:SetAbsOrigin(rocket.location)			
			missile:SetForwardVector(rocket.direction)

    		-- check for collision with target
    		distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()
    		if ( distance < collisionDistance  ) then
    			_G.HOMING_MISSILE_HIT_TARGET = rocket.target
    			--TODO: deal dmg, destroy missle
    			local p = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT, rocket.target )
				UTIL_Remove(missile)
    			return --TODO: confirm this ends the timer
    		end

			-- blue = rocket's target
			DebugDrawCircle(rocket.target_lastKnownLocation, Vector(0,0,255), 128, 20, true, tracking_interval)

			--only update the rocket if an enemy has been scanned
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


-- local damageInfo = 
-- {
-- 	victim = target,
-- 	attacker = self:GetCaster(),
-- 	damage = self.base_damage,
-- 	damage_type = self:GetAbilityDamageType(),
-- 	ability = self,
-- }