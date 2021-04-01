whirlwind_attack = class({})
LinkLuaModifier( "whirlwind_burn_modifier", "bosses/gyrocopter/whirlwind_burn_modifier", LUA_MODIFIER_MOTION_NONE )

_G.WhirlwindProjectiles = {}
_G.WhirlWindAttackParticles = {}
function whirlwind_attack:OnSpellStart()
	self.radius = self:GetSpecialValueFor("radius")
	self.burnInterval = self:GetSpecialValueFor("burn_damage_interval")
	self.burnDuration = self:GetSpecialValueFor("burn_duration")

	--same same
	self.caster = self:GetCaster()
	local caster = self:GetCaster()

	-- grab target from _G.WhirlwindTargets[1], remove it, shoot at it
	if #_G.WhirlwindTargets > 0 then
		-- target is a vector
		self.target = _G.WhirlwindTargets[1]

		--remove [1] and reorder the list
		for i = 1, #_G.WhirlwindTargets, 1 do 
			if _G.WhirlwindTargets[i+1] ~= nil then 
				_G.WhirlwindTargets[i] = _G.WhirlwindTargets[i+1]
			else
				_G.WhirlwindTargets[i] = nil
			end
		end

		local noZVelocity = Vector(caster:GetForwardVector().x, caster:GetForwardVector().y, 0) * 1800
		local distance = (self.target - caster:GetAbsOrigin()):Length2D()
		local info =
		{
			Ability = self,
	    	EffectName = "particles/gyrocopter/phoenix_base_attack.vpcf",
	    	vSpawnOrigin = caster:GetAbsOrigin(),
	    	fDistance = distance,
	    	fStartRadius = 64,
	    	fEndRadius = 64,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = noZVelocity,
			bProvidesVision = true,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)

		_G.WhirlwindProjectiles[#_G.WhirlwindProjectiles +1] = projectile
	else
		print("whirlwind_attack cast, but no targets found in _G.WhirlwindTargets")
	end
end


function whirlwind_attack:OnProjectileHit( hTarget, vLocation)
	--vLocation has location, hTarget is nil. 

	--DEBUG:
	--DebugDrawCircle(vLocation,Vector(255,0,0),128,self.radius,true,10)

	--particle: a fire patch on the ground
	local particle_cast = "particles/gyrocopter/fire_patch_b.vpcf"
	local pfx = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self.caster  )
	ParticleManager:SetParticleControl( pfx, 0, vLocation )

	--add particle to global table so it can be cleaned up/destroyed in different file. whirlwind.lua
	_G.WhirlWindAttackParticles[#_G.WhirlWindAttackParticles +1] = pfx
	--Track the location of the fires. Has start and end location because it will later spread
	_G.FireLocations[#_G.FireLocations+1] = {}
	_G.FireLocations[#_G.FireLocations].StartLocation = vLocation
	_G.FireLocations[#_G.FireLocations].EndLocation = vLocation

	--start a timer which continues to check if a unit walks into the fire. stop when fire destroyed.
	Timers:CreateTimer(function()
		--stop condition:
		if _G.WhirlwindRotationComplete then return end

		local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, vLocation, nil, self.radius,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		for _,enemy in pairs(enemies) do
	        self:ApplyBurnModifier(enemy)
		end
		return self.burnInterval
	end)

end

-- Applys the burn modifier, and removes it after duration. 
-- Adds the modifier if the enemy doesn't have it, increments it if they do have it.
-- Starts a timer to remove the modifier 
function whirlwind_attack:ApplyBurnModifier(enemy)
    if enemy:HasModifier("whirlwind_burn_modifier") then -- has modifier, increment it.
    	local currBurnStacks = enemy:GetModifierStackCount("whirlwind_burn_modifier", self.caster)
		enemy:SetModifierStackCount("whirlwind_burn_modifier", self.caster, currBurnStacks +1)        	
	else -- no modifier yet, add it
		enemy:AddNewModifier(self:GetCaster(), self, "whirlwind_burn_modifier", {}) -- can pass kvp values in the final param	
    end
    --Decrease stacks after burnDuration
	Timers:CreateTimer(self.burnDuration, function()
		if enemy:HasModifier("whirlwind_burn_modifier") then
			local currBurnStacks = enemy:GetModifierStackCount("whirlwind_burn_modifier", self.caster)
			if currBurnStacks > 0 then
				enemy:SetModifierStackCount("whirlwind_burn_modifier", self.caster, currBurnStacks -1)        	
			end
		end		
		return 
	end)
end


