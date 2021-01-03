-- on target: 
-- particles/clock/gyro_base_attack_explosion.vpcf
gyro_base_attack = class({})


function gyro_base_attack:OnSpellStart()
	--print("gyro_base_attack:OnSpellStart()")
	self.caster = self:GetCaster()

	self.damage = self:GetSpecialValueFor("damage")
	self.projectile_speed = self:GetSpecialValueFor("projectile_speed")
	

	-- grab target from _G.BaseAttackTargets[1], remove it, shoot at it
	if #_G.BaseAttackTargets > 0 then
		self.target = shallowcopy(_G.BaseAttackTargets[1])

		--remove [1] and reorder the list
		for i = 1, #_G.BaseAttackTargets, 1 do 
			if _G.BaseAttackTargets[i+1] ~= nil then 
				_G.BaseAttackTargets[i] = _G.BaseAttackTargets[i+1]
			else
				_G.BaseAttackTargets[i] = nil
			end
		end

	    local info = {
	    -- EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
	    EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
	    Ability = self,
	    iMoveSpeed = self.projectile_speed,
	    Source = self.caster,
	    Target = self.target,
	    bDodgeable = false,
	    --iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,

	    --from stefans code:
	    bDeleteOnHit = true,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,


	    bProvidesVision = true,
	    iVisionTeamNumber = self.caster:GetTeamNumber(),
		iVisionRadius = 300,
		}
	    ProjectileManager:CreateTrackingProjectile( info )

	else
		print("gyro_base_attack cast, but no targets found in _G.BaseAttackTargets")
	end

end


function gyro_base_attack:OnProjectileHit( hTarget, vLocation)
	--print("gyro_base_attack:OnProjectileHit()")

    if IsServer() then
        if hTarget:IsAlive() == true then
            local dmgTable =
            {
                victim = hTarget,
                attacker = self.caster,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)

        end
    end
end