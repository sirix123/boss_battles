swoop = class({})

--TODO: put these vars into kvp txt file
-- Gyro moves toward target, crashing into it upon arrival
function swoop:OnSpellStart()
	--print("swoop:OnSpellStart()")
	_G.IsGyroBusy = true

	local caster = self:GetCaster()
	local swoopSpeed = self:GetSpecialValueFor("swoop_speed")
	local radius = self:GetSpecialValueFor("radius")
	local dmg = self:GetSpecialValueFor("damage")
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local collisionDist  = self:GetSpecialValueFor("collision_distance")

	--Use the below for abilities that are: DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	--local target = self:GetCursorTarget():GetAbsOrigin()

	--Use the below for abilities that are: DOTA_ABILITY_BEHAVIOR_POINT
	local target = self:GetCursorPosition()
	--DebugDrawCircle(target, Vector(255,0,0), 128, 100, true, 1)

	local originalMs = self:GetCaster():GetBaseMoveSpeed()
	caster:SetBaseMoveSpeed(swoopSpeed)
	local distance = (target - caster:GetAbsOrigin()):Length2D()
	local travelTime = distance / caster:GetBaseMoveSpeed()

	--tilt gyro's nose 25 degrees down, so he aiming at the ground
	caster:SetAngles(25,0,0)
	caster:MoveToPosition(target)

	local enemiesAlreadyHit = {}
	Timers:CreateTimer(function()
		local distance = (target  - caster:GetAbsOrigin()):Length2D()

		-- check for any units within collision radius, if any, hit them and add to hitlist to prevent second hit..
		--they take half damage.  
		local runOverEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, collisionDist*2, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		for _,enemy in pairs(runOverEnemies) do
			
			-- check that enemy is in enemiesAlreadyHit.
			local enemyAlreadyHit = false
			if #enemiesAlreadyHit > 0 then
				for i = 1, #enemiesAlreadyHit do 
					if enemiesAlreadyHit[i] == enemy then
						enemyAlreadyHit = true
					end
				end
			end
			--only damage enemies not already hit
			if not enemyAlreadyHit then
				local dmgTable =
	            {
	                victim = enemy,
	                attacker = caster,
	                damage = dmg/2,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	            }
	            ApplyDamage(dmgTable)
				enemiesAlreadyHit[#enemiesAlreadyHit+1] = enemy

				--TODO: apply daze?

			end
		end

		--gyro arrived at target		
		if (distance <= collisionDist) then
			--reset ms to original ms
			self:GetCaster():SetBaseMoveSpeed(originalMs)

			--DEBUG
			--DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 128, 100, true, 1)

			--find enemies in range and dmg them and stun
			local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

			for _,enemy in pairs(enemies) do 
				-- damage enemies in radius
	            local dmgTable =
	            {
	                victim = enemy,
	                attacker = caster,
	                damage = dmg,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	            }
	            ApplyDamage(dmgTable)
				-- stun enemies in radius
				enemy:AddNewModifier(
					caster, -- caster source
					self, -- ability source
					"modifier_generic_stunned", -- modifier name
					{ duration = stunDuration } 
				)
				
	        end
	        -- stun gyro too? but then _G.IsGyroBusy needs to continue until unstunned
			self:GetCaster():AddNewModifier(
					caster, -- caster source
					self, -- ability source
					"modifier_generic_stunned", -- modifier name
					{ duration = stunDuration } 
				)

			-- delay until the end of stun duration before resetting IsGyroBusy
			Timers:CreateTimer(stunDuration, function()
		        _G.IsGyroBusy = false	
		        return
			end)
			caster:SetAngles(0,0,0)
        	return --stop timer, ability ended.
		end
		return 0.05 --continue timer, gyro still flying
	end)
end
