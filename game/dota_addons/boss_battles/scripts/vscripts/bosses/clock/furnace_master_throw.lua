furnace_master_throw = class({})

function furnace_master_throw:OnAbilityPhaseStart()
	if IsServer() then

		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()

		-- find all 4 furances
		local furances = 4
		local tFurnaceLocations = {}
		for i = 1, furances, 1 do
			local vFurnaceLoc = Entities:FindByName(nil, "furnace_" .. i):GetAbsOrigin()
			table.insert(tFurnaceLocations, vFurnaceLoc )
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
		EmitSoundOnLocationWithCaster( vLocation, "OgreTank.GroundSmash", self:GetCaster() )
		
		if self.hThrowTarget ~= nil then
			self.hThrowBuff:Destroy()
			if self.hThrowTarget:IsRealHero() then
				if self.hThrowTarget:IsAlive() == false then
					local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
					ParticleManager:SetParticleControlEnt( nFXIndex, 0, self.hThrowTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hThrowTarget:GetOrigin(), true )
					ParticleManager:SetParticleControl( nFXIndex, 1, self.hThrowTarget:GetOrigin() )
					ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
					ParticleManager:SetParticleControlEnt( nFXIndex, 10, self.hThrowTarget, PATTACH_ABSORIGIN_FOLLOW, nil, self.hThrowTarget:GetOrigin(), true )
					ParticleManager:ReleaseParticleIndex( nFXIndex )

					EmitSoundOn( "Dungeon.BloodSplatterImpact", self.hThrowTarget )
				end
			end
		end

		return false
	end
end

-----------------------------------------------------------------------
