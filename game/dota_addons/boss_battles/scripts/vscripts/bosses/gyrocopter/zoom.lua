zoom = class({})


-- Gyro moves toward target, leaving behind a trail
function zoom:OnSpellStart()
	_G.IsGyroBusy = true
	local target = self:GetCursorTarget()

	local zoomSpeed = 1200
	local originalMs = self:GetCaster():GetBaseMoveSpeed()
	self:GetCaster():SetBaseMoveSpeed(zoomSpeed)

	local radius = 250
	local collisionDist = 70 --stop the timer and apply effects once gyro is within this distance of target
	
	local distance = (target - self:GetCaster():GetAbsOrigin()):Length2D()
	local travelTime = distance / self:GetCaster():GetBaseMoveSpeed()

	--tilt gyro's nose 25 degrees up, so he's aiming up as he flies away
	self:GetCaster():SetAngles(-25,0,0)
	self:GetCaster():MoveToPosition(target)


	Timers:CreateTimer(function()
		local distance = (location - self:GetCaster():GetAbsOrigin()):Length2D()

		--TODO: each tick, place a puddle behind gyro.

		--gyro arrived at location, ignite puddles on fire		
		if (distance <= collisionDist) then
			--reset ms to original ms
			self:GetCaster():SetBaseMoveSpeed(originalMs)

			--todo: ignite puddles on fire

	        _G.IsGyroBusy = false
        	return --stop timer, ability ended.
		end

		return 0.05 --continue timer, gyro still flying
	end)

end


function swoop:OnSpellStart()

	Timers:CreateTimer(function()
		local distance = (location - self:GetCaster():GetAbsOrigin()):Length2D()

		--gyro arrived at location		
		if (distance <= collisionDist) then
			--reset ms to original ms
			self:GetCaster():SetBaseMoveSpeed(originalMs)

			--DEBUG
			DebugDrawCircle(self:GetCaster():GetAbsOrigin(), Vector(255,0,0), 128, 100, true, 1)

			--find enemies in range and dmg them and stun
			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetCaster():GetAbsOrigin(), nil, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

			for _,enemy in pairs(enemies) do 
				--damage
	            local dmgTable =
	            {
	                victim = enemy,
	                attacker = self:GetCaster(),
	                damage = dmg,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	            }
	            ApplyDamage(dmgTable)
				-- stun
				enemy:AddNewModifier(
					self:GetCaster(), -- caster source
					self, -- ability source
					"modifier_generic_stunned", -- modifier name
					{ duration = stunDuration } -- kv
				)
	        end
	        _G.IsGyroBusy = false
        	return --stop timer, ability ended.
		end
		return 0.05 --continue timer, gyro still flying
	end)
end