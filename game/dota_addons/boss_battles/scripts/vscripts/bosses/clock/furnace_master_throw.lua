furnace_master_throw = class({})

function furnace_master_throw:OnAbilityPhaseStart()
	if IsServer() then

		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()

		-- find all 4 furances
		local tFurnaceLocations = {}

		local units = FindUnitsInRadius(
			DOTA_TEAM_BADGUYS,
			origin,
			nil,
			5000,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false )

		if #units == 0 then
			return 0
		end

		for _, unit in pairs(units) do
			if unit:GetUnitName() == "furnace" then
				table.insert(tFurnaceLocations, unit:GetAbsOrigin() )
			end
		end

		self.attach = caster:ScriptLookupAttachment( "attach_attack2" )
		self.vSpawnLocation = caster:GetAttachmentOrigin( self.attach )

		-- furnace furthest away from golem/player
		local previous_compare_distance = 0
		self.furthestFurnace = Vector(0,0,0)
		for _, furnace in pairs(tFurnaceLocations) do
			local compareDistance = ( furnace - self.vSpawnLocation ):Length2D()
			if compareDistance > previous_compare_distance then
				previous_compare_distance = compareDistance
				self.furthestFurnace = furnace
			end
		end

		local direction = (Vector( self.furthestFurnace.x - origin.x, self.furthestFurnace.y - origin.y, 0 )):Normalized()
		caster:SetForwardVector(direction)

	end
	return true
end

--------------------------------------------------------------------------------

function furnace_master_throw:OnAbilityPhaseInterrupted()
	if IsServer() then

	end
end
--------------------------------------------------------------------------------

function furnace_master_throw:OnSpellStart()
	if IsServer() then
		self.hBuff = self:GetCaster():FindModifierByName( "furnace_master_grabbed_buff" )
		if self.hBuff == nil then
			return false
		end

		self.hThrowTarget = self.hBuff.hThrowObject
		if self.hThrowTarget == nil then
			self:GetCaster():RemoveModifierByName( "furnace_master_grabbed_buff" )
			return false
		end

		self.hThrowBuff = self.hThrowTarget:FindModifierByName( "furnace_master_grab_debuff" )
		if self.hThrowBuff == nil then
			self:GetCaster():RemoveModifierByName( "furnace_master_grabbed_buff" )
			return false
		end

		self.throw_speed = self:GetSpecialValueFor( "throw_speed" ) --500
		self.impact_radius = self:GetSpecialValueFor( "impact_radius" ) --100

		self.vDirection = self.furthestFurnace - self.vSpawnLocation
		self.flDist = self.vDirection:Length2D()
		self.vDirection.z = 0.0
		self.vDirection = self.vDirection:Normalized()
		self.vEndPos = self.vSpawnLocation + self.vDirection * self.flDist

		local info = {
			EffectName = "",
			Ability = self,
			vSpawnOrigin = self.vSpawnLocation, 
			fStartRadius = self.impact_radius,
			fEndRadius = self.impact_radius,
			vVelocity = self.vDirection * self.throw_speed,
			fDistance = self.flDist,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		}

		self.hThrowBuff.nProjHandle = ProjectileManager:CreateLinearProjectile( info )
		self.hThrowBuff.flHeight = self.vSpawnLocation.z - GetGroundHeight( self:GetCaster():GetOrigin(), self:GetCaster() )
		self.hThrowBuff.flTime = self.flDist  / self.throw_speed
		self:GetCaster():RemoveModifierByName( "furnace_master_grabbed_buff" )
		EmitSoundOn( "Hero_Tiny.Toss.Target", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function furnace_master_throw:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil then
			return
		end

		EmitSoundOnLocationWithCaster( vLocation, "Ability.TossImpact", self:GetCaster() )
		
		if self.hThrowTarget ~= nil then
			self.hThrowBuff:Destroy()
		end

		return false
	end
end

-----------------------------------------------------------------------
