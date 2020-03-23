
quilboar_puddle = class({})


--------------------------------------------------------------------------------

function quilboar_puddle:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function quilboar_puddle:OnSpellStart()
	if IsServer() then

		self.radius = self:GetSpecialValueFor( "radius" )
		self.duration = self:GetSpecialValueFor( "duration" )
		self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

		local vTargetPos = nil
		if self:GetCursorTarget() then
			vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			vTargetPos = self:GetCursorPosition()
		end

		local vDirection = vTargetPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		local fRangeToTarget =  ( self:GetCaster():GetOrigin() - vTargetPos ):Length2D()

		local projectile =
		{
			Target = vTargetPos,
			Source = self:GetCaster(),
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetOrigin() + Vector( 0, 0, 200 ), 
			fStartRadius = 10,
			fEndRadius = 10,
			vVelocity = vDirection * self.projectile_speed,
			fDistance = fRangeToTarget,
			EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile_linear.vpcf", --"particles/units/heroes/hero_viper/viper_viper_strike_beam.vpcf",
			iMoveSpeed = self.projectile_speed,
			vSourceLoc = self:GetCaster():GetOrigin(),
			bDodgeable = false,
			bProvidesVision = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
		}

		ProjectileManager:CreateLinearProjectile( projectile )

	end
end

---------------------------------------------------------------------------

function quilboar_puddle:OnProjectileHit( hTarget, vLocation )

	local duration = self:GetSpecialValueFor( "duration" )
	CreateModifierThinker( self:GetCaster(), self, "modifier_viper_nethertoxin_thinker", { duration }, vLocation, self:GetCaster():GetTeamNumber(), false )

	return true
end
