--An example spell using RotatePosition to create multiple projectiles, who's velocity means they project outward at an angel from the caster
--Using timers or different for loops you can create numerous different style of spells.
vaal_fireball = class({})

local tProjectileData = {}
local tProjectileDirections = {}	
local projectile_speed = 275

function vaal_fireball:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin() 

	local angelIncrement = 10
	local currentAngel = 1
	local amountOfProjectiles = 36

	--Calculate the direction component for each projectile
	for i = 1, amountOfProjectiles, 1 do
		tProjectileDirections[i] = RotatePosition(Vector(0,0,0), QAngle(0,currentAngel,0), Vector(1,0,0)) 	--not sure what the last vector does exactly. Either Vector(1,0,0) or Vector(0,1,0) work
		currentAngel = currentAngel + angelIncrement
	end

	--Create each projectile, this will create all projectiles instantly
	for i = 1, amountOfProjectiles, 1 do
		local hProjectile = {
			Source = caster,
			Ability = self,
			vSpawnOrigin = origin,
			bDeleteOnHit = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf", 					
			fDistance = 2000,
			fStartRadius = 300,
			fEndRadius = 300,
			vVelocity = tProjectileDirections[i] * projectile_speed,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			fExpireTime = GameRules:GetGameTime() + 10.0, --seconds to keep projectile live for
			bProvidesVision = true,
			iVisionRadius = 200,
			iVisionTeamNumber = caster:GetTeamNumber(),
		}
		local projectileId = ProjectileManager:CreateLinearProjectile(hProjectile)
		local projectileInfo  = {
			projectile = projectileId,
			position = origin, --might this cause problems because it's linking the projectileInfo to the caster origin? Not sure if by ref or val
			velocity = tProjectileDirections[i] * projectile_speed,
			handleProjectile = hProjectile
		}
		table.insert(tProjectileData, projectileInfo)
	end

	--Alternatively create the projectiles with a slight delay between each one.
	-- --The below timer is effectively a for loop with a delay.
	-- local tickCount = 1	--the amount of times you want the timer for.
	-- local timerDelay = 0.25
	-- Timers:CreateTimer(function()
	-- 	tickCount = tickCount +1
	-- 	print("tickCount ", tickCount)
	-- 	if tickCount < amountOfProjectiles then
				--TODO: create hProjectile here
	-- 			local projectileId = ProjectileManager:CreateLinearProjectile(hProjectile)
	-- 			local projectileInfo  = {
	-- 				projectile = projectileId,
	-- 				position = origin,
	-- 				velocity = projectileDirections[tickCount] * projectile_speed,
	-- 				handleProjectile = hProjectile
	-- 			}
	-- 			table.insert(tProjectileData, projectileInfo)
	-- 		return timerDelay
	-- 	else
	-- 		return
	-- 	end
	-- end
	-- )
end


