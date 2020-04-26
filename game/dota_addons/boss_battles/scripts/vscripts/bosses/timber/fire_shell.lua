--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers


]]
LinkLuaModifier( "fire_shell_thinker", "bosses/timber/fire_shell_thinker", LUA_MODIFIER_MOTION_NONE )

fire_shell = class({})

function fire_shell:OnSpellStart()
    if IsServer() then

        -- init 
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()

		-- init vars for proj movement 
		-- can link to KV
		-- raidus needs to match projectile 100 is not worked out
		local radius = 100
		local projectile_speed = 500
		self.destroy_tree_radius = 50

		-- get directions 
		local vFrontRightDirection = caster:GetForwardVector() + caster:GetRightVector()
		local vFrontLeftDirection = caster:GetForwardVector() - caster:GetRightVector()
		local vBackRightDirection = - caster:GetForwardVector() + caster:GetRightVector()
		local vBackLeftDirection = - caster:GetForwardVector() - caster:GetRightVector()

		local vFrontDirection = caster:GetForwardVector()
		local vBackDirection = -caster:GetForwardVector()
		local vRightDirection = caster:GetRightVector()
		local vLeftDirection = -caster:GetRightVector()

		-- get proj spawn locations
		local offset = 80

		local vFrontRightLocation 	= 	origin + 	(( vFrontDirection 		+ vRightDirection ) 	* offset )
		local vFrontLeftLocation 	= 	origin + 	(( vFrontDirection 		+ vLeftDirection ) 		* offset )
		local vBackRightLocation 	= 	origin + 	(( - vFrontDirection 	+ vRightDirection ) 	* offset )
		local vBackLeftLocation 	= 	origin + 	(( - vFrontDirection 	+ vLeftDirection ) 		* offset )

		local vFrontLocation 		= 	origin + 	( vFrontDirection 		* offset )
		local vBackLocation 		= 	origin + 	( - vFrontDirection 	* offset )
		local vRightLocation 		= 	origin +	( vRightDirection  		* offset )
		local vLeftLocation 		= 	origin + 	( - vRightDirection  	* offset )
		
		-- table init
		--local tProjectile = {}
		local nWaves = 10
		--self.tProjectileId = {}
		local tProjectilesDirection = {}
		local tProjectilesLocation = {}

		self.tProjectileData = {}

		tProjectilesDirection = {	vFrontRightDirection, vFrontLeftDirection, vBackRightDirection, vBackLeftDirection,
									vFrontDirection, vBackDirection, vRightDirection, vLeftDirection			}

		tProjectilesLocation = {	vFrontRightLocation, vFrontLeftLocation, vBackRightLocation, vBackLeftLocation,
									vFrontLocation, vBackLocation, vRightLocation, vLeftLocation						}

		--Loop over both the Direction and Location and create a projectile for each direction/location combination
		--as long as tProjectilesDirection and tProjectilesLocation have the same count and are in the same order this will work. 
		--for j = 1, nWaves, 1 do
			for i = 1, #tProjectilesDirection, 1 do
				
				local hProjectile = {
					Source = caster,
					Ability = self,
					vSpawnOrigin = tProjectilesLocation[i],
					bDeleteOnHit = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					EffectName = "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf", --"particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", 
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
                    velocity = tProjectilesDirection[i] * projectile_speed
                }

                table.insert(self.tProjectileData, projectileInfo)
			end
		--end
	end

	self:StartThinkLoop()

end
------------------------------------------------------------------------------------------------

function fire_shell:StartThinkLoop()
  Timers:CreateTimer(1, function()
    if not self.tProjectileData or self.tProjectileData == {} then return false end

	for k, projectileInfo in pairs(self.tProjectileData) do
		projectileInfo.position = projectileInfo.position + projectileInfo.velocity

        if GetGroundPosition(projectileInfo.position, nil).z > 256 then
			ProjectileManager:DestroyLinearProjectile(projectileInfo.projectile)
			table.remove(self.tProjectileData, k)
		end

	end

	return 1
	end)
end
