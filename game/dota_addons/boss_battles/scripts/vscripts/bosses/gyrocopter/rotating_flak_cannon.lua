rotating_flak_cannon = class({})

--gyro rotates, either 
function rotating_flak_cannon:OnSpellStart()
	print("rotating_flak_cannon:OnSpellStart()")
	_G.IsGyroBusy = true
	-- check _G.rotating_flak_cannon_direction for clockwise or counterclockwise

	--TODO: put this in txt file and implement both versions. 
	if _G.rotating_flak_cannon_direction == "clockwise" then
		--clockwise = yawAcceleration = yawAcceleration + yawIncrement
		--but need to change the yawLastDetectionThreshold method too
	end
	if _G.rotating_flak_cannon_direction == "counterclockwise" then

	end

	local caster = self:GetCaster()

	local duration = 10

	local timerDelay = 0.1
	local totalTicks = duration / timerDelay
	local currentTick = 0

	--UNTESTED: not sure if this is the right way to get Gyros current orientaiton..
	local yawAcceleration = 0.5
	local yawIncrement = 0.1
	local minYaw = 0.15

	local length = 2000

	--pitch incrementing pitch makes the model face downwards. decrementing would tilt upwards
	--yaw incrementing yaw makes the model rotate counter-clockwise. decrementing would rotate clockwise
	--roll. does nothing. Thanks valve.
	-- local pitch = 0.0
	-- local yaw = 0.0
	-- local roll = 0.0 -- does nothing, with the gyro model? or in general?
	-- --thisEntity:SetAngles(pitch, yaw, roll)

	local yawAtLastEnemyDetection = caster:GetAnglesAsVector().y
	local yawLastDetectionThreshold = 180

	local color = Vector(255,0,0)
	Timers:CreateTimer(function()
		currentTick = currentTick + 1
		print("caster yaw = ", caster:GetAnglesAsVector().y)
		print("yawAtLastEnemyDetection = ", yawAtLastEnemyDetection)

		local endPoint = (caster:GetForwardVector() * length) + caster:GetAbsOrigin()

		DebugDrawLine_vCol(caster:GetAbsOrigin(), endPoint, color, true, 0.5)

		--check if unit in line from forward vector to length
		local enemies = FindUnitsInLine(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), endPoint, caster, 3, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE )
		if #enemies > 0 then
			yawAtLastEnemyDetection = caster:GetAnglesAsVector().y

			--degree rate of rotation...
			if yawAcceleration > minYaw then
				--yawAcceleration = yawAcceleration - (yawIncrement*4)
				yawAcceleration = minYaw
			end

			-- attack each enemy
			for _,enemy in pairs(enemies) do
				--TODO: new attack, shoot flame projectile  
				-- and onhit apply  burning modifier


				-- add the enemy to the target list
				_G.FlakCannonTargets[#_G.FlakCannonTargets +1] = enemy

				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = caster:FindAbilityByName("rotating_flak_cannon_attack"):entindex(),
					Queue = false, -- I want to set this to queue = true, but when the boss is attacking then this wont work
				})
			end
						
		end

		--no enemies. continue rotating... faster and faster 
		caster:SetAngles(caster:GetAnglesAsVector().x, caster:GetAnglesAsVector().y + yawAcceleration, 0)
		--increase yawAcceleration slightly
		yawAcceleration = yawAcceleration + yawIncrement

		--TODO:
		--if yawAcceleration reaches some threshold...
		if (caster:GetAnglesAsVector().y - yawAtLastEnemyDetection) > 180 then
			print("havent detected an enemy for 180 degrees! TODO something!")
		end

		return timerDelay
	end)
end
