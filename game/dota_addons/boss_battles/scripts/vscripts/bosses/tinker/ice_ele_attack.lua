ice_ele_attack = class({})

function ice_ele_attack:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_IDLE_RARE, 2.0)
        return true
    end
end

function ice_ele_attack:OnSpellStart()
	if IsServer() then

		self:GetCaster():RemoveGesture(ACT_DOTA_IDLE_RARE)

		self.attack_speed = self:GetSpecialValueFor( "attack_speed" )
		self.attack_width_initial = self:GetSpecialValueFor( "attack_width_initial" )
		self.attack_width_end = self:GetSpecialValueFor( "attack_width_end" )
		self.attack_distance = self:GetSpecialValueFor( "attack_distance" )
		self.attack_damage = self:GetSpecialValueFor( "attack_damage" )
		self.duration = self:GetSpecialValueFor( "duration" )

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self.attack_speed = self.attack_speed * ( self.attack_distance / ( self.attack_distance - self.attack_width_initial ) )
		local effectName = "particles/units/heroes/hero_tusk/tusk_ice_shards_projectile.vpcf"

		if self:GetCaster():HasModifier("biting_frost_modifier_buff") then
			self.attack_speed = self.attack_speed + 500
			effectName = "particles/tinker/tinker_tusk_ice_shards_projectile.vpcf"
		end

		local info = {
			EffectName = effectName,
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetOrigin(), 
			fStartRadius = self.attack_width_initial,
			fEndRadius = self.attack_width_end,
			vVelocity = vDirection * self.attack_speed,
			fDistance = self.attack_distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		}

		ProjectileManager:CreateLinearProjectile( info )

		EmitSoundOn( "Hero_Tusk.IceShards.Cast", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function ice_ele_attack:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self.attack_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self
			}
			ApplyDamage( damage )

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
			ParticleManager:SetParticleControl( nFXIndex, 1, hTarget:GetOrigin() )
			if self:GetCaster() then
				ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
			end
			ParticleManager:SetParticleControlEnt( nFXIndex, 10, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			EmitSoundOn( "Hero_Tinker.ProjectileImpact", hTarget )
		end

		return true
	end
end