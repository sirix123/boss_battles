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

function fire_shell:OnAbilityPhaseStart()
    if IsServer() then
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.0)
		return true
    end
end

function fire_shell:OnSpellStart()
	if IsServer() then

        -- init
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()

		-- init (KV)
		local radius = self:GetSpecialValueFor( "radius" )
		local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
		self.destroy_tree_radius = 50

		-- table init
		local tProjectilesDirection = {}

		-- wave init (KV)
		local nWaves = 0
		local nMaxWaves = self:GetSpecialValueFor( "nMaxWaves" )
		--print(nMaxWaves)
		local fTimeBetweenWaves = self:GetSpecialValueFor( "fTimeBetweenWaves" )
		local firstWave = true
		local nMinProjPerWave = self:GetSpecialValueFor( "nMinProjPerWave" )
		local nMaxProjPerWave = self:GetSpecialValueFor( "nMaxProjPerWave" )

		caster:AddNewModifier( caster, self, "fire_shell_modifier", { duration = 1 + (nMaxWaves * fTimeBetweenWaves) } )

		-- play sound on spell start
		--EmitSoundOn("lone_druid_lone_druid_kill_13", self:GetCaster())
		EmitSoundOn("shredder_timb_kill_16", caster)

		-- start of the main loop
		Timers:CreateTimer(1, function()
			if nWaves == nMaxWaves then
				self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
				return false
			end

			if nWaves == math.ceil(nMaxWaves / 2) then
				EmitSoundOn("shredder_timb_chakram_06", caster)
			end

			-- start timer to track proj z axis 
			if firstWave == true then
				firstWave = false
			end

			-- new wave init
			nWaves = nWaves + 1

			-- generate random directions, fill table with them
			local nProjectilesPerWave = RandomInt(nMinProjPerWave, nMaxProjPerWave)

			for i = 1, nProjectilesPerWave, 1 do
				local vRandomDirection = Vector(	RandomFloat( -1 	, 1 ), RandomFloat( -1 , 1 ), 0 ):Normalized()
				table.insert(tProjectilesDirection, vRandomDirection)
			end

			--Loop over both the Direction and Location and create a projectile for each direction/location combination
			--as long as tProjectilesDirection and tProjectilesLocation have the same count and are in the same order this will work. 
			for i = 1, #tProjectilesDirection, 1 do

				local projectile = {
					EffectName = "particles/timber/ltimber_fireshell_inear_lina_base_attack.vpcf", --particles/tinker/iceshot__invoker_chaos_meteor.vpcf particles/tinker/blue_tinker_missile.vpcf
					vSpawnOrigin = origin,
					fDistance = 2000,
					fUniqueRadius = radius,
					Source = caster,
					vVelocity = tProjectilesDirection[i] * projectile_speed,
					UnitBehavior = PROJECTILES_DESTROY,
					TreeBehavior = PROJECTILES_NOTHING,
					WallBehavior = PROJECTILES_DESTROY,
					GroundBehavior = PROJECTILES_NOTHING,
					fGroundOffset = 80,
					draw = false,
					UnitTest = function(_self, unit)
						return unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true and unit:GetTeamNumber() ~= caster:GetTeamNumber()
					end,
					OnUnitHit = function(_self, unit)

						local damage = self:GetSpecialValueFor( "damage" )

						-- init dmg table
						local damageTable = {
							victim = unit,
							attacker = caster,
							damage = damage,
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}

						ApplyDamage( damageTable )

						local particle_cast = "particles/units/heroes/hero_lina/lina_base_attack_explosion.vpcf"
						local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
						ParticleManager:SetParticleControl(effect_cast, 0, unit:GetAbsOrigin())
						ParticleManager:SetParticleControl(effect_cast, 3, unit:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(effect_cast)

					end,
					OnFinish = function(_self, pos)

						--
						local particle_cast = "particles/units/heroes/hero_lina/lina_base_attack_explosion.vpcf"
						local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
						ParticleManager:SetParticleControl(effect_cast, 0, pos)
						ParticleManager:SetParticleControl(effect_cast, 3, pos)
						ParticleManager:ReleaseParticleIndex(effect_cast)

					end,
				}

				Projectiles:CreateProjectile(projectile)

			end

			return fTimeBetweenWaves
		end)
	end
end
------------------------------------------------------------------------------------------------