vaal_fireball = class({})




function vaal_fireball:OnSpellStart()
	print("VAAL FIREBALL!")
	
	local caster = self:GetCaster()

	projectileDirections = {}	

	local angelIncrement = 45
	local currentAngel = 45
	for i = 1, 8, 1 do
		projectileDirections[i] = caster:GetAbsOrigin() + RotatePosition(Vector(0,0,0), QAngle(0,currentAngel,0), caster:GetForwardVector()) 

		currentAngel = currentAngel + angelIncrement
	end


	for i = 1, #projectileDirections, 1 do

				local hProjectile = {
					Source = caster,
					Ability = self,
					vSpawnOrigin = caster:GetAbsOrigin(),
					bDeleteOnHit = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					EffectName = "particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf", --"particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf", 
					fDistance = 9000,
					fStartRadius = radius,
					fEndRadius = radius,
					vVelocity = tProjectilesDirection[i] * projectile_speed,
					bHasFrontalCone = false,
					bReplaceExisting = false,
					fExpireTime = GameRules:GetGameTime() + 30.0,
					bProvidesVision = true,
					iVisionRadius = 200,
					iVisionTeamNumber = caster:GetTeamNumber(),
				}

				local projectileId = ProjectileManager:CreateLinearProjectile(hProjectile)

				local projectileInfo  = {
					projectile = projectileId,
					position = tProjectilesLocation[i],
					velocity = tProjectilesDirection[i] * projectile_speed,
					handleProjectile = hProjectile
				}

				table.insert(tProjectileData, projectileInfo)
				
			end

end