--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers
	
		-- get directions 
			forward = 0,1,0
			back = 0,-1,0
			right = 1,0,0
			left = -1,0,0

			frontright = 0	->	1, 0   ->	1
			frontleft = -1 -> 0, 0 -> 1
			backright = 0 -> 1, -1 -> 0
			backleft = -1 -> 0, -1 -> 0

			RandomFloat(float float_1, float float_2)

		local vFrontRightDirection = caster:GetForwardVector() + caster:GetRightVector()
		local vFrontLeftDirection = caster:GetForwardVector() - caster:GetRightVector()
		local vBackRightDirection = - caster:GetForwardVector() + caster:GetRightVector()
		local vBackLeftDirection = - caster:GetForwardVector() - caster:GetRightVector()

		local vFrontDirection = caster:GetForwardVector()
		local vBackDirection = -caster:GetForwardVector()
		local vRightDirection = caster:GetRightVector()
		local vLeftDirection = -caster:GetRightVector()
]]


LinkLuaModifier( "fire_shell_thinker", "bosses/timber/fire_shell_thinker", LUA_MODIFIER_MOTION_NONE )

fire_shell = class({})

local tProjectileData = {}

function fire_shell:OnSpellStart()
    if IsServer() then

        -- init
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()

		-- init (KV)
		local radius = 100
		local projectile_speed = 500
		self.destroy_tree_radius = 150

		-- init vars for proj
		local offset = 80

		-- table init
		local tProjectilesDirection = {}
		local tProjectilesLocation = {}

		-- wave init (KV)
		local nWaves = 0
		local nMaxWaves = 5
		local fTimeBetweenWaves = 1.5

		-- start of the main loop
		Timers:CreateTimer(1, function()
			if nWaves == nMaxWaves then
				return false
			end

			-- new wave init
			nWaves = nWaves + 1

			local vFrontRightDirection 	=	Vector(	RandomFloat( 0 	, 1 ), RandomFloat( 0 , 1 ), 0 )
			local vFrontLeftDirection 	=	Vector(	RandomFloat( -1 , 0 ), RandomFloat( 0 , 1 ), 0 )
			local vBackRightDirection 	=	Vector(	RandomFloat( 0 	, 1 ), RandomFloat( -1 , 0 ), 0 )
			local vBackLeftDirection 	=	Vector(	RandomFloat( -1 , 0 ), RandomFloat( -1 , 0 ), 0 )

			local vFrontDirection 		=	Vector(	RandomFloat( -1 , 1 ), 1, 0 )
			local vBackDirection 		=	Vector(	RandomFloat( -1 , 1 ), -1, 0 )
			local vRightDirection 		=	Vector(	1, RandomFloat( -1 , 1 ), 0 )
			local vLeftDirection 		=	Vector(	-1, RandomFloat( -1 , 1 ), 0 )

			local vFrontRightLocation 	= 	origin + 	(( vFrontDirection 		+ vRightDirection ) 	* offset )
			local vFrontLeftLocation 	= 	origin + 	(( vFrontDirection 		+ vLeftDirection ) 		* offset )
			local vBackRightLocation 	= 	origin + 	(( - vFrontDirection 	+ vRightDirection ) 	* offset )
			local vBackLeftLocation 	= 	origin + 	(( - vFrontDirection 	+ vLeftDirection ) 		* offset )

			local vFrontLocation 		= 	origin + 	( vFrontDirection 		* offset )
			local vBackLocation 		= 	origin + 	( - vFrontDirection 	* offset )
			local vRightLocation 		= 	origin +	( vRightDirection  		* offset )
			local vLeftLocation 		= 	origin + 	( - vRightDirection  	* offset )

			tProjectilesDirection =
			{
				vFrontRightDirection, vFrontLeftDirection, vBackRightDirection, vBackLeftDirection,
				vFrontDirection, vBackDirection, vRightDirection, vLeftDirection
			}

			tProjectilesLocation =
			{
				vFrontRightLocation, vFrontLeftLocation, vBackRightLocation, vBackLeftLocation,
				vFrontLocation, vBackLocation, vRightLocation, vLeftLocation
			}

			print("is the timer runinng")

			--Loop over both the Direction and Location and create a projectile for each direction/location combination
			--as long as tProjectilesDirection and tProjectilesLocation have the same count and are in the same order this will work. 
			for i = 1, #tProjectilesDirection, 1 do

				local hProjectile = {
					Source = caster,
					Ability = self,
					vSpawnOrigin = tProjectilesLocation[i],
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

			return fTimeBetweenWaves
		end)
	end

	self:StartThinkLoop()

end
------------------------------------------------------------------------------------------------

function fire_shell:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint( vLocation, self.destroy_tree_radius, true )

end
------------------------------------------------------------------------------------------------

function fire_shell:StartThinkLoop()
	--[[

		this is a thinker, it will grab the proj ground pos every iteration and check to see if it is above the map floor (z256) 
		if it is it will destroy it

	]]

	Timers:CreateTimer(1, function()
	if not tProjectileData or #tProjectileData == 0 then
		return false
	end

	--print(#tProjectileData)
	--print("is the timer still running?")

	for k, projectileInfo in pairs(tProjectileData) do
		projectileInfo.position = projectileInfo.position + projectileInfo.velocity

		--DebugDrawCircle(projectileInfo.position, Vector(0,0,255), 128, 100, true, 60)

        if GetGroundPosition(projectileInfo.position, handleProjectile).z > 256 then
			ProjectileManager:DestroyLinearProjectile(projectileInfo.projectile)
			table.remove(tProjectileData, k)
		end

	end

		return 1.5
	end)
end