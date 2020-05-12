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

		local vFrontRightLocation 	= 	origin + 	(( vFrontDirection 		+ vRightDirection ) 	* offset )
		local vFrontLeftLocation 	= 	origin + 	(( vFrontDirection 		+ vLeftDirection ) 		* offset )
		local vBackRightLocation 	= 	origin + 	(( - vFrontDirection 	+ vRightDirection ) 	* offset )
		local vBackLeftLocation 	= 	origin + 	(( - vFrontDirection 	+ vLeftDirection ) 		* offset )

		local vFrontLocation 		= 	origin + 	( vFrontDirection 		* offset )
		local vBackLocation 		= 	origin + 	( - vFrontDirection 	* offset )
		local vRightLocation 		= 	origin +	( vRightDirection  		* offset )
		local vLeftLocation 		= 	origin + 	( - vRightDirection  	* offset )
]]


LinkLuaModifier( "fire_shell_thinker", "bosses/timber/fire_shell_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "fire_shell_modifier", "bosses/timber/fire_shell_modifier", LUA_MODIFIER_MOTION_NONE )

fire_shell = class({})

local tProjectileData = {}

function fire_shell:OnSpellStart()
	if IsServer() then

        -- init
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()

		self.damage = 100

		-- init dmg table
		self.damageTable = {
			attacker = self.caster,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}

		-- init (KV)
		local radius = 300
		local projectile_speed = 1000
		self.destroy_tree_radius = 50

		-- table init
		local tProjectilesDirection = {}

		-- wave init (KV)
		local nWaves = 0
		local nMaxWaves = 4
		local fTimeBetweenWaves = 0.8
		local firstWave = true

		caster:AddNewModifier( caster, self, "fire_shell_modifier", { duration = 1 + (nMaxWaves * fTimeBetweenWaves) } )

		-- play sound on spell start
		--EmitSoundOn("lone_druid_lone_druid_kill_13", self:GetCaster())
		EmitSoundOn("shredder_timb_kill_16", caster)

		-- start of the main loop
		Timers:CreateTimer(1, function()
			if nWaves == nMaxWaves then
				return false
			end

			if nWaves == math.ceil(nMaxWaves / 2) then
				EmitSoundOn("shredder_timb_chakram_06", caster)
			end

			-- start timer to track proj z axis 
			if firstWave == true then
				firstWave = false
				self:StartThinkLoop()
			end

			-- new wave init
			nWaves = nWaves + 1

			-- generate random directions, fill table with them
			local nProjectilesPerWave = RandomInt(4, 6)

			for i = 1, nProjectilesPerWave, 1 do
				local vRandomDirection = Vector(	RandomFloat( -1 	, 1 ), RandomFloat( -1 , 1 ), 0 ):Normalized()
				table.insert(tProjectilesDirection, vRandomDirection)
			end

			--Loop over both the Direction and Location and create a projectile for each direction/location combination
			--as long as tProjectilesDirection and tProjectilesLocation have the same count and are in the same order this will work. 
			for i = 1, #tProjectilesDirection, 1 do

				local hProjectile = {
					Source = caster,
					Ability = self,
					vSpawnOrigin = origin,
					bDeleteOnHit = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					EffectName = "particles/timber/napalm_wave_basedtidehuntergushupgrade.vpcf", --"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf"
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
					position = origin,
					velocity = tProjectilesDirection[i] * projectile_speed,
					handleProjectile = hProjectile
				}

				table.insert(tProjectileData, projectileInfo)
				
			end

			return fTimeBetweenWaves
		end)
	end
end
------------------------------------------------------------------------------------------------

function fire_shell:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint( vLocation, self.destroy_tree_radius, true )

end
------------------------------------------------------------------------------------------------

function fire_shell:OnProjectileHit(hTarget, vLocation)

	self.damageTable.victim = hTarget
	ApplyDamage( self.damageTable )

end
------------------------------------------------------------------------------------------------

function fire_shell:StartThinkLoop()
	--[[

		this is a thinker, it will grab the proj ground pos every iteration and check to see if it is above the map floor (z256)
		if it is it will destroy it

	]]

	Timers:CreateTimer(1, function()
	if not tProjectileData or #tProjectileData == 0 then
		-- return bIsFireShellResolved = true to AI file and check if == true before casting, set to false at the top of this file
		return false
	end

	--print(#tProjectileData)
	--print("is the timer still running?")

	for k, projectileInfo in pairs(tProjectileData) do
		projectileInfo.position = projectileInfo.position + projectileInfo.velocity

		DebugDrawCircle(projectileInfo.position, Vector(0,0,255), 128, 50, true, 60)

        if GetGroundPosition(projectileInfo.position, handleProjectile).z > 256 then
			ProjectileManager:DestroyLinearProjectile(projectileInfo.projectile)
			table.remove(tProjectileData, k)
		end

	end

		return 1.5
	end)
end