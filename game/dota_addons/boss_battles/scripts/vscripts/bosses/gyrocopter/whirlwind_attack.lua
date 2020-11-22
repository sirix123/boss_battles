whirlwind_attack = class({})


function whirlwind_attack:OnSpellStart()
	--print("whirlwind_attack:OnSpellStart()")
	self.damage = 15
	self.caster = self:GetCaster()

	-- grab target from _G.whirlwindTargets[1], remove it, shoot at it
	if #_G.whirlwindTargets > 0 then
		self.target = shallowcopy(_G.whirlwindTargets[1])

		--remove [1] and reorder the list
		for i = 1, #_G.whirlwindTargets, 1 do 
			if _G.whirlwindTargets[i+1] ~= nil then 
				_G.whirlwindTargets[i] = _G.whirlwindTargets[i+1]
			else
				_G.whirlwindTargets[i] = nil
			end
		end

	    local info = {
	    -- EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
	    EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
	    Ability = self,
	    iMoveSpeed = 600,
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
		print("whirlwind_attack cast, but no targets found in _G.whirlwindTargets")
	end
end



function whirlwind_attack:OnProjectileHit( hTarget, vLocation)
	--print("whirlwind_attack:OnProjectileHit()")

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