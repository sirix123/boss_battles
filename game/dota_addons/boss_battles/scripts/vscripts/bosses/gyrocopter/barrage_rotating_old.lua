barrage_rotating = class({})

local duration = 20 -- seconds

local range = 1500

local rotationBeforeStack = 90 --rotate this many degrees without finding an enemy, add one stack
local currentStacks = 0
local velocityPerStack = 1

local currentVelocity = 2 -- goes down when enemy found, goes up when no enemy

local defaultVelocityIncrement = 0.05


function barrage_rotating:OnSpellStart()
	print("barrage_rotating:OnSpellStart()")

	local currentTick = 0

	--Start a timer which will; rotate gyro, check for units in line, 
		-- if units, shoot,
		-- else rotate faster
	-- if a certain rotate speed is reached... WHIRLWIND / TAKE OFF (todo: define what this means)



	--NEW CODE to replace
	local currentDirection = 0 --TODO: get this from the units current forward vector.


	--OLD CODE from gyro.lua
	local currentRotation = 0
	local rotationVelocity = 2

	local minSpeed = 0.05
	local maxSpeed = 45
	local rotationSpeed = minSpeed


	local tickInterval = 0.1
	local totalTicks = duration / tickInterval
	Timers:CreateTimer(function()	
		currentTick = currentTick +1	
		if (currentTick == totalTicks) then return end --final tick, stop the timer

		--NEW CODE to replace:



		--OLD CODE from gyro.lua
		-- Calculate a new position based on an angle and length
		currentRotation =  currentRotation + rotationVelocity
		local radAngle = currentRotation * 0.0174532925 --angle in radians
		local point = Vector(length * math.cos(radAngle), length * math.sin(radAngle), 0)
		local endPoint = point + thisEntity:GetAbsOrigin()

		--rotate gyro:
		local newForwardVector = Vector(0,0,0)
		local rotated = RotatePosition(Vector(0,0,0), QAngle(0,currentRotation,0), Vector(1,0,0))  
		thisEntity:SetForwardVector(rotated)

		--IMPL 1; test rotating gyro at a fixed speed
		--IMPL 2; test speeding up gyros rotation, determine good amount to speed up by (linear or some curve, max speed?
		--IMPL 3; test slowing down / stopping when detecting player
		--IMPL 4; test stacks/modifier after x degrees with no unit


		return tickInterval
	end) --end timer


end






function WhirlWind(pushEnemyAway)
	_G.IsGyroBusy = true

	-- "gyrocopter_gyro_attack_15" "gyrocopter: C'mere you!"
	thisEntity:EmitSound("gyrocopter_gyro_attack_15")

	--print("WhirlWind() called")
	thisEntity:SetBaseMoveSpeed(flyingMs)
	
	local radius = 9999

	local duration = wwsuckDuration -- seconds
	local tickInterval = 0.05
	local totalTicks = duration / tickInterval
	local currentTick = 1

	local velocity = 0
	local velocityIncrement = 200 * tickInterval

	local currentAngle = 0
	local angleIncrement = 200 * tickInterval
	local zIncrement = 50 * tickInterval

	local length = 200
	local lengthIncrement = 2

	-- print("angleIncrement = ", angleIncrement)
	-- print("velocityIncrement = ", velocityIncrement)
	-- print("totalTicks = ", totalTicks)

	Timers:CreateTimer(function()
		currentTick = currentTick +1

		-- during whirlwind play these:
		-- "gyrocopter_gyro_move_29" "gyrocopter: Meeeeoooooooowwwwnnn!"
		-- "gyrocopter_gyro_move_30" "gyrocopter: Eeeooooownnn!"
		-- "gyrocopter_gyro_move_31" "gyrocopter: Sshhhhhhzzzoooo!"
		-- "gyrocopter_gyro_move_32" "gyrocopter: Mmmmmw!"
		if (totalTicks / 4) == currentTick then
			thisEntity:EmitSound("gyrocopter_gyro_move_29")
		end
		--HACK: coz totalTicks / 3 isn't a whole number. it's 46.666666667
		--if (totalTicks / 3) == currentTick then
		if currentTick == 47 then
			thisEntity:EmitSound("gyrocopter_gyro_move_30")
		end
		if (totalTicks / 2) == currentTick then
			thisEntity:EmitSound("gyrocopter_gyro_move_31")
		end
		if currentTick == 100 then 
			thisEntity:EmitSound("gyrocopter_gyro_move_32")
		end


		--start casting CallDown before the end of whirlwind
		local cooldownLeadTime = 3 / tickInterval --ticks in 3 seconds
		if currentTick + cooldownLeadTime == totalTicks then
			if not pushEnemyAway then
				--calldown on gyros current position
				CastCallDownAt(thisEntity:GetAbsOrigin())
				--InstantlyCastCallDownAt(thisEntity:GetAbsOrigin())
			else 
				--calldown in ring/aoe around gyro, but not immediately on him
				--TODO: calldown pattern of some sort..
			end
		end

		--At the end of whirlwind, return gyro to ground level.
		if currentTick == totalTicks then
			thisEntity:SetBaseMoveSpeed(normalMs)
			Timers:CreateTimer(function()
				if thisEntity:GetAbsOrigin().z > 300 then
					thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(0,0 -30))
					return 0.05
				else
					--wait a second in case still moving then unset IsGyroBusy
					Timers:CreateTimer({
						endTime = 0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
						callback = function()
							_G.IsGyroBusy = false 
							return
						end
					})
					return
				end
			end)
			return 
		end

		--update ability model
		length = length + lengthIncrement
		velocity = velocity + velocityIncrement
		thisEntity:SetBaseMoveSpeed(flyingMs+velocity)

		-- Calculate a new position based on an angle and length
		currentAngle =  currentAngle + angleIncrement
		local radAngle = currentAngle * 0.0174532925 --angle in radians
		local point = Vector(length * math.cos(radAngle), length * math.sin(radAngle), 0)
		local endPoint = point + thisEntity:GetAbsOrigin()


		-- increment z.. doesn't seem to work. Unit can't move to z axis.
		--endPoint = endPoint + Vector(0,0,1000)
		thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(0,0,zIncrement)) --force increase on z axis
		thisEntity:MoveToPosition(endPoint)
		
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		--Pull all units toward gyro:
		for _,enemy in pairs(enemies) do
			local diff = thisEntity:GetAbsOrigin() - enemy:GetAbsOrigin()
			if pushEnemyAway then
				--Push the unit away from gyro:
				diff = enemy:GetAbsOrigin() - thisEntity:GetAbsOrigin()
			end
			local diffIncr = diff:Normalized() * 25
			enemy:SetAbsOrigin(enemy:GetAbsOrigin() + diffIncr)
		end
		return tickInterval
	end)
end

