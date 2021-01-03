flee = class({})

--Consider: AddFOWViewer(teamId: DOTATeam_t, location: Vector, radius: float, duration: float, obstructedVision: bool): ViewerID
--TODO: look at quillboar puddle, and leave a bunch of these behind. 
	--store the locations of em. coz after zoom, detonate them!

-- Gyro moves toward target, leaving behind a trail
function flee:OnSpellStart()
	print("flee:OnSpellStart()")
	_G.IsGyroBusy = true

	local target = self:GetCursorPosition()
	print("target = ", target)
	DebugDrawCircle(target, Vector(255,0,0), 128, 100, true, 1)
	
	local caster = self:GetCaster()

	local zoomSpeed = 1800
	local originalMs = self:GetCaster():GetBaseMoveSpeed()
	self:GetCaster():SetBaseMoveSpeed(zoomSpeed)

	local radius = 250
	local collisionDist = 70 --stop the timer and apply effects once gyro is within this distance of target'
	local dmg = 100
	
	local distance = (target - self:GetCaster():GetAbsOrigin()):Length2D()
	local travelTime = distance / self:GetCaster():GetBaseMoveSpeed()

	--tilt gyro's nose 25 degrees up, so he's aiming up as he flies away
	caster:SetAngles(-25,0,0)
	caster:MoveToPosition(target)

	local particle = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf"
	local enemiesAlreadyHit = {}
	local previousPosition = nil
	local puddles = {}
	Timers:CreateTimer(function()
		local distance = (target - caster:GetAbsOrigin()):Length2D()

		if previousPosition ~= nil then
			--Place a puddle at gyros current position.
			--TODO: make it so it places it at gyro's previous position. So it's behind him instead of in front
			local puddle = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN , caster  )
			ParticleManager:SetParticleControl( puddle, 0, caster:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex( puddle )
			puddles[#puddles+1] = puddle
		end

		local runOverEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetCaster():GetAbsOrigin(), nil, collisionDist*2, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
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
	                attacker = self:GetCaster(),
	                damage = dmg/2,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	            }
	            ApplyDamage(dmgTable)
				enemiesAlreadyHit[#enemiesAlreadyHit+1] = enemy
			end
		end

		--gyro arrived at location, ignite puddles on fire		
		if (distance <= collisionDist) then
			--reset ms to original ms
			self:GetCaster():SetBaseMoveSpeed(originalMs)

			--todo: ignite puddles on fire
			print("Zoom ended. #Puddles = ", #puddles)

	        _G.IsGyroBusy = false
        	return --stop timer, ability ended.
		end

		previousPosition = caster:GetAbsOrigin()
		return 0.1 --continue timer, gyro still flying
	end)

end
