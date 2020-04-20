--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers


]]
--LinkLuaModifier( "", "", LUA_MODIFIER_MOTION_NONE )

fire_shell = class({})

function fire_shell:OnSpellStart()
    if IsServer() then

        -- init 
		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local hero = self:GetCaster()

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

        -- init vars for proj movement 
		-- can link to KV
		-- raidus needs to match projectile 100 is not worked out
		local radius = 100
		local projectile_speed = 300
		
		-- table init
		local tProjectile = {}
		local tProjectilesDirection = {}
		local tProjectilesLocation = {}

		tProjectilesDirection = {	vFrontRightDirection, vFrontLeftDirection, vBackRightDirection, vBackLeftDirection,
									vFrontDirection, vBackDirection, vRightDirection, vLeftDirection			}

		tProjectilesLocation = {	vFrontRightLocation, vFrontLeftLocation, vBackRightLocation, vBackLeftLocation,
									vFrontLocation, vBackLocation, vRightLocation, vLeftLocation						}
		
		for _, direction in ipairs(tProjectilesDirection) do
			for _, location in ipairs(tProjectilesLocation) do
				local hProjectile = {
					EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", --"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_spear.vpcf",
					vSpawnOrigin = location,
					fDistance = 2000, 
					fStartRadius = radius,
					fEndRadius = radius,
					Source = caster,
					vVelocity = direction * projectile_speed,
					UnitBehavior = PROJECTILES_NOTHING,
					bMultipleHits = true,
					-- investigate this treebehavior and see what we can do
					TreeBehavior = PROJECTILES_NOTHING,
					WallBehavior = PROJECTILES_DESTROY,
					GroundBehavior = PROJECTILES_FOLLOW,
					fGroundOffset = 80,
					draw = true,
					UnitTest = function(_self, unit) return unit:GetTeamNumber() ~= hero:GetTeamNumber() end,
					OnUnitHit = function(_self, unit) 
						if unit ~= nil and (unit:GetUnitName() ~= nil) then

						end
					end,
					OnWallHit = function(self, gnvPos) 
						
					end,
					OnFinish = function(_self, pos)
						
					end,
					OnTreeHit = function(self, tree) 
					
					end,
				}

				table.insert(tProjectile, hProjectile)

			end
		end

		for _, projectile in ipairs(tProjectile) do
			Projectiles:CreateProjectile(projectile)
		end
    end
end


